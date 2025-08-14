import os
import re
import requests
from requests.auth import HTTPBasicAuth
import time
import sys
import urllib.parse
import getpass
from bs4 import BeautifulSoup

def authenticate_earthdata_session(session, username, password):
    """
    Authenticate with NASA Earthdata URS system
    """
    print("Authenticating with NASA Earthdata...")
    
    # Start with the URS login page
    login_url = "https://urs.earthdata.nasa.gov/home"
    
    try:
        # Get the login page
        response = session.get(login_url, timeout=30)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Find the login form
        login_form = soup.find('form', {'id': 'login'}) or soup.find('form', action=re.compile(r'.*login.*'))
        
        if not login_form:
            print("Could not find login form on NASA Earthdata page")
            return False
        
        # Extract form action URL
        form_action = login_form.get('action')
        if form_action:
            if form_action.startswith('/'):
                login_post_url = "https://urs.earthdata.nasa.gov" + form_action
            else:
                login_post_url = urllib.parse.urljoin(response.url, form_action)
        else:
            login_post_url = "https://urs.earthdata.nasa.gov/login"
        
        # Prepare login data
        login_data = {
            'username': username,
            'password': password
        }
        
        # Add any hidden form fields
        for hidden_input in login_form.find_all('input', type='hidden'):
            name = hidden_input.get('name')
            value = hidden_input.get('value')
            if name and value:
                login_data[name] = value
        
        # Submit login form
        login_response = session.post(login_post_url, data=login_data, allow_redirects=True, timeout=30)
        
        # Check if login was successful
        if "Invalid" in login_response.text or "error" in login_response.text.lower():
            print("Login failed - please check your credentials")
            return False
        
        # Additional verification - try to access profile page
        profile_response = session.get("https://urs.earthdata.nasa.gov/profile", timeout=30)
        if profile_response.status_code == 200 and "profile" in profile_response.text.lower():
            print("Authentication successful!")
            return True
        else:
            print("Authentication verification failed")
            return False
            
    except Exception as e:
        print(f"Authentication error: {str(e)}")
        return False

def download_with_auth_flow(session, url, filename, max_redirects=10):
    """
    Download file following NASA's authentication redirects
    """
    redirect_count = 0
    current_url = url
    
    while redirect_count < max_redirects:
        try:
            response = session.get(current_url, allow_redirects=False, timeout=120, stream=True)
            
            # If it's a redirect, follow it
            if response.status_code in [301, 302, 303, 307, 308]:
                redirect_count += 1
                current_url = response.headers.get('Location')
                if not current_url:
                    print(f"Redirect without location header")
                    return False
                
                # Make sure it's an absolute URL
                if current_url.startswith('/'):
                    parsed_original = urllib.parse.urlparse(url)
                    current_url = f"{parsed_original.scheme}://{parsed_original.netloc}{current_url}"
                
                continue
            
            # If we need to authenticate
            elif response.status_code == 401:
                print(f"Authentication required for {filename}")
                return False
            
            # If successful response
            elif response.status_code == 200:
                # Check content type to make sure it's the file we want
                content_type = response.headers.get('content-type', '').lower()
                
                # Save the file
                total_size = 0
                with open(filename, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
                            total_size += len(chunk)
                
                if total_size > 0:
                    print(f"Successfully downloaded: {filename} ({total_size} bytes)")
                    return True
                else:
                    print(f"Downloaded empty file: {filename}")
                    os.remove(filename)  # Remove empty file
                    return False
            
            else:
                print(f"Unexpected status code {response.status_code} for {filename}")
                return False
                
        except requests.exceptions.RequestException as e:
            print(f"Request error for {filename}: {str(e)}")
            return False
        except Exception as e:
            print(f"Unexpected error for {filename}: {str(e)}")
            return False
    
    print(f"Too many redirects for {filename}")
    return False

def download_opendap_files(input_file):
    # Get Earthdata credentials
    username = input("Enter your Earthdata username: ").strip()
    password = getpass.getpass("Enter your Earthdata password: ")
    
    # Create session for persistent connections
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    })
    
    # Authenticate with NASA Earthdata
    if not authenticate_earthdata_session(session, username, password):
        print("Failed to authenticate. Exiting.")
        return
    
    # Read the input file
    with open(input_file, 'r') as file:
        content = file.read()
    
    # Find all OpenDAP URLs
    opendap_urls = re.findall(r'https://opendap[^\s"\']+', content)
    
    if not opendap_urls:
        print("No OpenDAP URLs found in the file.")
        return
    
    print(f"Found {len(opendap_urls)} OpenDAP URLs to download")
    print("Files will be saved in: ", os.getcwd())
    
    # Download each file
    successful_downloads = 0
    failed_downloads = 0
    
    for i, url in enumerate(opendap_urls, 1):
        try:
            # Extract filename from URL
            parsed = urllib.parse.urlparse(url)
            filename = os.path.basename(parsed.path)
            
            # Clean filename (remove query string, replace special characters)
            if '?' in filename:
                filename = filename.split('?')[0]
            filename = filename.replace(':', '_').replace('%3A', '_')
            
            if not filename or filename == '/':
                filename = f"opendap_file_{i}.nc4"
            
            # Skip if file already exists
            if os.path.exists(filename):
                print(f"File exists, skipping: {filename}")
                continue
                
            print(f"Downloading ({i}/{len(opendap_urls)}): {filename}")
            
            # Download with authentication flow
            if download_with_auth_flow(session, url, filename):
                successful_downloads += 1
            else:
                failed_downloads += 1
            
            # Pause between downloads to be respectful to the server
            time.sleep(3)
            
        except Exception as e:
            print(f"Unexpected error processing {url}: {str(e)}")
            failed_downloads += 1
    
    print(f"\nDownload Summary:")
    print(f"Successful: {successful_downloads}")
    print(f"Failed: {failed_downloads}")
    print(f"Total: {len(opendap_urls)}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python nasa_downloader.py <input_file.txt>")
        print("Example: python nasa_downloader.py data_links.txt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    if not os.path.isfile(input_file):
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)
    
    # Check if BeautifulSoup is available
    try:
        from bs4 import BeautifulSoup
    except ImportError:
        print("Error: BeautifulSoup4 is required. Install it with: pip install beautifulsoup4")
        sys.exit(1)
    
    download_opendap_files(input_file)