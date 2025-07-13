#!/bin/bash
CACHE_FILE="/var/www/showtime/web/showtime_cache.json"
MEDIA_DIR="/var/www/showtime/media"
CLOCK_DIR="/var/www/showtime/clocks"

MEDIA_FILES=""
if [ -d "$MEDIA_DIR" ]; then
   MEDIA_FILES=$(ls "$MEDIA_DIR" 2>/dev/null | grep -E '\.(jpg|jpeg|png|gif|mp4|avi|mov|mkv|webm)$' | tr '\n' '|' | sed 's/|$//')
fi

CLOCK_FILES=""
if [ -d "$CLOCK_DIR" ]; then
   CLOCK_FILES=$(ls "$CLOCK_DIR" 2>/dev/null | grep '\.html$' | tr '\n' '|' | sed 's/|$//')
fi

cat > "$CACHE_FILE" << CACHE_CONTENT
{
   "media_files": "$MEDIA_FILES",
   "clock_files": "$CLOCK_FILES", 
   "last_updated": "$(date -Iseconds)"
}
CACHE_CONTENT

echo "Cache updated: $(echo "$MEDIA_FILES" | tr '|' '\n' | wc -l) media files, $(echo "$CLOCK_FILES" | tr '|' '\n' | wc -l) clock files"
