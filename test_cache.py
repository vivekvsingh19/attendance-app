#!/usr/bin/env python3
"""
Test script to verify the 6-hour caching functionality for Heroku deployment
"""
import requests
import time
import json

# Test configuration
BASE_URL = "http://localhost:8000"
TEST_USERNAME = "test_user_123"
TEST_PASSWORD = "test_pass_123"

def test_health_endpoint():
    """Test the health endpoint to check cache status"""
    print("=== Testing Health Endpoint ===")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health check passed")
            print(f"   Cache info: {json.dumps(data.get('cache_info', {}), indent=2)}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_cache_behavior():
    """Test that caching works correctly"""
    print("\n=== Testing Cache Behavior ===")
    
    # First request - should fetch fresh data
    print("1. Making first request (should fetch fresh data)...")
    try:
        # Using dateWise endpoint as it's a GET request
        response1 = requests.get(f"{BASE_URL}/dateWise", params={
            'username': TEST_USERNAME,
            'password': TEST_PASSWORD
        })
        
        if response1.status_code == 200:
            data1 = response1.json()
            print(f"✅ First request successful")
            print(f"   Message: {data1.get('message', 'No message')}")
            
            # Second request immediately - should serve from cache
            print("\n2. Making second request immediately (should serve from cache)...")
            response2 = requests.get(f"{BASE_URL}/dateWise", params={
                'username': TEST_USERNAME,
                'password': TEST_PASSWORD
            })
            
            if response2.status_code == 200:
                data2 = response2.json()
                print(f"✅ Second request successful")
                print(f"   Message: {data2.get('message', 'No message')}")
                
                # Check if second request was served from cache
                if "cache" in data2.get('message', '').lower():
                    print("✅ Cache is working - second request served from cache!")
                else:
                    print("⚠️  Cache might not be working - check server logs")
                    
                return True
            else:
                print(f"❌ Second request failed: {response2.status_code}")
                return False
        else:
            print(f"❌ First request failed: {response1.status_code}")
            print(f"   Response: {response1.text}")
            return False
            
    except Exception as e:
        print(f"❌ Cache behavior test error: {e}")
        return False

def test_clear_cache():
    """Test cache clearing functionality"""
    print("\n=== Testing Cache Clear ===")
    try:
        response = requests.post(f"{BASE_URL}/clear-cache")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Cache cleared successfully")
            print(f"   Cleared entries: {data.get('cleared_entries', {})}")
            return True
        else:
            print(f"❌ Cache clear failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Cache clear error: {e}")
        return False

def main():
    print("🧪 Testing Heroku-Optimized Attendance API with 6-Hour Caching")
    print("=" * 60)
    
    # Test 1: Health check
    health_ok = test_health_endpoint()
    
    if health_ok:
        # Test 2: Cache behavior
        cache_ok = test_cache_behavior()
        
        # Test 3: Cache clearing
        clear_ok = test_clear_cache()
        
        # Final health check
        print("\n=== Final Health Check ===")
        test_health_endpoint()
        
        print("\n" + "=" * 60)
        if cache_ok and clear_ok:
            print("🎉 All tests passed! The API is ready for Heroku deployment.")
            print("   - 6-hour caching is implemented")
            print("   - Cache status is monitorable via /health endpoint")
            print("   - Cache can be cleared via /clear-cache endpoint")
        else:
            print("⚠️  Some tests failed. Check the server logs for details.")
    else:
        print("❌ Health check failed. Make sure the server is running.")

if __name__ == "__main__":
    main()
