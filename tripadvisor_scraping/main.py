# %%
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter
from io import StringIO
import os
import pandas as pd
import re
import traceback

from joblib import Parallel, delayed, parallel_backend
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

from review_scrape import scrapeReview

# CLI arguments
parser = ArgumentParser(formatter_class=ArgumentDefaultsHelpFormatter)
parser.add_argument("-l", "--location", default="KL",
                    help="location to scrape")
args = vars(parser.parse_args())


def main(location):
    restaurants = pd.read_csv(f"data/Restaurants_{location}.csv")

    # sequential work
    error_restaurants = []

    # start driver
    # driver settings
    options = webdriver.ChromeOptions()
    options.add_argument("--lang=en")
    driver = webdriver.Chrome(service=Service(
        ChromeDriverManager().install()), options=options)


    for restaurant, url in zip(restaurants['Restaurant'], restaurants['url']):
        # --------------------------
        data = []
        orifile_path = f"data/reviews_all_{location}.csv"
        # inefficient, but more safe for generating files for every restaurant
        if not os.path.exists(orifile_path):
            # start from scratch
            json_string = '{"Author":{},"Title":{},"Review":{},"Rating":{},"Dates":{},"Restaurant":{}}'
            existingReviews = pd.read_json(StringIO(json_string))
        else:
            existingReviews = pd.read_csv(orifile_path)
            existingReviews.drop_duplicates(inplace=True)
        completedRestaurant = list(existingReviews["Restaurant"].unique())
        # replace " - CLOSED"
        completedRestaurant = list(
            map(lambda x: re.sub(" - CLOSED$", "", x), completedRestaurant))
        # --------------------

        if restaurant in completedRestaurant:
            print(f"skip {restaurant}")
            continue  # skip completed restaurant

        try:
            df = scrapeReview(url, driver, restaurant)
        except Exception as e:
            print(f"error on {restaurant}")
            print(traceback.format_exc())
            print(e)
            error_restaurants.append(restaurant)
            continue
        else:
            if not df.empty:
                data.append(df)
            df_final = pd.concat(data)
            existingReviews = pd.concat([existingReviews, df_final])
            existingReviews.drop_duplicates(inplace=True)
            existingReviews.to_csv(orifile_path, index=False)
    print("Done all Restaurant")


if __name__ == "__main__":
    location = args['location']
    main(location=location)

    # to run:, eg.
    # python main.py -l KL
    # python main.py -l Rome