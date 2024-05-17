app (file o) gcc(file c, string optz) {
  "gcc" "-c" "-o" o optz c;
}
app (file x) link(file o) {
  "gcc" "-o" x o;
}
file c        = input("f.c");
file o<"f.o"> = gcc(c, "-O3");
file x<"f">   = link(o);
