#!/bin/bash
set -eu

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
SITE=$THIS/../docs

echo "Building site"
asciidoctor $THIS/../src/main.adoc -o $SITE/index.html
