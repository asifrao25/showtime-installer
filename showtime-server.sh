#!/bin/bash
pkill -f "python.*808"
fuser -k 8081/tcp 2>/dev/null
cd /var/www/showtime
python3 -m http.server 8081 --bind 0.0.0.0
