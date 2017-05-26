#!/usr/bin/env bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P) # https://stackoverflow.com/a/17744637
source $DIR/.profile
lyp use 2.18.2
lilypond $DIR/start.ly
