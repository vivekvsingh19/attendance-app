#!/usr/bin/env python3
"""
Debug script to test LNCT portal login with detailed inspection
"""
import requests
from bs4 import BeautifulSoup
import json

def debug_login_process():
    session = requests.Session()
    
    # Headers to mimic a real browser
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
    }
    
    print("=== STEP 1: Accessing Login Page ===")
    login_url = "https://portal.lnct.ac.in/Accsoft2/StudentLogin.aspx"
    
    try:
        response = session.get(login_url, headers=headers)
        print(f"Status Code: {response.status_code}")
        print(f"URL after redirect: {response.url}")
        print(f"Content Length: {len(response.text)}")
        
        # Parse HTML to find form elements
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Find all input fields
        print("\n=== FORM FIELDS FOUND ===")
        inputs = soup.find_all('input')
        for inp in inputs:
            input_type = inp.get('type', '')
            input_name = inp.get('name', '')
            input_value = inp.get('value', '')
            if input_name:
                print(f"Name: {input_name}, Type: {input_type}, Value: {input_value[:50] if input_value else 'None'}")
        
        # Find form action
        forms = soup.find_all('form')
        print(f"\n=== FORMS FOUND ({len(forms)}) ===")
        for i, form in enumerate(forms):
            action = form.get('action', '')
            method = form.get('method', '')
            print(f"Form {i+1}: Action='{action}', Method='{method}'")
        
        # Check if we can find specific student login fields
        student_username = soup.find('input', {'name': 'ctl00$cph1$txtStuUser'}) or \
                          soup.find('input', {'id': 'txtStuUser'}) or \
                          soup.find('input', {'name': 'txtStuUser'})
        
        student_password = soup.find('input', {'name': 'ctl00$cph1$txtStuPsw'}) or \
                          soup.find('input', {'id': 'txtStuPsw'}) or \
                          soup.find('input', {'name': 'txtStuPsw'})
        
        student_login_btn = soup.find('input', {'name': 'ctl00$cph1$btnStuLogin'}) or \
                           soup.find('input', {'id': 'btnStuLogin'}) or \
                           soup.find('input', {'name': 'btnStuLogin'})
        
        print(f"\n=== STUDENT LOGIN FIELDS ===")
        print(f"Username field found: {student_username is not None}")
        if student_username:
            print(f"  Name: {student_username.get('name')}")
            print(f"  ID: {student_username.get('id')}")
            
        print(f"Password field found: {student_password is not None}")
        if student_password:
            print(f"  Name: {student_password.get('name')}")
            print(f"  ID: {student_password.get('id')}")
            
        print(f"Login button found: {student_login_btn is not None}")
        if student_login_btn:
            print(f"  Name: {student_login_btn.get('name')}")
            print(f"  ID: {student_login_btn.get('id')}")
            print(f"  Value: {student_login_btn.get('value')}")
        
        # Get required hidden fields
        viewstate = soup.find('input', {'name': '__VIEWSTATE'})
        eventvalidation = soup.find('input', {'name': '__EVENTVALIDATION'})
        viewstategenerator = soup.find('input', {'name': '__VIEWSTATEGENERATOR'})
        
        print(f"\n=== ASP.NET HIDDEN FIELDS ===")
        print(f"__VIEWSTATE found: {viewstate is not None}")
        print(f"__EVENTVALIDATION found: {eventvalidation is not None}")
        print(f"__VIEWSTATEGENERATOR found: {viewstategenerator is not None}")
        
        # Save the page for manual inspection
        with open('/tmp/login_page_debug.html', 'w', encoding='utf-8') as f:
            f.write(response.text)
        print(f"\nLogin page saved to: /tmp/login_page_debug.html")
        
        # Check if there are any JavaScript requirements
        scripts = soup.find_all('script')
        print(f"\n=== JAVASCRIPT ANALYSIS ===")
        print(f"Total script tags found: {len(scripts)}")
        
        js_validation = False
        for script in scripts:
            if script.string and ('validation' in script.string.lower() or 'postback' in script.string.lower()):
                js_validation = True
                break
        
        print(f"Potential JS validation detected: {js_validation}")
        
        return {
            'success': True,
            'status_code': response.status_code,
            'url': response.url,
            'has_student_fields': all([student_username, student_password, student_login_btn]),
            'has_asp_fields': all([viewstate, eventvalidation]),
            'form_data': {
                'viewstate': viewstate['value'] if viewstate else None,
                'eventvalidation': eventvalidation['value'] if eventvalidation else None,
                'viewstategenerator': viewstategenerator['value'] if viewstategenerator else None,
            } if all([viewstate, eventvalidation]) else None
        }
        
    except Exception as e:
        print(f"Error accessing login page: {e}")
        return {'success': False, 'error': str(e)}

if __name__ == "__main__":
    result = debug_login_process()
    print(f"\n=== FINAL RESULT ===")
    print(json.dumps(result, indent=2))
