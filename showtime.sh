   DISPLAY=:0 $BROWSER_CMD $CHROME_FLAGS "$kiosk_url" </dev/null >/dev/null 2>&1 &
   local chrome_pid=$!
   echo $chrome_pid > "$CHROME_PID_FILE"
   log_message "$BROWSER_CMD launched with PID: $chrome_pid"
   
   sleep 3
   
   if kill -0 $chrome_pid 2>/dev/null; then
       log_message "SUCCESS: $BROWSER_CMD started successfully with PID: $chrome_pid"
       log_message "Kiosk display started successfully"
       manage_display_sleep "disable"
   else
       log_message "ERROR: Failed to start $BROWSER_CMD (PID $chrome_pid not running)"
       rm -f "$PID_FILE" "$CHROME_PID_FILE"
       manage_display_sleep "enable"
       exit 1
   fi
}

stop_showtime() {
   log_message "=== STOP command received ==="
   log_message "Stopping kiosk display"
   
   if [ -f "$CHROME_PID_FILE" ]; then
       local chrome_pid=$(cat "$CHROME_PID_FILE")
       if kill -0 $chrome_pid 2>/dev/null; then
           log_message "Stopping $BROWSER_CMD process: $chrome_pid"
           kill $chrome_pid 2>/dev/null
       fi
       rm -f "$CHROME_PID_FILE"
   fi
   
   pkill -f "$BROWSER_CMD.*kiosk" 2>/dev/null
   sleep 2
   rm -f "$PID_FILE"
   manage_display_sleep "enable"
   log_message "Kiosk display stopped"
}

check_schedule_command() {
   if [ "$(get_current_schedule)" = "true" ]; then
       echo "true"
   else
       echo "false"
   fi
   exit 0
}

show_status() {
   echo "=== Showtime Status ==="
   echo "Current time: $(date)"
   echo "Schedule active: $(get_current_schedule)"
   
   if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE" 2>/dev/null) 2>/dev/null; then
       echo "Main process: Running (PID: $(cat "$PID_FILE"))"
   else
       echo "Main process: Stopped"
   fi
   
   if [ -f "$CHROME_PID_FILE" ] && kill -0 $(cat "$CHROME_PID_FILE" 2>/dev/null) 2>/dev/null; then
       echo "Browser process: Running (PID: $(cat "$CHROME_PID_FILE"))"
   else
       echo "Browser process: Stopped"
   fi
   
   echo "Display DPMS status:"
   DISPLAY=:0 xset q | grep -A 5 "DPMS" 2>/dev/null || echo "Cannot check display status"
   
   local media_files=$(find "$MEDIA_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.webm" \) 2>/dev/null | wc -l)
   local clock_files=$(find "$CLOCK_DIR" -type f -iname "*.html" 2>/dev/null | wc -l)
   echo "Media files: $media_files"
   echo "Clock files: $clock_files"
}

case "$1" in
   "start") start_showtime ;;
   "stop") stop_showtime ;;
   "restart") stop_showtime; sleep 3; start_showtime ;;
   "status") show_status ;;
   "check-schedule") check_schedule_command ;;
   *)
       echo "Usage: $0 {start|stop|restart|status|check-schedule}"
       exit 1
       ;;
esac
   DISPLAY=:0 $BROWSER_CMD $CHROME_FLAGS "$kiosk_url" </dev/null >/dev/null 2>&1 &
   local chrome_pid=$!
   echo $chrome_pid > "$CHROME_PID_FILE"
   log_message "$BROWSER_CMD launched with PID: $chrome_pid"
   
   sleep 3
   
   if kill -0 $chrome_pid 2>/dev/null; then
       log_message "SUCCESS: $BROWSER_CMD started successfully with PID: $chrome_pid"
       log_message "Kiosk display started successfully"
       manage_display_sleep "disable"
   else
       log_message "ERROR: Failed to start $BROWSER_CMD (PID $chrome_pid not running)"
       rm -f "$PID_FILE" "$CHROME_PID_FILE"
       manage_display_sleep "enable"
       exit 1
   fi
}

stop_showtime() {
   log_message "=== STOP command received ==="
   log_message "Stopping kiosk display"
   
   if [ -f "$CHROME_PID_FILE" ]; then
       local chrome_pid=$(cat "$CHROME_PID_FILE")
       if kill -0 $chrome_pid 2>/dev/null; then
           log_message "Stopping $BROWSER_CMD process: $chrome_pid"
           kill $chrome_pid 2>/dev/null
       fi
       rm -f "$CHROME_PID_FILE"
   fi
   
   pkill -f "$BROWSER_CMD.*kiosk" 2>/dev/null
   sleep 2
   rm -f "$PID_FILE"
   manage_display_sleep "enable"
   log_message "Kiosk display stopped"
}

check_schedule_command() {
   if [ "$(get_current_schedule)" = "true" ]; then
       echo "true"
   else
       echo "false"
   fi
   exit 0
}

show_status() {
   echo "=== Showtime Status ==="
   echo "Current time: $(date)"
   echo "Schedule active: $(get_current_schedule)"
   
   if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE" 2>/dev/null) 2>/dev/null; then
       echo "Main process: Running (PID: $(cat "$PID_FILE"))"
   else
       echo "Main process: Stopped"
   fi
   
   if [ -f "$CHROME_PID_FILE" ] && kill -0 $(cat "$CHROME_PID_FILE" 2>/dev/null) 2>/dev/null; then
       echo "Browser process: Running (PID: $(cat "$CHROME_PID_FILE"))"
   else
       echo "Browser process: Stopped"
   fi
   
   echo "Display DPMS status:"
   DISPLAY=:0 xset q | grep -A 5 "DPMS" 2>/dev/null || echo "Cannot check display status"
   
   local media_files=$(find "$MEDIA_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.webm" \) 2>/dev/null | wc -l)
   local clock_files=$(find "$CLOCK_DIR" -type f -iname "*.html" 2>/dev/null | wc -l)
   echo "Media files: $media_files"
   echo "Clock files: $clock_files"
}

case "$1" in
   "start") start_showtime ;;
   "stop") stop_showtime ;;
   "restart") stop_showtime; sleep 3; start_showtime ;;
   "status") show_status ;;
   "check-schedule") check_schedule_command ;;
   *)
       echo "Usage: $0 {start|stop|restart|status|check-schedule}"
       exit 1
       ;;
esac
