import socket
from flask import Flask, redirect, url_for
from flask_mysqldb import MySQL
import os 
from dotenv import load_dotenv
from flask_restx import Api, Resource, fields
from flask import jsonify
from decimal import Decimal
from flask_cors import CORS


load_dotenv()  # This is the crucial part

app = Flask(__name__)
CORS(app)

api = Api(app, version='1.0', title='My API',
          description='A simple API', swagger_ui=True)

# Configure MySQL connection
app.config['MYSQL_HOST'] = os.getenv('MYSQL_HOST')
app.config['MYSQL_PORT'] = int(os.getenv('MYSQL_PORT', 3306))
app.config['MYSQL_USER'] = os.getenv('MYSQL_USER')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD')
app.config['MYSQL_DB'] = os.getenv('MYSQL_DB')

# Setup mysql
mysql = MySQL(app)

##### API models #####
recommended_restaurant_model = api.model('recommended_restaurant', {
    'id': fields.Integer(description='The unique identifier of a restaurant'),
    'restaurant_name': fields.String(required=True, description='Name of the restaurant'),
    'cuisine': fields.String(required=True, description='Type of cuisine offered'),
    'star_rating': fields.Float(description='Rating of the restaurant'),
    'no_reviews': fields.Float(description='Total number of reviews'),
    'trip_advisor_url': fields.String(description='TripAdvisor url')
})

restaurant_details_model = api.model('restaurant_details', {
    'id': fields.Integer(description='The unique identifier of a restaurant'),
    'restaurant_name': fields.String(required=True, description='Name of the restaurant'),
    'cuisine': fields.String(required=True, description='Type of cuisine offered'),
    'star_rating': fields.Float(description='Rating of the restaurant'),
    'no_reviews': fields.Float(description='Total number of reviews'),
    'trip_advisor_url': fields.String(description='TripAdvisor url')
})

##### API SECTION #####
@api.route('/api/number_of_restaurants/<string:location>')
class home(Resource):
    def get(self, location):
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM restaurant_info WHERE location = %s", (location,))

        total_restaurants = cursor.fetchone()[0]
        total_pages_of_restaurants = (total_restaurants + 9) // 10  # Calculating the number of pages, each page has 10 reviews
        
        cursor.close()
        return jsonify({'totalPagesOfRestaurants': total_pages_of_restaurants})

        

@api.route('/api/recommended_restaurants/<string:location>/<int:page>')
@api.doc(params={'location': 'The location for which to find restaurants'})
class recommended_restaurants(Resource):
    @api.marshal_list_with(recommended_restaurant_model)
    def get(self, location, page):
        per_page = 10
        offset = (page - 1) * per_page

        cursor = mysql.connection.cursor()
        cursor.execute("SELECT id, restaurant_name, cuisine, star_rating, no_reviews, url FROM restaurant_info WHERE location = %s LIMIT %s OFFSET %s", (location, per_page, offset))
        restaurants = cursor.fetchall()
        cursor.close()
        return [{'id': row[0], 'restaurant_name': row[1], 'cuisine': [cuisine.strip() for cuisine in row[2].split(',')], 'star_rating': row[3], 'no_reviews': row[4], 'trip_advisor_url' : row[5]} for row in restaurants]

# @api.route('/api/restaurant_details/<int:restaurant_id>')
# class restaurant_details(Resource):
#     def get(self,restaurant_id):
#         cursor = mysql.connection.cursor()
#         cursor.execute("SELECT id, restaurant_name, cuisine, star_rating, no_reviews, url FROM restaurant_info WHERE id = %s", (restaurant_id,))
#         row = cursor.fetchone()

#         # Fetch positivity for each aspect from quadruples
#         cursor.execute("""
#             SELECT category, AVG(CASE WHEN polarity = 'positive' THEN 1 ELSE 0 END) AS positivity
#             FROM quadruples
#             JOIN reviews ON quadruples.review_id = reviews.id
#             WHERE reviews.restaurant = %s
#             GROUP BY category
#         """, (row[1],))  # Assuming restaurant name is the link between tables
#         aspect_data = cursor.fetchall()

#         # Prepare aspects summary from the fetched data
#         aspects_summary = [
#             {'aspectName': aspect[0], 'positivity': round(aspect[1], 2)}
#             for aspect in aspect_data
#         ]

#         cursor.close()

#         # Prepare the response
#         if row:
#             restaurant = {
#                 'id': row[0],
#                 'restaurant_name': row[1],
#                 'cuisine': row[2],
#                 'star_rating': float(row[3]) if isinstance(row[3], Decimal) else row[3],
#                 'no_reviews': float(row[4]) if isinstance(row[4], Decimal) else row[4],
#                 'trip_advisor_url': row[5],
#                 'aspectsSummary': aspects_summary,
#                 'totalPagesOfReviews': 20  # Static value or calculated dynamically
#             }
#         else:
#             restaurant = {}
#         return jsonify(restaurant)
    

