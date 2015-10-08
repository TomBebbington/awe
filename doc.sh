#! /bin/bash
haxe doc.hxml
mv -f doc /tmp/doc
git checkout gh-pages
rm -rf ./*
mv -f /tmp/doc/* .
rm -rf /tmp/doc
git add -A .
git commit -q -am "Update documentation"
git push -fq origin gh-pages
git checkout -f master