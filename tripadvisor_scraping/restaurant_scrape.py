# %%
# for Trip Advisor
import os
import re
import time

from bs4 import BeautifulSoup
import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import (
    ElementClickInterceptedException,
    StaleElementReferenceException,
    TimeoutException,
)
from webdriver_manager.chrome import ChromeDriverManager

from selenium.webdriver.chrome.service import Service as ChromeService 
from selenium.webdriver.common.keys import Keys 
from selenium_stealth import stealth

from webdriver_manager.chrome import ChromeDriverManager 
import time


def scrapeRestaurant(url):
    """
    Scrape restaurant name and url.

    url : url of the trip advisor of the region.
    """
    def eachPageScrape(data):
        """
        Web scrape data in form of dictionary, into a list.

        data : list
        """
        response = BeautifulSoup(driver.page_source, 'html.parser')
        restaurants = response.find_all('div', class_='jhsNf')
        domain = "https://www.tripadvisor.com.my"
        
        lastNext = response.find('span', {'class': 'nav next disabled'})
        if lastNext:
            raise TimeoutException
        restaurants = restaurants[::2]
            # compile data
        for restaurant in restaurants:
            document = {}
            # print(restaurant)
            name = restaurant.find('div', class_='fiohW')
            document['Restaurant'] = name.text
            
            star_rating = restaurant.find('span', class_='Qqwyj').text
            match = re.search("(^[0-9]+\.[0-9]+)", star_rating)
            if match:
                document['star_rating'] = match.group(1)  # Access the captured group (rating value)
            else:   # No rating found
                document['star_rating'] = 'N/A'
                
            no_reviews = restaurant.find('span', class_='IiChw').text
            match_review = re.search("([0-9,]*)", no_reviews)
            if match_review:
                document['no_reviews'] = match_review.group(1)  # Access the captured group (number) and convert to integer
            else:
                document['no_reviews'] = 'N/A'
                
            cuisine = restaurant.find('div', class_='FGSTQ').find_all('span', class_='YECgr')[0].text
            match_cuisine = re.search("\$", cuisine)
            if match_cuisine:
                document['cuisine'] = 'N/A'
            else:
                document['cuisine'] = cuisine
                
            document['url'] = domain + name.find('a')['href']
            
            match_name = re.search("^[0-9]+\.\s.*", name.text)
            if match_name:
                data.append(document)
        

    # driver settings
    options = webdriver.ChromeOptions()
    options.add_argument("--lang=en")
    driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()), options=options)

    # Selenium Stealth settings
    stealth(driver,
            languages=["en-US", "en"],
            vendor="Google Inc.",
            platform="Win32",
            webgl_vendor="Intel Inc.",
            renderer="Intel Iris OpenGL Engine",
            fix_hairline=True,
            )

    # load url
    driver.implicitly_wait(2)
    driver.get(url)
    time.sleep(5)
    driver.set_page_load_timeout(2)  # seconds for time out

    # Scape Individual page
    data = []
    wait = WebDriverWait(driver, timeout=2)
    flag = True
    while len(data) < 550 and flag:
        try:  # from 1st page
            eachPageScrape(data)
            time.sleep(0.5)
            # driver.find_element(By.CSS_SELECTOR, '.BrOJK.u.j.z._F.wSSLS.tlqAi.unMkR').click()
            driver.find_elements(By.CSS_SELECTOR, '.UCacc')[-1].click()
            time.sleep(0.5)
            
        except ElementClickInterceptedException:  # until last page
                print("Element Click Intercepted")
        # except StaleElementReferenceException:
        #     try:  # redefine element
        #         print("StaleElementReferenceException")
        #         next_btn = wait.until(
        #             EC.element_to_be_clickable((By.LINK_TEXT, "Next")))
        #         next_btn.click()
        #     except ElementClickInterceptedException:  # until last page
        #         eachPageScrape(data)
        #         print("Done")
        #     except TimeoutException:
        #         print("Timeout")
        except TimeoutException:  # if only have 1 page
            if driver.find_elements(By.CSS_SELECTOR,'span.nav.next.disabled'):
                print("last page, done.")
        except Exception as e:  # other general execeptions
            print("Oh Shit")
            print("Something Went Wrong: ", e)
            flag = False
            
    # combine data into dataframe
    df = pd.DataFrame(data)
    # preprocessing
    # get name after number eg. 1. Grant Hatyai
    df = df[df['Restaurant'].str.contains("^[0-9]+\.\s.*")]
    
    df['Restaurant'] = df['Restaurant'].apply(
        lambda x: re.compile("(^[0-9]+\.\s)?(.*)").search(x).group(2))
    df = df.drop_duplicates(subset='Restaurant')

    driver.quit()
    return df


def main(url, location):
    filepath = f"data/Restaurants_{location}.csv"
    # skip files if already done.
    if os.path.exists(filepath):
        print(f"Skip {location}")
        return

    df = scrapeRestaurant(url)
    # df.drop_duplicates(inplace=True)
    df.to_csv(filepath, index=False)
    print(f"Done {location}")


# %%
if __name__ == "__main__":
    # url =
    urls = [
        # ("https://www.tripadvisor.com.my/Restaurants-g298570-Kuala_Lumpur_Wilayah_Persekutuan.html", 'KL'),
        # ("https://www.tripadvisor.com.my/Restaurants-g298278-Johor_Bahru_Johor_Bahru_District_Johor.html", 'JB'),
        # ("https://www.tripadvisor.com.my/Restaurants-g660694-Penang_Island_Penang.html", 'Penang'),
        ("https://www.tripadvisor.com/Restaurants-g187791-Rome_Lazio.html", 'Rome'),
        
        
        # https://www.tripadvisor.com/Restaurants-g187768-Italy.html ITALY
    ]
    for url, loc in urls:
        main(url, loc)


# %%