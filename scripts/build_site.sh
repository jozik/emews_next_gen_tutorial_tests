#!/bin/bash
set -eu

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
SITE=$THIS/../docs
WEBSITE=https://repast.github.io/emews_next_gen_tutorial_tests

echo "Building site"
asciidoctor -a website=$WEBSITE $THIS/../src/main.adoc -o $SITE/index.html