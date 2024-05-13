import os
from dotenv import load_dotenv
import pandas as pd

# # Load JSONL file
# data = pd.read_json('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/Pyabsa/absa_model/reviews_KL.jsonl', lines=True)

# # Convert to CSV
# data.to_csv('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/Pyabsa/absa_model/reviews_KL.jsonl', index=False)


import json
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

def execute_query(connection, query):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        print("Query executed successfully")
    except Error as e:
        print(f"The error '{e}' occurred")

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
    # connection = create_connection(os.getenv('MYSQL_HOST'), os.getenv('MYSQL_USER'), os.getenv('MYSQL_PASSWORD'), os.getenv('MYSQL_DB'))

    # create_reviews_table = """
    # CREATE TABLE IF NOT EXISTS reviews (
    #     id INT AUTO_INCREMENT PRIMARY KEY,
    #     author VARCHAR(255),
    #     title TEXT,
    #     review TEXT,
    #     rating VARCHAR(10),
    #     date DATE,
    #     restaurant VARCHAR(255)
    # );
    # """

    # create_quadruples_table = """
    # CREATE TABLE IF NOT EXISTS quadruples (
    #     id INT AUTO_INCREMENT PRIMARY KEY,
    #     review_id INT,
    #     aspect VARCHAR(255),
    #     polarity VARCHAR(100),
    #     opinion TEXT,
    #     category VARCHAR(255),
    #     FOREIGN KEY (review_id) REFERENCES reviews(id)
    # );
    # """

    # execute_query(connection, create_reviews_table)
    # execute_query(connection, create_quadruples_table)

    cursor = connection.cursor(buffered=True)
    try:
        with open('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/predicted_reviews/reviews_ROME.jsonl', 'r') as file:
            for line in file:
                data = json.loads(line)
                
                # Check if the review already exists
                check_review_query = """
                SELECT 1 FROM reviews WHERE author = %s AND date = %s AND restaurant = %s;
                """
                cursor.execute(check_review_query, (data['Author'], data['Dates'], data['Restaurant']))
                if cursor.fetchone():
                    print(f"Review already exists for author {data['Author']} on {data['Dates']} at {data['Restaurant']}. Skipping insertion.")
                    continue  # Skip if review exists
                
                insert_review_query = """
                INSERT INTO reviews (author, title, review, rating, date, restaurant)
                VALUES (%s, %s, %s, %s, %s, %s);
                """
                review_data = (data['Author'], data['Title'], data['Review'], data['Rating'], data['Dates'], data['Restaurant'])
                cursor.execute(insert_review_query, review_data)
                print(f"Inserted review for author {data['Author']} on {data['Dates']} at {data['Restaurant']}.")
                
                review_id = cursor.lastrowid
                for quad in data['Quadruples']:
                    insert_quad_query = """
                    INSERT INTO quadruples (review_id, aspect, polarity, opinion, category)
                    VALUES (%s, %s, %s, %s, %s);
                    """
                    quad_data = (review_id, quad['aspect'], quad['polarity'], quad['opinion'], quad['category'])
                    cursor.execute(insert_quad_query, quad_data)
                    print(f"Inserted quadruple with aspect {quad['aspect']} and opinion {quad['opinion']}.")

                connection.commit()  # Commit after all inserts for a single review
    except Error as e:
        print("An error occurred:", e)
        connection.rollback()
    finally:
        cursor.close()
        connection.close()
    
if __name__ == "__main__":
    main()
