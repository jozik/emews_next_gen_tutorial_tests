#!/bin/bash
set -eu

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
SITE=$THIS/../docs

echo "Building site"
# Install asciidoctor-bibtex. E.g., gem install asciidoctor-bibtex
asciidoctor -r asciidoctor-bibtex $THIS/../src/main.adoc -o $SITE/index.html

