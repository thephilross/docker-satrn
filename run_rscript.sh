#!/bin/bash

WHERE=$1

cd $WHERE; shift

/usr/bin/Rscript $@
