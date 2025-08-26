"""
Smart Sleep Mode Middleware for FastAPI
Only serves requests during active hours: 7 AM-12 PM and 4 PM-7 PM IST
"""
from fastapi import HTTPException
from fastapi.responses import JSONResponse
from datetime import datetime
import pytz

# Schedule configuration (IST timezone)
IST = pytz.timezone('Asia/Kolkata')
ACTIVE_HOURS = [
    (7, 12),   # 7 AM to 12 PM
    (16, 19)   # 4 PM to 7 PM
]

def get_current_ist_hour():
    """Get current hour in IST"""
    return datetime.now(IST).hour

def is_service_active():
    """Check if the service should be active based on schedule"""
    current_hour = get_current_ist_hour()
    
    for start, end in ACTIVE_HOURS:
        if start <= current_hour < end:
            return True
    return False

def get_next_active_time():
    """Get the next active time period"""
    current_hour = get_current_ist_hour()
    
    # Check if we're before first active period
    if current_hour < 7:
        return "7:00 AM"
    # Check if we're between active periods
    elif 12 <= current_hour < 16:
        return "4:00 PM"
    # Check if we're after last active period
    else:
        return "7:00 AM (next day)"

async def sleep_mode_middleware(request, call_next):
    """
    Middleware to handle sleep mode during inactive hours
    """
    # Health check endpoint should always be available
    if request.url.path in ["/", "/health", "/docs", "/openapi.json"]:
        return await call_next(request)
    
    # Check if service is active
    if not is_service_active():
        next_active = get_next_active_time()
        current_time = datetime.now(IST).strftime("%I:%M %p")
        
        return JSONResponse(
            status_code=503,
            content={
                "success": False,
                "message": "Service is currently in sleep mode",
                "details": {
                    "current_time_ist": current_time,
                    "active_hours": [
                        "7:00 AM - 12:00 PM",
                        "4:00 PM - 7:00 PM"
                    ],
                    "next_active_at": next_active,
                    "timezone": "Asia/Kolkata (IST)"
                }
            }
        )
    
    return await call_next(request)
