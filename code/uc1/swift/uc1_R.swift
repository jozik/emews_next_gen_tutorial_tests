import io;
import sys;
import files;
import string;
import emews;
import R;

string count_humans = ----
last.row <- tail(read.csv("%s/counts.csv"), 1)
res <- last.row["human_count"]
----;

string find_max =  ----
v <- c(%s)
res <- which(v == max(v))
----;


string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

file model_sh = input(emews_root+"/scripts/run_repast_uc1.sh");
file upf = input(argv("f"));

// app function used to run the model
app (file out, file err) run_model(file shfile, string param_line, string instance)
{
    "bash" shfile param_line emews_root instance @stdout=out @stderr=err;
}


// call this to create any required directories
app (void o) make_dir(string dirname) {
    "mkdir" "-p" dirname;
}

// Anything that needs to be done prior to a model
// run (e.g. file creation) should be done within this
// function.
app (void o) run_prerequisites() {
  "cp" (emews_root+"/complete_model/MessageCenter.log4j.properties") turbine_output;
}

// Iterate over each line in the upf file, passing each line 
// to the model script to run
main() {
  run_prerequisites() => {
    string upf_lines[] = file_lines(upf);
    string results[];
    foreach s,i in upf_lines {
      string instance = "%s/instance_%i/" % (turbine_output, i+1);
      make_dir(instance) => {
        file out <instance+"out.txt">;
        file err <instance+"err.txt">;
        (out,err) = run_model(model_sh, s, instance) => {
          string code = count_humans % instance;
          results[i] = R(code, "toString(res)");
        }
      }
    }

    string results_str = string_join(results, ",");
    string code = find_max % results_str;
    string maxs = R(code, "toString(res)");
    string max_idxs[] = split(maxs, ",");
    string best_params[];
    foreach s, i in max_idxs {
      int idx = toint(trim(s));
      best_params[i] = upf_lines[idx - 1];
    }
    file best_out <emews_root + "/output/best_parameters.txt"> =
      write(string_join(best_params, "\n"));
  }
}
