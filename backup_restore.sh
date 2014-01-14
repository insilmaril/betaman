#!/bin/bash
#
# $1 filenmae

DATABASE=betaman_dev

pg_restore  -F c -v -c  -d $DATABASE $1