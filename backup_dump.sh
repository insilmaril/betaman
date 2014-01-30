#!/bin/bash
#
# Usage:
#
# backup_dump.sh betaman > betaman-prod-2014-14-01.dump

DATE=$(date +"%Y-%m-%d_%H:%M")

DB=betaman

pg_dump -F c -b -v $DB > betaman-prod-$DATE.dump