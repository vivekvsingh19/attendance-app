#!/usr/bin/env python3
"""
Heroku Dyno Scheduler Script
Automatically scales dynos up/down based on schedule
Schedule: 7 AM-12 PM and 4 PM-7 PM (IST)
"""
import os
import requests
import json
from datetime import datetime
import pytz

# Heroku API configuration
HEROKU_API_TOKEN = os.getenv('HEROKU_API_TOKEN')
HEROKU_APP_NAME = os.getenv('HEROKU_APP_NAME', 'attendance-backend-api')
HEROKU_API_BASE = 'https://api.heroku.com'

# Schedule configuration (IST timezone)
IST = pytz.timezone('Asia/Kolkata')
ACTIVE_HOURS = [
    (7, 12),   # 7 AM to 12 PM
    (16, 19)   # 4 PM to 7 PM
]

def get_current_ist_hour():
    """Get current hour in IST"""
    return datetime.now(IST).hour

def should_be_active():
    """Check if the app should be active based on schedule"""
    current_hour = get_current_ist_hour()
    
    for start, end in ACTIVE_HOURS:
        if start <= current_hour < end:
            return True
    return False

def scale_dyno(scale_to):
    """Scale Heroku dyno to specified number"""
    headers = {
        'Authorization': f'Bearer {HEROKU_API_TOKEN}',
        'Accept': 'application/vnd.heroku+json; version=3',
        'Content-Type': 'application/json'
    }
    
    url = f'{HEROKU_API_BASE}/apps/{HEROKU_APP_NAME}/formation/web'
    data = {'quantity': scale_to}
    
    try:
        response = requests.patch(url, headers=headers, json=data)
        response.raise_for_status()
        print(f"Successfully scaled to {scale_to} dynos")
        return True
    except requests.exceptions.RequestException as e:
        print(f"Failed to scale dynos: {e}")
        return False

def main():
    """Main scheduler function"""
    if not HEROKU_API_TOKEN:
        print("HEROKU_API_TOKEN environment variable not set")
        return
    
    current_hour = get_current_ist_hour()
    should_active = should_be_active()
    
    print(f"Current IST hour: {current_hour}")
    print(f"Should be active: {should_active}")
    
    if should_active:
        print("Scaling UP - Active hours")
        scale_dyno(1)  # Scale up to 1 dyno
    else:
        print("Scaling DOWN - Inactive hours")
        scale_dyno(0)  # Scale down to 0 dynos

if __name__ == "__main__":
    main()
