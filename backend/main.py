import certifi
import os
os.environ['REQUESTS_CA_BUNDLE'] = certifi.where()

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import re
from datetime import datetime, timedelta
import json
from typing import Dict, Any, Optional
import uvicorn
import hashlib

app = FastAPI(title="College Attendance Scraper", version="1.0.0")

# In-memory cache for attendance data (optimized for Heroku)
attendance_cache = {}
datewise_cache = {}
tilldate_cache = {}
CACHE_DURATION_HOURS = 6

def get_cache_key(username: str, endpoint: str) -> str:
    """Generate a unique cache key for user and endpoint"""
    return hashlib.md5(f"{username}_{endpoint}".encode()).hexdigest()

def is_cache_valid(cache_entry: dict) -> bool:
    """Check if cache entry is still valid (less than 6 hours old)"""
    if not cache_entry or 'timestamp' not in cache_entry:
        return False
    
    cache_time = datetime.fromisoformat(cache_entry['timestamp'])
    return datetime.now() - cache_time < timedelta(hours=CACHE_DURATION_HOURS)

def get_cached_data(username: str, endpoint: str) -> Optional[dict]:
    """Retrieve cached data if valid"""
    cache_key = get_cache_key(username, endpoint)
    
    if endpoint == 'attendance':
        cache_store = attendance_cache
    elif endpoint == 'datewise':
        cache_store = datewise_cache
    elif endpoint == 'tilldate':
        cache_store = tilldate_cache
    else:
        return None
    
    if cache_key in cache_store and is_cache_valid(cache_store[cache_key]):
        print(f"✅ Serving cached data for {username} - {endpoint}")
        return cache_store[cache_key]['data']
    
    return None

def set_cached_data(username: str, endpoint: str, data: dict) -> None:
    """Store data in cache with timestamp"""
    cache_key = get_cache_key(username, endpoint)
    
    if endpoint == 'attendance':
        cache_store = attendance_cache
    elif endpoint == 'datewise':
        cache_store = datewise_cache
    elif endpoint == 'tilldate':
        cache_store = tilldate_cache
    else:
        return
    
    cache_store[cache_key] = {
        'data': data,
        'timestamp': datetime.now().isoformat()
    }
    print(f"💾 Cached data for {username} - {endpoint}")

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
    institution_type: str = "college"  # "college" or "university"

class AttendanceData(BaseModel):
    subject: str
    total: int
    attended: int
    percentage: float

class AttendanceResponse(BaseModel):
    success: bool
    message: str
    data: Dict[str, Dict[str, Any]] = None

