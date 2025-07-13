#!/bin/bash
echo "Manual start command issued at $(date)"
touch /tmp/showtime-manual-start
echo "Manual start override activated. Show will start on next scheduler check (within 60 seconds)."
echo "Override will automatically clear when the schedule changes."
echo "Use 'showtime-manual-clear' to return to schedule immediately."
