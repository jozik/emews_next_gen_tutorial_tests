import files;
import string;
import sys;
import io;
import python;
import location;
import unix;
import emews;

import EQR;

// deletes the specified directory
app (void o) rm_dir(string dirname) {
  "rm" "-rf" dirname;
}

// deletes the specified directories
app (void o) rm_dirs(file dirnames[]) {
  "rm" "-rf" dirnames;
}

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");


file model_sh = input(emews_root+"/scripts/run_my_model_eq.sh");
int n_trials = toint(argv("trials", "1"));
string me_config_file = argv("me_config_file");

(float result) get_result(string output_file) {
    // TODO given the model output, set the the model result 
    result = 0.0;
}

(float agg_result) get_aggregate_result(float model_results[]) {
    // TODO replace with aggregate result calculation (e.g.,
    // take the average of model results with avg(model_results);
    agg_result = 0.0;
}

// app function used to run the model
app (file out, file err) run_model(file shfile, string param_line, string output_file, int trial, string instance_dir) {
    "bash" shfile param_line output_file trial emews_root instance_dir @stdout=out @stderr=err;
}

(float result) run_obj(string param_line, int trial, string instance_dir, string instance_id) {
    file out <instance_dir + "/" + instance_id+"_out.txt">;
    file err <instance_dir + "/" + instance_id+"_err.txt">;
    string output_file = "%s/output_%s.csv" % (instance_dir, instance_id);
    (out,err) = run_model(model_sh, param_line, output_file,  trial, instance_dir) =>
    result = get_result(output_file);
}

(string obj_result, string log_string) obj(string params, int me_iter, int param_iter) {
    float results[];
    string log_lines[];

    string instance = "%s/instance_%i_%i/" % (turbine_output, me_iter, param_iter);
    mkdir(instance) => {
        foreach i in [0:n_trials-1:1] {
            int trial = i + 1;
            string instance_id = "%i_%i_%i" % (me_iter, param_iter, trial);
            results[i] = run_obj(params, trial, instance, instance_id);
            log_lines[i] =  "%d|%d|%d|%s|%f" % (me_iter, param_iter, trial, params, results[i]);
        }
    }

    obj_result = float2string(get_aggregate_result(results)) =>
    // TODO uncomment to delete the instance directory if
    // it is not needed after the result have been computed.
    // rm_dir(instance);
    string log_lines2[];
    foreach line, i in log_lines {
      log_lines2[i] = line + "|" + obj_result;
    }
    log_string = string_join(log_lines2, "\n");
}

(void v) loop (location ME) {
    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    // Gets the model parameters from the python ME algorithm
    string params = EQR_get(ME);
    boolean c;
    if (params == "DONE")
    {
        string finals =  EQR_get(ME);
        // TODO if appropriate
        // split finals string and join with "\\n"
        // e.g. finals is a ";" separated string and we want each
        // element on its own line:
        // multi_line_finals = join(split(finals, ";"), "\\n");
        string fname = "%s/final_result" % (turbine_output);
        file results_file <fname> = write(finals) =>
        printf("Writing final result to %s", fname) =>
        // printf("Results: %s", finals) =>
        v = make_void() =>
        c = false;
    } else if (params == "EQR_ABORT") {
        printf("EQR Aborted");
        string why = EQR_get(ME);
        // TODO handle the abort if necessary, e.g., write intermediate results.
        printf("%s", why) =>
        v = propagate() =>
        c = false;
    } else {
        string param_array[] = parse_json_list(params);
        string obj_results[];
        string log[];
        foreach p, j in param_array {
            obj_results[j], log[j] = obj(p, i, j);
        }

        string res = join(obj_results, ";");
        string fname = "%s/result_log_%d.csv" % (turbine_output, i);
        file results_file <fname> = write(join(log, "\n") + "\n") =>
        EQR_put(ME, res) => c = true;
    }
  }
}


(void o) start (int ME_rank) {
    string me_script = "%s/%s" % (emews_root, "R/me.R");
    location me_loc = locationFromRank(ME_rank);
    EQR_init_script(me_loc, me_script) =>
    EQR_get(me_loc) =>
    EQR_put(me_loc, me_config_file) =>
      loop(me_loc) => {
        EQR_stop(me_loc) =>
        EQR_delete_R(me_loc);
        o = propagate();
    }
}

main() {
    int ME_ranks[];
    foreach r_rank, i in r_ranks{
        ME_ranks[i] = toint(r_rank);
    }

    foreach ME_rank, i in ME_ranks {
        start(ME_rank) =>
        printf("End rank: %d", ME_rank);
    }
}
