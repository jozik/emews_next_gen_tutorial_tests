import io;                          // <1>
import string;
import files;
import R;

app (file o) simulation(int i) {    // <2>
  "bash" "-c"
    ("RANDOM=%i; echo $RANDOM" % i)
    @stdout=o;
}

string results[];                   // <3>
foreach i in [0:9] {
  f = simulation(i);
  results[i] = read(f);
}

A = join(results, ",");             // <4>
code = "m = mean(c(%s))" % A;
mean = R(code, "toString(m)");
printf(mean);
