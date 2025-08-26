import certifi
import os
os.environ['REQUESTS_CA_BUNDLE'] = certifi.where()

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import re
import json
from typing import Dict, Any
import uvicorn
from sleep_middleware import sleep_mode_middleware

app = FastAPI(title="College Attendance Scraper", version="1.0.0")

# Add sleep mode middleware (if enabled)
SLEEP_MODE_ENABLED = os.getenv('SLEEP_MODE_ENABLED', 'false').lower() == 'true'
if SLEEP_MODE_ENABLED:
    app.middleware("http")(sleep_mode_middleware)

# Add CORS middleware to allow Flutter app to make requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

class LoginRequest(BaseModel):
    college_id: str
    password: str

class AttendanceData(BaseModel):
    subject: str
    total: int
    attended: int
    percentage: float

class AttendanceResponse(BaseModel):
    success: bool
    message: str
    data: Dict[str, Dict[str, Any]] = None

@app.get("/")
async def root():
    """Root endpoint with basic info"""
    return {"message": "College Attendance Scraper API", "status": "running"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    from sleep_middleware import is_service_active, get_current_ist_hour
    from datetime import datetime
    import pytz
    
    IST = pytz.timezone('Asia/Kolkata')
    current_time = datetime.now(IST).strftime("%Y-%m-%d %I:%M %p")
    
    return {
        "status": "healthy",
        "service_active": is_service_active() if SLEEP_MODE_ENABLED else True,
        "sleep_mode_enabled": SLEEP_MODE_ENABLED,
        "current_time_ist": current_time,
        "active_hours": ["7:00 AM - 12:00 PM", "4:00 PM - 7:00 PM"] if SLEEP_MODE_ENABLED else "24/7"
    }

@app.post("/login-and-fetch-attendance", response_model=AttendanceResponse)
async def login_and_fetch_attendance(request: LoginRequest):
    """
    Login to the college portal and fetch attendance data
    """
    try:
        # Create a session to maintain cookies
        session = requests.Session()
        
        # Step 1: Get the login page to extract ASP.NET ViewState and EventValidation
        login_url = "https://portal.lnct.ac.in/Accsoft2/StudentLogin.aspx"  # Correct student login URL
        
        # Set headers to mimic a real browser
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
        
        # Get the login page
        try:
            response = session.get(login_url, headers=headers, timeout=5)
        except requests.exceptions.Timeout:
            print("Login page request timed out.")
            return AttendanceResponse(
                success=False,
                message="Login page request timed out. Please try again later.",
            )
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Failed to access login page")
        
        # Parse the HTML to extract ViewState and EventValidation
        soup = BeautifulSoup(response.content, 'html.parser')
        
        viewstate = soup.find('input', {'name': '__VIEWSTATE'})
        eventvalidation = soup.find('input', {'name': '__EVENTVALIDATION'})
        viewstategenerator = soup.find('input', {'name': '__VIEWSTATEGENERATOR'})
        
        if not viewstate or not eventvalidation:
            raise HTTPException(status_code=500, detail="Could not find required form fields")
        
        # Step 2: Prepare login data
        login_data = {
            '__VIEWSTATE': viewstate['value'],
            '__EVENTVALIDATION': eventvalidation['value'],
            '__VIEWSTATEGENERATOR': viewstategenerator['value'] if viewstategenerator else '',
            'ctl00$cph1$rdbtnlType': '2',  # Student login radio button
            'ctl00$cph1$txtStuUser': request.college_id,
            'ctl00$cph1$txtStuPsw': request.password,
            'ctl00$cph1$btnStuLogin': 'Login »',
            '__EVENTTARGET': '',
            '__EVENTARGUMENT': '',
            '__LASTFOCUS': '',
        }
        
        # Step 3: Perform login
        try:
            login_response = session.post(login_url, data=login_data, headers=headers, allow_redirects=True, timeout=5)
        except requests.exceptions.Timeout:
            print("Login request timed out.")
            return AttendanceResponse(
                success=False,
                message="Login request timed out. Please try again later.",
            )
        except Exception as e:
            print(f"Login request failed: {e}.")
            return AttendanceResponse(
                success=False,
                message=f"Login request error: {str(e)}",
            )
        
        # Debug: Log response details
        print(f"Login response status: {login_response.status_code}")
        print(f"Login response URL: {login_response.url}")
        print(f"Response contains 'welcome': {'welcome' in login_response.text.lower()}")
        print(f"Response contains 'student': {'student' in login_response.text.lower()}")
        
        # Log cookies received
        print(f"Cookies received: {dict(session.cookies)}")
        
        # DEBUG: Check for specific success/failure indicators in response
        response_text = login_response.text.lower()
        success_indicators = ['dashboard', 'welcome', 'logout', 'attendance', 'profile']
        # Make failure indicators more specific to avoid false positives
        failure_indicators = ['invalid username', 'invalid password', 'login failed', 'authentication failed']
        
        print(f"Success indicators found: {[ind for ind in success_indicators if ind in response_text]}")
        print(f"Failure indicators found: {[ind for ind in failure_indicators if ind in response_text]}")
        
        # DEBUG: Save login response to see what we're actually getting
        with open('/tmp/login_response.html', 'w', encoding='utf-8') as f:
            f.write(login_response.text)
        print("Login response saved to /tmp/login_response.html for inspection")
        
        # Check if login was successful
        response_text = login_response.text.lower()
        
        # Debug: Log response details
        print(f"Login response status: {login_response.status_code}")
        print(f"Login response URL: {login_response.url}")
        print(f"Response length: {len(login_response.text)}")
        print(f"Cookies received: {dict(session.cookies)}")
        
        # Check for login failure indicators
        error_indicators = [
            'invalid username',
            'invalid password', 
            'incorrect username',
            'incorrect password',
            'authentication failed',
            'login failed',
            'wrong password',
            'wrong username',
            'access denied',
            'invalid credentials',
            'accsoft 2.0 : login'  # Still at login page
        ]
        
        # Check for specific error indicators
        for error in error_indicators:
            if error in response_text:
                print(f"Login failed - found error indicator: {error}")
                return AttendanceResponse(
                    success=False,
                    message="Login authentication failed. Please check your credentials.",
                )
        
        print("Login appears successful, proceeding to attendance page...")
        # Step 4: Access the specific attendance page
        attendance_url = "https://portal.lnct.ac.in/Accsoft2/Parents/StuAttendanceStatus.aspx"
        attendance_headers = headers.copy()
        attendance_headers['Referer'] = login_url
        try:
            attendance_response = session.get(attendance_url, headers=attendance_headers, timeout=5)
        except requests.exceptions.Timeout:
            print("Attendance request timed out.")
            return AttendanceResponse(
                success=False,
                message="Attendance request timed out. Please try again later.",
            )
        except Exception as e:
            print(f"Attendance request failed: {e}.")
            return AttendanceResponse(
                success=False,
                message=f"Attendance request error: {str(e)}",
            )
        
        # DEBUG: Check if we're not redirected back to login
        if "studentlogin.aspx" in attendance_response.url.lower():
            print("Redirected to login - session may have expired")
            return AttendanceResponse(
                success=False,
                message="Session expired or login failed. Please try again.",
            )
        
        attendance_soup = BeautifulSoup(attendance_response.content, 'html.parser')
        print(f"Attendance page length: {len(attendance_response.text)}")
        
        # Initialize attendance data
        attendance_data = {}
        
        # Look for attendance tables
        tables = attendance_soup.find_all('table')
        print(f"Found {len(tables)} tables to analyze")
        
        for table_idx, table in enumerate(tables):
            rows = table.find_all('tr')
            if len(rows) > 1:
                print(f"\n=== Analyzing Table {table_idx + 1} ===")
                # Log the first 5 rows for debugging
                for debug_row_idx, debug_row in enumerate(rows[:5]):
                    debug_cells = [cell.get_text(strip=True) for cell in debug_row.find_all(['th', 'td'])]
                    print(f"Debug Row {debug_row_idx}: {debug_cells}")
                # Look for header row
                header_row = rows[0]
                header_cells = [cell.get_text(strip=True).lower() for cell in header_row.find_all(['th', 'td'])]
                print(f"Header row: {header_cells}")
                attendance_keywords = ['subject', 'attendance', 'present', 'absent', 'total', 'percentage', '%']
                has_attendance_headers = any(keyword in ' '.join(header_cells) for keyword in attendance_keywords)
                if has_attendance_headers or len(rows) > 3:
                    print("Found potential attendance table!")
                    # Find the index of the subject, total, attended, and percentage columns
                    subject_idx = None
                    total_idx = None
                    attended_idx = None
                    percentage_idx = None
                    for idx, col in enumerate(header_cells):
                        if 'subject' in col or 'course' in col:
                            subject_idx = idx
                        if 'total' in col:
                            total_idx = idx
                        if 'attend' in col or 'present' in col:
                            attended_idx = idx
                        if 'percent' in col or '%' in col:
                            percentage_idx = idx
                    for row_idx, row in enumerate(rows[1:], 1):
                        cells = row.find_all(['td', 'th'])
                        cell_texts = [cell.get_text(strip=True) for cell in cells]
                        if any(cell_texts) and subject_idx is not None:
                            subject = cell_texts[subject_idx] if subject_idx < len(cell_texts) else None
                            total = int(cell_texts[total_idx]) if total_idx is not None and total_idx < len(cell_texts) and cell_texts[total_idx].isdigit() else None
                            attended = int(cell_texts[attended_idx]) if attended_idx is not None and attended_idx < len(cell_texts) and cell_texts[attended_idx].isdigit() else None
                            percentage = float(cell_texts[percentage_idx]) if percentage_idx is not None and percentage_idx < len(cell_texts) and re.match(r'\d+\.?\d*', cell_texts[percentage_idx]) else None
                            if subject and total is not None and attended is not None:
                                attendance_data[subject] = {
                                    "total": total,
                                    "attended": attended,
                                    "percentage": round(percentage, 2) if percentage is not None else None
                                }
                                print(f"✓ Added subject: {subject} -> {attendance_data[subject]}")
        
        if attendance_data:
            print(f"\n✅ Successfully found attendance data: {attendance_data}")
            return AttendanceResponse(
                success=True,
                message="Attendance data fetched successfully",
                data=attendance_data
            )
        else:
            print("No attendance data found in tables")
            # Debug: Show page content snippet
            page_snippet = attendance_response.text[:1000].replace('\n', ' ').replace('\r', '')
            print(f"Page content preview: {page_snippet}...")
            return AttendanceResponse(
                success=False,
                message="No attendance data found on the page. The page structure may have changed."
            )
    
    except requests.exceptions.RequestException as e:
        print(f"Network error: {e}")
        return AttendanceResponse(
            success=False,
            message=f"Network error: {str(e)}",
        )
    except Exception as e:
        print(f"General error: {e}")
        return AttendanceResponse(
            success=False,
            message=f"General error: {str(e)}",
        )

@app.get("/")
async def root():
    return {"message": "College Attendance Scraper API is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "message": "API is running properly"}

@app.post("/test-login")
async def test_login():
    """
    Test endpoint that returns dummy data without web scraping
    """
    return AttendanceResponse(
        success=True,
        message="Test login successful - dummy data",
        data={
            "ADA": {"total": 40, "attended": 35, "percentage": 87.50},
            "COA": {"total": 45, "attended": 34, "percentage": 75.56},
            "Mathematics-III": {"total": 48, "attended": 42, "percentage": 87.50},
            "Operating Systems": {"total": 42, "attended": 38, "percentage": 90.48},
            "Database Management Systems": {"total": 44, "attended": 40, "percentage": 90.91},
            "Software Engineering": {"total": 38, "attended": 32, "percentage": 84.21},
            "Computer Networks": {"total": 36, "attended": 30, "percentage": 83.33},
            "Data Structures Lab": {"total": 24, "attended": 22, "percentage": 91.67},
            "Web Technology": {"total": 32, "attended": 28, "percentage": 87.50},
            "Python Programming": {"total": 36, "attended": 33, "percentage": 91.67}
        }
    )

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
