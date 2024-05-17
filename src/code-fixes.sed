# CSS fixes for generated code blocks with linenums
# Delete 2 vertical lines:
/td.linenos/s/1px/0px/
/pre.pygments .lineno/s/1px/0px/
# Change opacity to solid:
/pre.pygments .lineno/s/:.35/:1/
