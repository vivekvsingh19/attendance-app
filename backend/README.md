# College Attendance Scraper Backend

This is the Python FastAPI backend for scraping attendance data from the college portal.

## Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Run the server:
```bash
python main.py
```

The API will be available at `http://localhost:8000`

## API Endpoints

- `POST /login-and-fetch-attendance` - Login and fetch attendance data
- `GET /` - Root endpoint
- `GET /health` - Health check

## Usage

Send a POST request to `/login-and-fetch-attendance` with:
```json
{
  "college_id": "your_college_id",
  "password": "your_password"
}
```
