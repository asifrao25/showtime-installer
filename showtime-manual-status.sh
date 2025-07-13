#!/bin/bash
echo "=== Showtime Manual Control Status ==="
echo "Current time: $(date)"
echo ""

if [ -f "/tmp/showtime-override" ]; then
   override=$(cat /tmp/showtime-override)
   echo "Manual Override: ACTIVE ($override)"
else
   echo "Manual Override: NONE (following schedule)"
fi

if [ -f "/run/showtime.pid" ] && kill -0 $(cat "/run/showtime.pid" 2>/dev/null) 2>/dev/null; then
   echo "Show Status: RUNNING"
else
   echo "Show Status: STOPPED"
fi

schedule_result=$(/usr/local/bin/showtime check-schedule 2>/dev/null || echo "unknown")
echo "Schedule Says: $schedule_result"

if [ -f "/tmp/showtime-last-schedule" ]; then
   last_schedule=$(cat /tmp/showtime-last-schedule)
   echo "Last Schedule State: $last_schedule"
fi

echo ""
echo "Recent scheduler log entries:"
tail -5 /var/log/showtime-scheduler.log 2>/dev/null || echo "No log entries found"
