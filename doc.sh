#! /bin/sh
haxe doc.hxml
haxelib run dox -i doc/doc.xml -o doc --title "Awe, the easy and fast ECS"
git add -A .
git commit -am "Update documentation"
git subtree push --prefix doc origin gh-pages