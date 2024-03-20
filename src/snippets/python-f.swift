import python;
x = 2; y = 3;
z = python("import F",
           "F.f(%i,%i)" % (x,y));
trace(z);