async def login_to_portal(username: str, password: str, institution_type: str = "college"):
    """
    Common login function for portal access
    Returns session and attendance page soup
    """
    session = requests.Session()
    
    # Set headers to mimic a real browser (matching working version)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',  # No 'br' encoding
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
    }
    
    # Choose URL based on institution type
    if institution_type == "university":
        login_url = "https://accsoft.lnctu.ac.in/Accsoft2/StudentLogin.aspx"
        attendance_url = "https://accsoft.lnctu.ac.in/Accsoft2/Parents/StuAttendanceStatus.aspx"
    else:  # default to college
        login_url = "https://portal.lnct.ac.in/Accsoft2/StudentLogin.aspx"
        attendance_url = "https://portal.lnct.ac.in/Accsoft2/Parents/StuAttendanceStatus.aspx"
    
    # Get login page to extract viewstate
    response = session.get(login_url, headers=headers, timeout=10)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    viewstate_elem = soup.find('input', {'name': '__VIEWSTATE'})
    viewstate_gen_elem = soup.find('input', {'name': '__VIEWSTATEGENERATOR'})
    event_validation_elem = soup.find('input', {'name': '__EVENTVALIDATION'})
    
    if not viewstate_elem or not event_validation_elem:
        raise Exception("Could not extract login form data")
    
    viewstate = viewstate_elem['value']
    viewstate_generator = viewstate_gen_elem['value'] if viewstate_gen_elem else ''
    event_validation = event_validation_elem['value']
    
    # Prepare login data (matching working version exactly)
    login_data = {
        '__VIEWSTATE': viewstate,
        '__EVENTVALIDATION': event_validation,
        '__VIEWSTATEGENERATOR': viewstate_generator,
        'ctl00$cph1$rdbtnlType': '2',  # Student login radio button
        'ctl00$cph1$txtStuUser': username,
        'ctl00$cph1$txtStuPsw': password,
        'ctl00$cph1$btnStuLogin': 'Login »',  # Correct button text
        '__EVENTTARGET': '',
        '__EVENTARGUMENT': '',
        '__LASTFOCUS': '',
    }
    
    # Submit login
    login_response = session.post(login_url, data=login_data, headers=headers, allow_redirects=True, timeout=10)
    
    # Check if login was successful by looking for redirect or success indicators
    if "studentlogin.aspx" in login_response.url.lower():
        raise Exception("Invalid credentials")
    
    # Access attendance page
    attendance_headers = headers.copy()
    attendance_headers['Referer'] = login_url
    attendance_response = session.get(attendance_url, headers=attendance_headers, timeout=10)
    
    # Check if we're redirected back to login
    if "studentlogin.aspx" in attendance_response.url.lower():
        raise Exception("Invalid credentials")
    
    # Parse the attendance page
    soup = BeautifulSoup(attendance_response.content, 'html.parser')
    
    # Basic validation: Check if the page actually contains attendance data
    # This prevents cross-institution login issues
    page_text = soup.get_text().lower()
    
    # Look for common attendance-related content
    has_attendance_content = any(keyword in page_text for keyword in [
        'attendance', 'subject', 'percentage', 'present', 'absent', 'total classes'
    ])
    
    # Also check for tables that might contain attendance data
    tables = soup.find_all('table')
    has_data_tables = len(tables) > 0
    
    # If page has no attendance content or tables, it's likely wrong credentials for this portal
    if not has_attendance_content and not has_data_tables:
        raise Exception("Invalid credentials for this institution")
    
    # Additional check: Look for actual student data in tables
    has_student_data = False
    for table in tables:
        rows = table.find_all('tr')
        if len(rows) > 1:  # Has more than just header
            for row in rows[1:]:  # Skip header
                cells = row.find_all(['td', 'th'])
                if len(cells) >= 3:  # Subject, numbers, percentages
                    cell_texts = [cell.get_text(strip=True) for cell in cells]
                    # Look for numeric data that suggests attendance records
                    has_numbers = any(text.replace('%', '').replace('.', '').isdigit() for text in cell_texts)
                    if has_numbers:
                        has_student_data = True
                        break
    
    if not has_student_data:
        raise Exception("No attendance data found - invalid credentials for this institution")
    
    return session, soup

@app.post("/login-and-fetch-attendance", response_model=AttendanceResponse)
async def login_and_fetch_attendance(request: LoginRequest):
    """
    Login to the college portal and fetch attendance data
    Uses 6-hour caching to optimize Heroku dyno usage
    """
    try:
        # Check if we have cached data that's less than 6 hours old
        cached_data = get_cached_data(request.college_id, 'attendance')
        if cached_data:
            return AttendanceResponse(
                success=True,
                message="Attendance data retrieved from cache (less than 6 hours old)",
                data=cached_data
            )
        
        print(f"🔄 Fetching fresh data for {request.college_id} - cache miss or expired")
        
        # Use common login function
        session, soup = await login_to_portal(request.college_id, request.password, request.institution_type)
        
        # Initialize attendance data
        attendance_data = {}
        
        # Look for attendance table in the soup
        tables = soup.find_all('table')
        print(f"Found {len(tables)} tables on attendance page")
        
        for i, table in enumerate(tables):
            print(f"\n=== Table {i+1} ===")
            rows = table.find_all('tr')
            print(f"Table {i+1} has {len(rows)} rows")
            
            for j, row in enumerate(rows):
                cells = row.find_all(['td', 'th'])
                if len(cells) >= 4:  # Subject, Total, Attended, Percentage
                    cell_texts = [cell.get_text(strip=True) for cell in cells]
                    print(f"Row {j+1}: {cell_texts}")
                    
                    # Try to parse attendance data
                    if j > 0 and len(cell_texts) >= 4:  # Skip header row
                        try:
                            subject = cell_texts[0]
                            if subject and not subject.lower() in ['subject', 'total', '']:
                                # Try different cell positions for total/attended/percentage
                                for k in range(1, len(cell_texts)-2):
                                    try:
                                        total = int(cell_texts[k])
                                        attended = int(cell_texts[k+1])
                                        percentage_text = cell_texts[k+2].replace('%', '').replace(' ', '')
                                        percentage = float(percentage_text)
                                        
                                        if total > 0 and attended >= 0 and 0 <= percentage <= 100:
                                            attendance_data[subject] = {
                                                "total": total,
                                                "attended": attended,
                                                "percentage": round(percentage, 2) if percentage is not None else None
                                            }
                                            print(f"✓ Added subject: {subject} -> {attendance_data[subject]}")
                                            break
                                    except (ValueError, IndexError):
                                        continue
                        except Exception as e:
                            print(f"Error parsing row: {e}")
                            continue
        
        if attendance_data:
            print(f"✅ Successfully found attendance data: {attendance_data}")
            
            # Cache the successful response for 6 hours
            set_cached_data(request.college_id, 'attendance', attendance_data)
            
            return AttendanceResponse(
                success=True,
                message="Attendance data fetched successfully",
                data=attendance_data
            )
        else:
            print("No attendance data found in tables")
            return AttendanceResponse(
                success=False,
                message="No attendance data found on the page. The page structure may have changed."
            )
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
            
            # Cache the successful response for 6 hours
            set_cached_data(request.college_id, 'attendance', attendance_data)
            
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

