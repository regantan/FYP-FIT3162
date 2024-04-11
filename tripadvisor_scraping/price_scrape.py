import csv
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium_stealth import stealth
from bs4 import BeautifulSoup

# Function to extract price range from TripAdvisor page using BeautifulSoup
def extract_price_range(url):

    try:
        # Open the URL
        driver.get(url)

        # Get page source and create BeautifulSoup object
        response = BeautifulSoup(driver.page_source, 'html.parser')

        # Find and extract the price range
        
        price_range_element = response.find('a', class_="dlMOJ")
        if price_range_element:
            price_range = price_range_element.text.strip()
            return price_range
        else:
            return "N/A"
    except Exception as e:
        print(f"Error occurred while extracting price range: {e}")
        return "Error"

def has_price_range_column(filename):
    with open(filename, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile)
        header = next(reader)
        return 'price_range' in header

# Read CSV file and extract price range for each restaurant
input_file = 'data/Restaurants_KL_cleaned.csv'
output_file = 'data/Restaurants_KL_cleaned_price.csv'

if has_price_range_column(input_file):
    print("Price range column already exists in the CSV file.")
    exit()

# Read CSV file and extract price range for each restaurant
with open(input_file, 'r', newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    rows = list(reader)  # Read all rows at once

# Iterate over rows and update with price range information
for row in rows:
    restaurant_name = row['Restaurant']
    url = row['url']
    
    # Check if price range is already declared
    if 'price_range' in row and row['price_range']:
        print(f"Price range already exists for {restaurant_name}")
        continue
    
    # start driver
    # driver settings
    options = webdriver.ChromeOptions()
    options.add_argument("--lang=en")
    driver = webdriver.Chrome(service=Service(
        ChromeDriverManager().install()), options=options)
    
    # Selenium Stealth settings
    stealth(driver,
            languages=["en-US", "en"],
            vendor="Google Inc.",
            platform="Win32",
            webgl_vendor="Intel Inc.",
            renderer="Intel Iris OpenGL Engine",
            fix_hairline=True,
            )
    
     # Open the URL
    driver.get(url)

    # Get page source and create BeautifulSoup object
    response = BeautifulSoup(driver.page_source, 'html.parser')

    
    # Extract price range
    price_range = extract_price_range(url)
    
    # Update the row with price range information
    row['Price Range'] = price_range

driver.quit()

# Write updated information back to CSV file
with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ['Restaurant', 'star_rating', 'no_reviews', 'cuisine', 'price_range', 'URL']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    
    writer.writeheader()
    writer.writerows(rows)

print("CSV file updated with price range information.")
