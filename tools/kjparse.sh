#!/bin/bash

#Parte the given java file

if [  $# == 0 ]; then
    echo "Usage: `basename $0` <javaFile>"
    exit 1
fi

JAVA_FILE=$1
TOOLS_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "'ListWrap("

java -jar $TOOLS_DIR/../parser/JavaParser.jar $JAVA_FILE
