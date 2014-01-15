#!/bin/bash
#
# Usage:
#
# backup_dump.sh betaman > betaman-prod-2014-14-01.dump

pg_dump -F c -b -v $1