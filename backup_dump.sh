#!/bin/bash
#
# Usage:
#
# backup_dump.sh betaman > betaman-prod-2014-14-01.dump

DATE=$(date +"%Y-%m-%d_%H:%M")

DB=betaman

pg_dump -F c -b -v $DB > backup/betaman-prod-$DATE.dump

DEST="uwedr@salam.suse.de:/data/work/betaman/backup"

echo "Copying DB dump and logfile..."
cp log/production.log backup
rsync -auv backup/ $DEST