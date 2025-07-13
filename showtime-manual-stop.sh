#!/bin/bash
echo "Manual stop command issued at $(date)"
touch /tmp/showtime-manual-stop
echo "Manual stop override activated. Show will stop on next scheduler check (within 60 seconds)."
echo "Override will automatically clear when the schedule changes."
echo "Use 'showtime-manual-clear' to return to schedule immediately."
