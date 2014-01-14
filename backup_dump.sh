#!/bin/bash
#
# $1: database name

pg_dump -F c -b -v $1