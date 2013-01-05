#!/bin/bash

# Compiles the given java program, run it and removes the remaining class file.

if [ $# -ne 1 ]; then
    echo "Usage: `basename $0` <javaFile or dir>"
    exit 1
fi

javaFile=$1

mainFile=`basename $javaFile`
mainClass=`echo "$mainFile" | cut -d'.' -f1`

if [ -f $javaFile ];
then
  #if the file starts with a package declaration, add package to the main class name
  read -r IN < $javaFile
  PACKAGE_STR=${IN:0:7}
  if [ "$PACKAGE_STR" == "package" ];
    then mainClass="${IN:8:${#IN}-9}.$mainClass"
  fi
  JAVAC_ARG=$javaFile
else
  JAVAC_ARG=$(find -P $javaFile -name "*.java" -type f)
fi

mkdir .jdk-run
javac -d .jdk-run $JAVAC_ARG
java -ea -cp .jdk-run $mainClass
rm -r -f .jdk-run
