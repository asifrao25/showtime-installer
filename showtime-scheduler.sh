#!/bin/bash
LOG_FILE="/var/log/showtime-scheduler.log"
CHECK_INTERVAL=60
PID_FILE="/run/showtime.pid"
OVERRIDE_FILE="/tmp/showtime-override"
MANUAL_START_FILE="/tmp/showtime-manual-start"
MANUAL_STOP_FILE="/tmp/showtime-manual-stop"
LAST_SCHEDULE_FILE="/tmp/showtime-last-schedule"

log_message() {
   echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

is_show_running() {
   if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE" 2>/dev/null) 2>/dev/null; then
       return 0
   else
       return 1
   fi
}

should_show_run() {
   local result=$(/usr/local/bin/showtime check-schedule)
   if [ "$result" = "true" ]; then
       return 0
   else
       return 1
   fi
}

get_schedule_state() {
   if should_show_run; then
       echo "on"
   else
       echo "off"
   fi
}

has_schedule_changed() {
   local current_schedule=$(get_schedule_state)
   local last_schedule="none"
   
   if [ -f "$LAST_SCHEDULE_FILE" ]; then
       last_schedule=$(cat "$LAST_SCHEDULE_FILE")
   fi
   
   echo "$current_schedule" > "$LAST_SCHEDULE_FILE"
   
   if [ "$current_schedule" != "$last_schedule" ] && [ "$last_schedule" != "none" ]; then
       return 0
   else
       return 1
   fi
}

manage_display_sleep() {
   local action="$1"
   case "$action" in
       "disable")
           DISPLAY=:0 xset dpms force on >/dev/null 2>&1
           DISPLAY=:0 xset s off >/dev/null 2>&1
           DISPLAY=:0 xset -dpms >/dev/null 2>&1
           DISPLAY=:0 xset s noblank >/dev/null 2>&1
           ;;
       "enable")
           DISPLAY=:0 xset s on >/dev/null 2>&1
           DISPLAY=:0 xset +dpms >/dev/null 2>&1
           DISPLAY=:0 xset dpms 10 10 10 >/dev/null 2>&1
           ;;
   esac
}

check_manual_override() {
   if [ -f "$MANUAL_START_FILE" ]; then
       log_message "Manual START override detected"
       rm -f "$MANUAL_START_FILE"
       echo "manual-start" > "$OVERRIDE_FILE"
       manage_display_sleep "disable"
       return 0
   fi
   
   if [ -f "$MANUAL_STOP_FILE" ]; then
       log_message "Manual STOP override detected"
       rm -f "$MANUAL_STOP_FILE"
       echo "manual-stop" > "$OVERRIDE_FILE"
       manage_display_sleep "enable"
       return 0
   fi
   
   return 1
}

get_override_status() {
   if [ -f "$OVERRIDE_FILE" ]; then
       cat "$OVERRIDE_FILE"
   else
       echo "none"
   fi
}

clear_override() {
   if [ -f "$OVERRIDE_FILE" ]; then
       rm -f "$OVERRIDE_FILE"
       log_message "Manual override cleared - returning to schedule"
   fi
}

log_message "Showtime Scheduler started with auto-expiring manual override support"

while true; do
   if has_schedule_changed; then
       current_schedule=$(get_schedule_state)
       log_message "Schedule changed to: $current_schedule - clearing any manual overrides"
       clear_override
   fi
   
   check_manual_override
   override_status=$(get_override_status)
   
   case "$override_status" in
       "manual-start")
           if ! is_show_running; then
               log_message "Manual override: STARTING show"
               /usr/local/bin/showtime start >> "$LOG_FILE" 2>&1
           else
               manage_display_sleep "disable"
           fi
           ;;
       "manual-stop")
           if is_show_running; then
               log_message "Manual override: STOPPING show"
               /usr/local/bin/showtime stop >> "$LOG_FILE" 2>&1
           else
               manage_display_sleep "enable"
           fi
           ;;
       "none")
           if should_show_run; then
               if ! is_show_running; then
                   log_message "Schedule says show should be running - starting"
                   /usr/local/bin/showtime start >> "$LOG_FILE" 2>&1
               else
                   manage_display_sleep "disable"
               fi
           else
               if is_show_running; then
                   log_message "Schedule says show should be off - stopping"
                   /usr/local/bin/showtime stop >> "$LOG_FILE" 2>&1
               else
                   manage_display_sleep "enable"
               fi
           fi
           ;;
   esac
   
   sleep $CHECK_INTERVAL
done
