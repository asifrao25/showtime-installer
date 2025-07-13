#!/usr/bin/env python3

from flask import Flask, request, jsonify
import os
import subprocess
from werkzeug.utils import secure_filename
from datetime import datetime
import time

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024

SHOWTIME_BASE = '/var/www/showtime'
MEDIA_DIR = os.path.join(SHOWTIME_BASE, 'media')
CLOCK_DIR = os.path.join(SHOWTIME_BASE, 'clocks')

def check_showtime_service():
   try:
       result = subprocess.run(['/usr/local/bin/showtime-manual-status'], 
                              capture_output=True, text=True, timeout=10)
       
       manual_override = "NONE"
       show_status = "UNKNOWN"
       schedule_says = "unknown"
       
       if result.returncode == 0:
           status_lines = result.stdout.strip().split('\n')
           for line in status_lines:
               if "Manual Override:" in line:
                   manual_override = line.split(": ")[1] if ": " in line else "NONE"
               elif "Show Status:" in line:
                   show_status = line.split(": ")[1] if ": " in line else "UNKNOWN"
               elif "Schedule Says:" in line:
                   schedule_says = line.split(": ")[1] if ": " in line else "unknown"
       
       is_running = "RUNNING" in show_status.upper()
       status_message = f"Show {show_status.lower()}"
       if "NONE" not in manual_override:
           status_message += f" (Override: {manual_override})"
       
       return is_running, status_message, manual_override, schedule_says
       
   except Exception as e:
       return False, f'Status check error: {str(e)}', "NONE", "unknown"

@app.after_request
def after_request(response):
   response.headers.add('Access-Control-Allow-Origin', '*')
   response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
   response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
   return response

@app.route('/')
def dashboard():
   try:
       with open('index.html', 'r') as f:
           return f.read()
   except FileNotFoundError:
       return '<h1>Dashboard HTML not found</h1>', 404

@app.route('/api/status')
def get_status():
   try:
       running, status_message, manual_override, schedule_says = check_showtime_service()
       
       return jsonify({
           'running': running,
           'manual_override': manual_override,
           'schedule_says': schedule_says,
           'error': None if running else status_message,
           'message': status_message,
           'timestamp': time.time()
       })
   
   except Exception as e:
       return jsonify({
           'running': False,
           'manual_override': 'NONE',
           'schedule_says': 'unknown',
           'error': f'Status check failed: {str(e)}',
           'message': 'Unable to determine service status',
           'timestamp': time.time()
       })

@app.route('/api/start', methods=['POST'])
def manual_start():
   try:
       subprocess.run(['/usr/local/bin/showtime-manual-start'], capture_output=True, text=True, timeout=10)
       return jsonify({'message': 'Manual start override activated'})
   except Exception as e:
       return jsonify({'error': f'Manual start command failed: {str(e)}'}), 500

@app.route('/api/stop', methods=['POST'])
def manual_stop():
   try:
       subprocess.run(['/usr/local/bin/showtime-manual-stop'], capture_output=True, text=True, timeout=10)
       return jsonify({'message': 'Manual stop override activated'})
   except Exception as e:
       return jsonify({'error': f'Manual stop command failed: {str(e)}'}), 500

@app.route('/api/manual-clear', methods=['POST'])
def clear_manual_override():
   try:
       subprocess.run(['/usr/local/bin/showtime-manual-clear'], capture_output=True, text=True, timeout=10)
       return jsonify({'message': 'Manual overrides cleared - following schedule'})
   except Exception as e:
       return jsonify({'error': f'Clear override command failed: {str(e)}'}), 500

if __name__ == '__main__':
   app.run(host='0.0.0.0', port=5001, debug=False)