class DatewiseAttendanceResponse(BaseModel):
    success: bool
    message: str
    data: list = None

@app.get("/dateWise")
async def get_datewise_attendance(username: str, password: str, institution_type: str = "college"):
    """
    Get date-wise attendance
    Uses 6-hour caching to optimize Heroku dyno usage
    """
    try:
        # Check if we have cached data that's less than 6 hours old
        cached_data = get_cached_data(username, 'datewise')
        if cached_data:
            return DatewiseAttendanceResponse(
                success=True,
                message="Date-wise attendance retrieved from cache (less than 6 hours old)",
                data=cached_data
            )
        
        print(f"🔄 Fetching fresh date-wise data for {username} - cache miss or expired")
        
        # Use common login function
        session, soup = await login_to_portal(username, password, institution_type)
        
        # Find all span elements to debug what's available
        total_period_element = soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_lbltotperiod'})
        not_applicable_element = soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_lbltotaln'})
        
        print(f"Total period element found: {total_period_element is not None}")
        print(f"Not applicable element found: {not_applicable_element is not None}")
        
        # If we can't find the specific elements, let's look for any elements with 'lbltot' in the id
        if not total_period_element:
            lbltot_elements = soup.find_all('span', {'id': lambda x: x and 'lbltot' in x})
            print(f"Found {len(lbltot_elements)} elements with 'lbltot' in id:")
            for elem in lbltot_elements:
                print(f"  ID: {elem.get('id')}, Text: {elem.get_text(strip=True)}")
            
            # Try alternative ID patterns
            total_period_element = soup.find('span', {'id': lambda x: x and 'lbltotperiod' in x}) or \
                                 soup.find('span', {'id': lambda x: x and 'totperiod' in x})
        
        if not not_applicable_element:
            lbltotal_elements = soup.find_all('span', {'id': lambda x: x and 'lbltotal' in x})
            print(f"Found {len(lbltotal_elements)} elements with 'lbltotal' in id:")
            for elem in lbltotal_elements:
                print(f"  ID: {elem.get('id')}, Text: {elem.get_text(strip=True)}")
                
            not_applicable_element = soup.find('span', {'id': lambda x: x and 'lbltotaln' in x}) or \
                                   soup.find('span', {'id': lambda x: x and 'totaln' in x})
        
        # If still not found, return all spans for debugging
        if not total_period_element or not not_applicable_element:
            all_spans = soup.find_all('span')
            print(f"Total spans found: {len(all_spans)}")
            span_info = []
            for span in all_spans[:20]:  # First 20 spans for debugging
                span_info.append({
                    'id': span.get('id', 'no-id'),
                    'text': span.get_text(strip=True)[:50]  # First 50 chars
                })
            
            raise Exception(f"Could not find attendance data elements. Found spans: {span_info}")
        
        total_period_text = total_period_element.get_text(strip=True)
        not_applicable_text = not_applicable_element.get_text(strip=True)
        
        print(f"Total period text: {total_period_text}")
        print(f"Not applicable text: {not_applicable_text}")
        
        # Extract numbers from text like "Total Period : 50"
        total = 0
        not_applicable = 0
        
        if ':' in total_period_text:
            try:
                total = int(total_period_text.split(':')[1].strip())
            except (ValueError, IndexError):
                print(f"Could not parse total from: {total_period_text}")
        
        if ':' in not_applicable_text:
            try:
                not_applicable = int(not_applicable_text.split(':')[1].strip())
            except (ValueError, IndexError):
                print(f"Could not parse not_applicable from: {not_applicable_text}")
        
        total_rows = total + not_applicable
        print(f"Total rows to process: {total_rows}")
        
        # Find attendance table
        tables = soup.find_all('table')
        print(f"Found {len(tables)} tables")
        
        attendance_table = None
        for i, table in enumerate(tables):
            rows = table.find_all('tr')
            print(f"Table {i}: {len(rows)} rows")
            if len(rows) > 20:  # Look for table with significant rows
                attendance_table = table
                print(f"Selected table {i} as attendance table")
                break
        
        if not attendance_table:
            # Use the largest table if none found with > 20 rows
            if tables:
                attendance_table = max(tables, key=lambda t: len(t.find_all('tr')))
                print(f"Using largest table with {len(attendance_table.find_all('tr'))} rows")
        
        if not attendance_table:
            raise Exception("Could not find any attendance table")
        
        rows = attendance_table.find_all('tr')
        forward = []
        backward = []
        
        print(f"Processing rows from index 24 to {min(24 + total_rows, len(rows))}")
        
        # Parse attendance data starting from row 24 (0-indexed)
        processed_rows = 0
        for i in range(24, min(24 + max(total_rows, 10), len(rows))):  # Process at least 10 rows for testing
            cells = rows[i].find_all('td')
            if len(cells) >= 5:
                date = cells[1].get_text(strip=True)
                subject_name = cells[3].get_text(strip=True)
                attendance_status = cells[4].get_text(strip=True)
                
                print(f"Row {i}: Date={date}, Subject={subject_name}, Status={attendance_status}")
                
                if date and subject_name:  # Only process if we have valid data
                    processed_rows += 1
                    # Create attendance object
                    attendance_object = {subject_name: attendance_status}
                    
                    # Check if this date already exists in forward array
                    existing_entry = None
                    for entry in forward:
                        if entry['date'] == date:
                            existing_entry = entry
                            break
                    
                    if existing_entry:
                        existing_entry['data'].append(attendance_object)
                    else:
                        forward.append({
                            'date': date,
                            'data': [attendance_object]
                        })
        
        print(f"Processed {processed_rows} valid rows")
        
        # If no data found, add default message
        if not forward:
            current_date = datetime.now()
            date_str = f"{current_date.day:02d} {current_date.strftime('%b')} {current_date.year}"
            forward.append({
                'date': date_str,
                'data': [{'Classes for this semester is yet to begin': ''}]
            })
        
        # Create backward array (reverse of forward)
        backward = forward[::-1]
        
        # Cache the successful response for 6 hours
        response_data = [forward, backward]
        set_cached_data(username, 'datewise', response_data)
        
        return DatewiseAttendanceResponse(
            success=True,
            message="Date-wise attendance retrieved successfully",
            data=response_data
        )
    
    except Exception as e:
        print(f"Error in dateWise endpoint: {e}")
        return DatewiseAttendanceResponse(
            success=False,
            message=f"Failed to retrieve date-wise attendance: {str(e)}",
            data=[]
        )

