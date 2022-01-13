import io;
import sys;
import files;
import string;
import R;

string count_humans = ----
 last.row <- tail(read.csv("%s/counts.csv"), 1)
 res <- last.row['human_count']
----;

string find_max =  ----
v <- c(%s)
res <- which(v == max(v))
----;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

app (file out, file err) repast (file shfile, string param_line, string outputdir)
{
    "bash" shfile param_line emews_root outputdir @stdout=out @stderr=err;
}

app (void o) make_dir(string dirname) {
  "mkdir" "-p" dirname;
}

app (void o) cp_message_center() {
  "cp" (emews_root+"/complete_model/MessageCenter.log4j.properties") turbine_output;
}

cp_message_center() => {
  file repast_sh = input(emews_root+"/scripts/repast.sh");
  file upf = input(argv("f"));
  string upf_lines[] = file_lines(upf);

  string results[];

  foreach s,i in upf_lines {
    string instance = "%s/instance_%i/" % (turbine_output, i+1);
    make_dir(instance) => {
      file out <instance+"out.txt">;
      file err <instance+"err.txt">;
      (out,err) = repast(repast_sh, s, instance) => {
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
