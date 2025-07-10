#!/usr/bin/env python3
"""
Quick script to test backend performance
"""
import time
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def test_backend_performance():
    """Test the backend login performance"""
    
    # Create optimized session like in the backend
    session = requests.Session()
    
    retry_strategy = Retry(
        total=3,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["HEAD", "GET", "OPTIONS", "POST"]
    )
    
    adapter = HTTPAdapter(
        pool_connections=100,
        pool_maxsize=100,
        max_retries=retry_strategy
    )
    
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    
    base_url = "http://localhost:8001"
    
    # Test health check
    print("Testing health check...")
    start_time = time.time()
    try:
        response = session.get(f"{base_url}/health", timeout=5)
        health_time = time.time() - start_time
        print(f"Health check: {response.status_code} - {health_time:.2f}s")
    except Exception as e:
        print(f"Health check failed: {e}")
        return
    
    # Test login (you can add test credentials here)
    print("\nLogin performance test - you can add test credentials to test actual login")
    print("The optimizations include:")
    print("1. Reduced timeouts from 10s to 5s")
    print("2. Better connection pooling")
    print("3. Cached URL discovery")
    print("4. Optimized HTTP client reuse")
    print("5. Better loading progress indicators")
    
    session.close()

if __name__ == "__main__":
    test_backend_performance()
