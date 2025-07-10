#!/bin/bash

# Script to start the Python backend for Class Attendance App

echo "Starting Class Attendance Backend..."
echo "========================================"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed"
    exit 1
fi

# Navigate to backend directory
cd backend

# Install requirements
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

# Start the server
echo "Starting FastAPI server..."
python3 main.py
