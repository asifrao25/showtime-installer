#!/bin/bash
echo "Clearing manual overrides at $(date)"
rm -f /tmp/showtime-override /tmp/showtime-manual-start /tmp/showtime-manual-stop
echo "Manual overrides cleared. Scheduler will now follow automatic schedule."
