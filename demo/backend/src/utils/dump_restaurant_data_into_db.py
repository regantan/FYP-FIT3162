import csv
import json
import os
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

load_dotenv() 

def create_connection(host_name, user_name, user_password, db_name):
    connection = None
    try:
        connection = mysql.connector.connect(
            host=host_name,
            user=user_name,
            passwd=user_password,
            database=db_name
        )
        print("Connection to MySQL DB successful")
    except Error as e:
        print(f"The error '{e}' occurred")
    return connection

# def execute_query(connection, query):
#     cursor = connection.cursor()
#     try:
#         cursor.execute(query)
#         connection.commit()
#         print("Query executed successfully")
#     except Error as e:
#         print(f"The error '{e}' occurred")

def execute_query(connection, query, data):
    cursor = connection.cursor()
    try:
        cursor.execute(query, data)
        connection.commit()
        print("Query executed successfully")
    except Error as e:
        print(f"The error '{e}' occurred")

def import_csv_data(connection, file_path):
    with open(file_path, mode='r', encoding='utf-8') as file:
        csv_reader = csv.reader(file)
        next(csv_reader)  # Skip the header row
        for row in csv_reader:
            query = """
            INSERT INTO restaurant_info (restaurant_name, star_rating, no_reviews, cuisine, url, location)
            VALUES (%s, %s, %s, %s, %s, "Rome");
            """
            # Cleaning the number of reviews by removing commas
            no_reviews = int(row[2].replace(",", ""))
            data = (row[0], row[1], no_reviews, row[3], row[4])
            execute_query(connection, query, data)


def main():

    host = os.getenv('MYSQL_HOST')
    user = os.getenv('MYSQL_USER')
    password = os.getenv('MYSQL_PASSWORD')
    db_name = os.getenv('MYSQL_DB')

    if not all([host, user, password, db_name]):
        print("Database configuration is incomplete.")
        return

    connection = create_connection(host, user, password, db_name)

    if connection is None:
        print("Failed to connect to the database. Check credentials and try again.")
        return
    if connection is not None:
        # file_path = '/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/raw/Restaurants_KL.csv'  # Replace with the actual path to your CSV file
        file_path = '/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/raw/Restaurants_Rome.csv'
        import_csv_data(connection, file_path)

if __name__ == "__main__":
    main()