# @api.route('/api/restaurant_details/<int:restaurant_id>')
# class RestaurantDetails(Resource):
#     def get(self, restaurant_id):
#         cursor = mysql.connection.cursor()
#         cursor.execute("SELECT id, restaurant_name, cuisine, star_rating, no_reviews, url FROM restaurant_info WHERE id = %s", (restaurant_id,))
#         row = cursor.fetchone()

#         if row:
#             restaurant_name = row[1]  # Ensuring we have the restaurant name before querying aspects

#             # Fetch positivity for each aspect from quadruples
#             cursor.execute("""
#                 SELECT COALESCE(category, 'Uncategorized') AS category, AVG(CASE WHEN polarity = 'positive' THEN 1 ELSE 0 END) AS positivity
#                 FROM quadruples
#                 JOIN reviews ON quadruples.review_id = reviews.id
#                 WHERE reviews.restaurant = %s
#                 GROUP BY category
#             """, (restaurant_name,))
#             aspect_data = cursor.fetchall()

#             # Prepare aspects summary from the fetched data
#             aspects_summary = [
#                 {'aspectName': aspect[0], 'positivity': round(aspect[1], 2) if aspect[1] is not None else 0}
#                 for aspect in aspect_data
#             ]

#             # Close the cursor
#             cursor.close()

#             # Prepare the response
#             restaurant = {
#                 'id': row[0],
#                 'restaurant_name': row[1],
#                 'cuisine': row[2],
#                 'star_rating': float(row[3]) if isinstance(row[3], Decimal) else row[3],
#                 'no_reviews': float(row[4]) if isinstance(row[4], Decimal) else row[4],
#                 'trip_advisor_url': row[5],
#                 'aspectsSummary': aspects_summary,
#                 'totalPagesOfReviews': 20
#             }
#         else:
#             restaurant = {}
#             cursor.close()

#         return jsonify(restaurant)

@api.route('/api/restaurant_details/<int:restaurant_id>')
class RestaurantDetails(Resource):
    def get(self, restaurant_id):
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT id, restaurant_name, cuisine, star_rating, no_reviews, url, location FROM restaurant_info WHERE id = %s", (restaurant_id,))
        row = cursor.fetchone()

        if row:
            restaurant_name = row[1]  # Ensuring we have the restaurant name before querying aspects

            # Calculate total number of review pages
            cursor.execute("SELECT COUNT(*) FROM reviews WHERE restaurant = %s", (restaurant_name,))
            total_reviews = cursor.fetchone()[0]
            total_pages_of_reviews = (total_reviews + 9) // 10  # Calculating the number of pages, each page has 10 reviews

            # The average score of the aspects across multiple years

            # Fetch positivity for each aspect from quadruples
            cursor.execute("""
                SELECT
                IF(category = '' OR category IS NULL, 'Uncategorized', category) AS category,
                AVG(
                    CASE 
                        WHEN polarity = 'positive' THEN 1 
                        WHEN polarity = 'neutral' THEN 0 
                        WHEN polarity = 'negative' THEN -1 
                        ELSE NULL 
                    END
                ) AS average_polarity
                FROM quadruples
                JOIN reviews ON quadruples.review_id = reviews.id
                WHERE reviews.restaurant = %s
                GROUP BY category
            """, (restaurant_name,))
            aspect_data = cursor.fetchall()

            # Fetch average scores of aspects per year
            cursor.execute("""
                SELECT
                IF(category = '' OR category IS NULL, 'Uncategorized', category) AS category,
                YEAR(reviews.date) AS year,
                AVG(
                    CASE 
                        WHEN polarity = 'positive' THEN 1 
                        WHEN polarity = 'neutral' THEN 0 
                        WHEN polarity = 'negative' THEN -1 
                    END
                ) AS average_polarity
                FROM quadruples
                JOIN reviews ON quadruples.review_id = reviews.id
                WHERE reviews.restaurant = %s
                GROUP BY category, YEAR(reviews.date)
            """, (restaurant_name,))
            yearly_aspect_data = cursor.fetchall()

            # Prepare average scores of aspects per year for JSON output
            average_scores = {}
            for aspect in yearly_aspect_data:
                if aspect[0] not in average_scores:
                    average_scores[aspect[0]] = {
                        "aspect_name": aspect[0],
                        "years": [],
                        "average_polarity": []
                    }
                average_scores[aspect[0]]["years"].append(aspect[1])
                average_scores[aspect[0]]["average_polarity"].append(float(round(aspect[2], 2)))

            # Sorting years and syncing polarities
            for aspect, data in average_scores.items():
                years_and_polarities = sorted(zip(data["years"], data["average_polarity"]), key=lambda x: x[0])  # Sort by year
                data["years"], data["average_polarity"] = zip(*years_and_polarities)  # Unzip sorted tuples back to lists
            
            # Convert dict to list for JSON output
            average_scores_list = list(average_scores.values())

            # Prepare aspects summary from the fetched data
            aspects_summary = [
                {'aspectName': aspect[0], 'positivity': float(round(aspect[1], 2)) if aspect[1] is not None else 0}
                for aspect in aspect_data
            ]

            # Close the cursor
            cursor.close()

            # Prepare the response
            restaurant = {
                'id': row[0],
                'restaurant_name': row[1],
                'cuisine': [cuisine.strip() for cuisine in row[2].split(',')],
                'star_rating': float(row[3]) if isinstance(row[3], Decimal) else row[3],
                'no_reviews': float(row[4]) if isinstance(row[4], Decimal) else row[4],
                'trip_advisor_url': row[5],
                'aspectsSummary': aspects_summary,
                'totalPagesOfReviews': total_pages_of_reviews,
                'average_scores_by_year': average_scores_list,
                'location': row[6],
            }
        else:
            restaurant = {}
            cursor.close()

        return jsonify(restaurant)


