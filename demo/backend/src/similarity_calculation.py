import numpy as np
import pickle
from flask_mysqldb import MySQL
from flask import Flask
import os
from dotenv import load_dotenv
from decimal import Decimal

load_dotenv()

app = Flask(__name__)
# Configure MySQL connection
app.config['MYSQL_HOST'] = os.getenv('MYSQL_HOST')
app.config['MYSQL_PORT'] = int(os.getenv('MYSQL_PORT', 3306))
app.config['MYSQL_USER'] = os.getenv('MYSQL_USER')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD')
app.config['MYSQL_DB'] = os.getenv('MYSQL_DB')

mysql = MySQL(app)

def fetch_aspect_scores():
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT ri.restaurant_name, ri.cuisine, ri.location, q.category, AVG(
            CASE 
                WHEN q.polarity = 'positive' THEN 1 
                WHEN q.polarity = 'neutral' THEN 0 
                WHEN q.polarity = 'negative' THEN -1
            END) AS score
        FROM reviews r
        JOIN quadruples q ON r.id = q.review_id
        JOIN restaurant_info ri ON r.restaurant = ri.restaurant_name
        GROUP BY ri.restaurant_name, ri.cuisine, ri.location, q.category
    """)
    results = cursor.fetchall()
    cursor.close()

    aspect_scores = {}
    for result in results:
        restaurant = result[0]
        if restaurant not in aspect_scores:
            cuisines = result[1].split(',')
            location = result[2]
            aspect_scores[restaurant] = {
                'cuisines': cuisines,
                'location': location,
                'scores': {}
            }  
        aspect_scores[restaurant]['scores'][result[3]] = float(result[4] if result[4] is not None else 0)
    return aspect_scores

def cosine_similarity(vec1, vec2):
    dot_product = np.dot(vec1, vec2)
    norm_a = np.linalg.norm(vec1)
    norm_b = np.linalg.norm(vec2)
    if norm_a == 0 or norm_b == 0:
        return Decimal(0)  # Return 0 similarity if either vector is zero
    return Decimal( dot_product / (norm_a * norm_b))

def cuisine_similarity(cuisines1, cuisines2):
    # Compute similarity based on intersection of cuisine lists
    set1 = set(cuisines1)
    set2 = set(cuisines2)
    if not set1 or not set2:
        return 0  # Avoid division by zero
    return len(set1.intersection(set2)) / len(set1.union(set2))

def compute_similarities(aspect_scores):
    similarities = {}
    for restaurant_id, data in aspect_scores.items():
        scores = data['scores']
        cuisines = data['cuisines']
        location = data['location']
        similarities[restaurant_id] = []
        for other_id, other_data in aspect_scores.items():
            if restaurant_id != other_id and data['location'] == other_data['location']:  # Only compare restaurants in the same location
                other_scores = other_data['scores']
                other_cuisines = other_data['cuisines']

                # Calculating cuisine similarity
                cuisine_match = cuisine_similarity(cuisines, other_cuisines)

                # Creating vectors for cosine similarity
                categories = sorted(set(scores) | set(other_scores))

                vec1 = np.array([scores.get(cat, 0) for cat in categories])  # Filling missing values with 0
                vec2 = np.array([other_scores.get(cat, 0) for cat in categories])  # Similarly here

                # Calculate cosine similarity and adjust for cuisine match
                sim_score = float(cosine_similarity(vec1, vec2)) * (1 + cuisine_match)  # Adjusting the influence of cuisine similarity
                similarities[restaurant_id].append((other_id, sim_score))
                print(f"Comparing {restaurant_id} with {other_id}:")
                print(f"  Cuisine Similarity: {cuisine_match}")
                print(f"  Cosine Similarity: {cosine_similarity(vec1, vec2)}")
                print(f"  Adjusted Similarity Score: {sim_score}\n")

        # Sort based on similarity score
        similarities[restaurant_id].sort(key=lambda x: x[1], reverse=True)
    return similarities

def main():
    aspect_scores = fetch_aspect_scores()
    print("Aspect Scores:", aspect_scores)  # Print to verify content

    similarities = compute_similarities(aspect_scores)
    print("Similarities:", similarities)  # Print to verify content

    with open('similarities.pkl', 'wb') as f:
        pickle.dump(similarities, f)

    print("Data written to pickle file successfully.")

if __name__ == '__main__':
    with app.app_context():
        main()