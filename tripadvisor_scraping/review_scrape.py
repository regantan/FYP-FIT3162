from bs4 import BeautifulSoup
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import (
    ElementClickInterceptedException,
    TimeoutException,
    StaleElementReferenceException,
)
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium_stealth import stealth
import re
import time
import traceback

def scrapeReview(url, driver, restaurantName):
    "scrape the restaurant review, based on restaurant url."
    def eachPageScrape(data):
        """
        Web scrape data in form of dictionary, into a list.

        driver: selenium driver
        data : list
        """

        response = BeautifulSoup(driver.page_source, 'html.parser')

        # check if "more" present
        morebtn = response.find('span', {'class': 'taLnk ulBlueLinks'})
        if morebtn:
            if morebtn.text == "More":
                clickMore()
                # scrap the page again
                response = BeautifulSoup(driver.page_source, 'html.parser')

        reviewContainers = response.find_all(
            'div', {'class': 'review-container'})
        for reviewObj in reviewContainers:  # only get the first one
            author = reviewObj.find('div', class_="info_text pointer_cursor")
            title = reviewObj.find('a', class_="title")

            review = reviewObj.find(
                'div', class_="prw_rup prw_reviews_text_summary_hsx").text
            pattern = re.compile("Show less$")
            # Substitute the matched pattern with an empty string
            cleaned_review = re.sub(pattern, "", review)
            
            rating = reviewObj.find(
                'div', class_="prw_rup prw_reviews_review_resp")
            rating_date = reviewObj.find('span', class_="ratingDate")

        # compile data
        # for author, title, review, rating, rating_date in zip(authors, titles, reviews, ratings, rating_dates):
            document = {}
            document['Author'] = author.text
            document['Title'] = title.text
            document['Review'] = cleaned_review
            document['Rating'] = rating.find("span",
                                             class_="ui_bubble_rating")['class'][1].split('_')[1][0]
            document['Dates'] = rating_date.text
            data.append(document)

        # if only 1 page, check if have page numbers
        last_page = response.find('a', {'class': "nav next ui_button primary"})
        if last_page and last_page.has_attr('disabled'):
            # Only 1 page
            return False
        return True

    def clickMore():
        # click the "More button"
        result = None
        while result is None:
            try:  # keep trying until success
                wait.until(EC.element_to_be_clickable(
                    (By.CSS_SELECTOR, 'span.taLnk.ulBlueLinks'))).click()
                result = 1
                # wait until the "Show less" btn presence, before next step
                WebDriverWait(driver, 5).until(
                    EC.text_to_be_present_in_element(
                        (By.CSS_SELECTOR, 'span.taLnk.ulBlueLinks'), 'Show less')
                )
            except (StaleElementReferenceException, ElementClickInterceptedException):
                driver.refresh()
                pass
            except TimeoutException:
                result = 1
                pass
            except Exception:
                # for other unkown errors
                driver.refresh()
                pass

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
    driver.get(url)
    # driver.set_page_load_timeout(5) # seconds for time out

    # restaurantName
    response = BeautifulSoup(driver.page_source, 'html.parser')

    # Scape Individual page
    data = []
    wait = WebDriverWait(driver, 10)
    
    while len(data) <= 100:
        try:  # from 1st page
            x = eachPageScrape(data)
            if not x:
                print("No next page")
                break
            time.sleep(0.5)
            driver.find_elements(By.CSS_SELECTOR, '.nav.next.ui_button.primary')[0].click()
            time.sleep(0.5)
            
        except StaleElementReferenceException:
            try:  # redefine element
                driver.refresh()
                pass
            except ElementClickInterceptedException:  # until last page
                x = eachPageScrape(data)
                print("Done")
                # break
        except (TimeoutException, ElementClickInterceptedException):  # if only have 1 page
            if driver.find_elements(By.CSS_SELECTOR,'a.nav.next.ui_button.primary.disabled'):
                print("last page, done.")
                break
            driver.refresh()
            pass
        except Exception as e:
            # for unkwown errors     
            print(traceback.format_exc())       
            print(f"Having other error:\n{e}")
            # preserve the overall data
       
    print(len(data))         

    # combine data into dataframe
    df = pd.DataFrame(data)
    df['Restaurant'] = restaurantName

    return df


if __name__ == "__main__":
    options = webdriver.ChromeOptions()
    options.add_argument("--lang=en")
    driver = webdriver.Chrome(service=Service(
        ChromeDriverManager().install()), options=options)
    
    url = "https://www.tripadvisor.com.my/Restaurant_Review-g298570-d11947368-Reviews-or130-Canopy_Rooftop_Bar_and_Lounge-Kuala_Lumpur_Wilayah_Persekutuan.html"
    print(scrapeReview(url, driver))

    # timeout page
    # https://www.tripadvisor.com.my/Restaurant_Review-g298570-d11947368-Reviews-or540-Canopy_Rooftop_Bar_and_Lounge-Kuala_Lumpur_Wilayah_Persekutuan.html