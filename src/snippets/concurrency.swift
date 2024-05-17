(int o) fib(int i) {
  if (i < 2) {
    ... // base cases
  }
  else {
    o = fib(i-1) + fib(i-2);
  }
}

foreach i in [0:N-1] {
  simulate(i);
}
