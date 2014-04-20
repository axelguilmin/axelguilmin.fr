#!/bin/bash

# /!\ Only tested on OSX
# Needs java
# Needs base64

# Copy whole project
echo ' -------- Copy whole project in ./prod-------- '
rm -Rf ./prod
mkdir ./prod
cp -r -v ./dev/ ./prod/
cd ./prod

# Replace CSS background-image url by base64 data
# See http://stackoverflow.com/questions/5465446/replacing-all-images-in-a-css-file-with-base64-encoded-strings-from-the-command
echo ' -------- Use base64 for background-image in css -------- '
cd ./css
for CSS_FILE in $(ls)
do
  awk -F'[()]' '

  /background.*url(.*).*/ {
    cmd=sprintf("base64 %s",$2)
    cmd | getline b64
    close(cmd)
    $0=$1 "(data:image/png;base64," b64 ")" $3
  }1' ${CSS_FILE} > ${CSS_FILE}.tmp && mv ${CSS_FILE}.tmp ${CSS_FILE}

  echo ${CSS_FILE} updated
done
cd ..

# Run less compiler
# TODO

# Compress css, html and js
# See YUI Compressor http://yui.github.io/yuicompressor/
echo ' -------- Running YUI Compressor on css files -------- '
cd ./css
java -jar ../../tools/yuicompressor-2.4.8.jar --type css -v -o '.css$:.css' *.css
cd ..
cd ./js
java -jar ../../tools/yuicompressor-2.4.8.jar --type js -v -o '.js$:.js' *.js
cd ..

# See HTML Compressor https://code.google.com/p/htmlcompressor
echo ' -------- Running HTML Compressor -------- '
for HTML_FILE in $(ls | grep -i -E '.html|.xml')
do
  java -jar ../tools/htmlcompressor-1.5.3.jar ${HTML_FILE} > ${HTML_FILE}.tmp && mv ${HTML_FILE}.tmp ${HTML_FILE}
  echo ${HTML_FILE} compressed
done

# Create sitemap.xml
# Perl script from http://code.google.com/p/perlsitemapgenerator/
# perl ../tools/perl_sitemap_gen/sitemap_gen.pl --config=../tools/perl_sitemap_gen/config.xml --testing
# TODO