class TillDateAttendanceResponse(BaseModel):
    success: bool
    message: str
    data: list = None

@app.get("/getDateWiseAttendance")
async def get_tilldate_attendance(username: str, password: str, institution_type: str = "college"):
    """
    Get till-date attendance
    Uses 6-hour caching to optimize Heroku dyno usage
    """
    try:
        # Check if we have cached data that's less than 6 hours old
        cached_data = get_cached_data(username, 'tilldate')
        if cached_data:
            return TillDateAttendanceResponse(
                success=True,
                message="Till-date attendance retrieved from cache (less than 6 hours old)",
                data=cached_data
            )
        
        print(f"🔄 Fetching fresh till-date data for {username} - cache miss or expired")
        
        # Use common login function
        session, soup = await login_to_portal(username, password, institution_type)
        
        # Extract total period information
        total_period_element = soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_lbltotperiod'})
        not_applicable_element = soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_lbltotaln'})
        
        # If we can't find the specific elements, try alternative patterns
        if not total_period_element:
            total_period_element = soup.find('span', {'id': lambda x: x and 'lbltotperiod' in x}) or \
                                 soup.find('span', {'id': lambda x: x and 'totperiod' in x})
        
        if not not_applicable_element:
            not_applicable_element = soup.find('span', {'id': lambda x: x and 'lbltotaln' in x}) or \
                                   soup.find('span', {'id': lambda x: x and 'totaln' in x})
        
        if not total_period_element or not not_applicable_element:
            # Look for any elements with attendance-related text
            all_spans = soup.find_all('span')
            relevant_spans = []
            for span in all_spans:
                text = span.get_text(strip=True).lower()
                if any(keyword in text for keyword in ['total', 'period', 'lecture', 'attendance']):
                    relevant_spans.append({
                        'id': span.get('id', 'no-id'),
                        'text': span.get_text(strip=True)
                    })
            
            raise Exception(f"Could not find attendance data elements. Found relevant spans: {relevant_spans[:10]}")
        
        total_period_text = total_period_element.get_text(strip=True)
        not_applicable_text = not_applicable_element.get_text(strip=True)
        
        # Extract numbers from text like "Total Period : 50"
        total = 0
        not_applicable = 0
        
        if ':' in total_period_text:
            try:
                total = int(total_period_text.split(':')[1].strip())
            except (ValueError, IndexError):
                pass
        
        if ':' in not_applicable_text:
            try:
                not_applicable = int(not_applicable_text.split(':')[1].strip())
            except (ValueError, IndexError):
                pass
        
        total_rows = total + not_applicable
        
        # Find attendance table
        tables = soup.find_all('table')
        attendance_table = None
        for table in tables:
            rows = table.find_all('tr')
            if len(rows) > 20:  # Look for table with significant rows
                attendance_table = table
                break
        
        if not attendance_table:
            # Use the largest table if none found
            if tables:
                attendance_table = max(tables, key=lambda t: len(t.find_all('tr')))
        
        if not attendance_table:
            raise Exception("Could not find attendance table")
        
        rows = attendance_table.find_all('tr')
        temp = []
        total_lectures = 0
        present = 0
        
        # Parse attendance data starting from row 24 (0-indexed)
        for i in range(24, min(24 + max(total_rows, 10), len(rows))):  # Process at least 10 rows for testing
            cells = rows[i].find_all('td')
            if len(cells) >= 5:
                date = cells[1].get_text(strip=True)
                attendance_status = cells[4].get_text(strip=True)
                
                if date and attendance_status:  # Only process if we have valid data
                    # Convert attendance status to numeric (A=0, P=1)
                    attendance_value = 0 if attendance_status.upper() == 'A' else 1
                    present += attendance_value
                    total_lectures += 1
                    
                    # Check if this date already exists in temp array
                    existing_entry = None
                    for entry in temp:
                        if entry['date'] == date:
                            existing_entry = entry
                            break
                    
                    if not existing_entry:
                        # Calculate percentage with 2 decimal places
                        percentage = round((present * 100) / total_lectures, 2) if total_lectures > 0 else 100.0
                        temp.append({
                            'date': date,
                            'present': present,
                            'totalLectures': total_lectures,
                            'percentage': percentage
                        })
                    else:
                        # Update existing entry
                        percentage = round((present * 100) / total_lectures, 2) if total_lectures > 0 else 100.0
                        existing_entry.update({
                            'present': present,
                            'totalLectures': total_lectures,
                            'percentage': percentage
                        })
        
        # If no data found, add default entry
        if not temp:
            current_date = datetime.now()
            date_str = f"{current_date.day:02d} {current_date.strftime('%b')} {current_date.year}"
            temp.append({
                'date': date_str,
                'present': 0,
                'totalLectures': 0,
                'percentage': 100.0
            })
        
        # Cache the successful response for 6 hours
        set_cached_data(username, 'tilldate', temp)
        
        return TillDateAttendanceResponse(
            success=True,
            message="Till-date attendance retrieved successfully",
            data=temp
        )
    
    except Exception as e:
        print(f"Error in getDateWiseAttendance endpoint: {e}")
        return TillDateAttendanceResponse(
            success=False,
            message=f"Failed to retrieve till-date attendance: {str(e)}",
            data=[]
        )

@app.get("/")
async def root():
    return {"message": "College Attendance Scraper API is running"}

@app.get("/health")
async def health_check():
    cache_stats = {
        "attendance_cache_entries": len(attendance_cache),
        "datewise_cache_entries": len(datewise_cache),
        "tilldate_cache_entries": len(tilldate_cache),
        "cache_duration_hours": CACHE_DURATION_HOURS,
        "server_time": datetime.now().isoformat()
    }
    
    return {
        "status": "healthy", 
        "message": "API is running with 6-hour caching for Heroku optimization",
        "cache_info": cache_stats
    }

@app.post("/clear-cache")
async def clear_cache():
    """
    Clear all cached data (admin endpoint)
    """
    global attendance_cache, datewise_cache, tilldate_cache
    
    old_counts = {
        "attendance": len(attendance_cache),
        "datewise": len(datewise_cache),
        "tilldate": len(tilldate_cache)
    }
    
    attendance_cache.clear()
    datewise_cache.clear()
    tilldate_cache.clear()
    
    return {
        "success": True,
        "message": "All caches cleared successfully",
        "cleared_entries": old_counts
    }

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
