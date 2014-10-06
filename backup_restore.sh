#!/bin/bash
#
# $1 filenmae

DATABASE=betaman

pg_restore  -F c -v -c  -d $DATABASE $1