@api.route('/api/reviews/<int:restaurant_id>/<int:page>')
class Reviews(Resource):
    def get(self, restaurant_id, page):
        per_page = 10
        offset = (page - 1) * per_page
        # Establish database connection
        # cursor = mysql.connection.cursor()
        # conn = mysql.connect()
        conn = mysql.connection
        cursor = conn.cursor()  # Use DictCursor here
        # cursor = mysql.connection.cursor(pymysql.cursors.DictCursor)  # Use DictCursor here


        # Query for basic restaurant information
        cursor.execute("SELECT star_rating, no_reviews, restaurant_name FROM restaurant_info WHERE id = %s", (restaurant_id,))
        restaurant_info = cursor.fetchone()
        if not restaurant_info:
            return {"error": "Restaurant not found"}, 404

        restaurant_name = restaurant_info[2] 

        # Query for reviews
        cursor.execute("""
            SELECT r.id AS reviewId, r.author AS reviewerName, r.date AS reviewDate, r.review AS reviewText
            FROM reviews r
            WHERE r.restaurant = %s
            LIMIT %s OFFSET %s
        """, (restaurant_name, per_page, offset))
        reviews_basic = cursor.fetchall()

        review_ids = [review[0] for review in reviews_basic]
        
        # Fetch aspects and polarities for these reviews if they exist
        if review_ids:
            cursor.execute("""
                SELECT q.review_id AS reviewId, q.category, 
                    CASE 
                        WHEN q.polarity = 'positive' THEN 1 
                        WHEN q.polarity = 'neutral' THEN 0 
                        WHEN q.polarity = 'negative' THEN -1 
                    ELSE NULL 
                    END AS polarity,
                    q.opinion,
                    q.aspect
                FROM quadruples q
                WHERE q.review_id IN (%s)
            """ % ','.join(['%s'] * len(review_ids)), tuple(review_ids))
            aspects_data = cursor.fetchall()
        else:
            aspects_data = []

        reviews = {}
        for row in reviews_basic:
            if row[0] not in reviews:
                reviews[row[0]] = {
                    'reviewId': row[0],
                    'reviewerName': row[1],
                    'reviewDate': row[2].strftime('%d/%m/%Y'),
                    'reviewText': row[3],
                    'aspectReviews': []
                }

        for aspect in aspects_data:
            if aspect[0] in reviews:
                reviews[aspect[0]]['aspectReviews'].append({
                    'categoryName': aspect[1],
                    'positivity': aspect[2],
                    'opinion': aspect[3],
                    'aspectTerm': aspect[4]
                })

        # Fetching total review counts from each star rating
        cursor.execute("""
            SELECT rating, COUNT(*) as count
            FROM reviews
            WHERE restaurant = %s
            GROUP BY rating
        """, (restaurant_name,))
        ratings_breakdown = cursor.fetchall()

        # Initialize counts for all star ratings from 1 to 5
        total_reviews_from_each_star = [0] * 5
        for row in ratings_breakdown:
            if 1 <= int(row[0]) <= 5:  # Ensure rating is within the expected range
                total_reviews_from_each_star[int(row[0]) - 1] = row[1]
        
        # total_reviews_from_each_star = {row[0]: row[1] for row in ratings_breakdown}

        # Closing the cursor and database connection
        cursor.close()

        # Constructing the final response
        response = {
            'restaurantId': restaurant_id,
            'rating': float(restaurant_info[0]),
            'totalReviews': int(restaurant_info[1]),
            'totalReviewsFromEachStar': total_reviews_from_each_star,
            'reviews': list(reviews.values())
        }
        return jsonify(response)


# @app.route('/api/similar_restaurants/<int:restaurant_id>')
# def similar_restaurants(restaurant_id):
#     cursor = mysql.connection.cursor()
#     # Implement your logic for finding similar restaurants, for example:
#     cursor.execute("SELECT * FROM restaurants WHERE category = (SELECT category FROM restaurants WHERE restaurantId = %s) AND restaurantId != %s", (restaurant_id, restaurant_id))
#     similar_restaurants = cursor.fetchall()
#     cursor.close()
#     return {'similar_restaurants': [dict(restaurant) for restaurant in similar_restaurants]}

def find_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]

if __name__ == '__main__':
    port = find_free_port()
    app.run(debug=True, host='0.0.0.0', port='8079')