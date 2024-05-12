import socket
from flask import Flask, redirect, url_for
from flask_mysqldb import MySQL
import os 
from dotenv import load_dotenv
from flask_restx import Api, Resource, fields
from flask import jsonify
from decimal import Decimal
import pymysql.cursors


load_dotenv()  # This is the crucial part

app = Flask(__name__)
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
@api.route('/')
class home(Resource):
    def get(self):
        default_location = 'KL'  
        return redirect(url_for('recommended_restaurants', location=default_location))

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
        return [{'id': row[0], 'restaurant_name': row[1], 'cuisine': row[2], 'star_rating': row[3], 'no_reviews': row[4], 'trip_advisor_url' : row[5]} for row in restaurants]

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
        cursor.execute("SELECT id, restaurant_name, cuisine, star_rating, no_reviews, url FROM restaurant_info WHERE id = %s", (restaurant_id,))
        row = cursor.fetchone()

        if row:
            restaurant_name = row[1]  # Ensuring we have the restaurant name before querying aspects

            # Calculate total number of review pages
            cursor.execute("SELECT COUNT(*) FROM reviews WHERE restaurant = %s", (restaurant_name,))
            total_reviews = cursor.fetchone()[0]
            total_pages_of_reviews = (total_reviews + 9) // 10  # Calculating the number of pages, each page has 10 reviews

            # Fetch positivity for each aspect from quadruples
            cursor.execute("""
                SELECT COALESCE(category, 'Uncategorized') AS category, AVG(CASE WHEN polarity = 'positive' THEN 1 ELSE 0 END) AS positivity
                FROM quadruples
                JOIN reviews ON quadruples.review_id = reviews.id
                WHERE reviews.restaurant = %s
                GROUP BY category
            """, (restaurant_name,))
            aspect_data = cursor.fetchall()

            # Prepare aspects summary from the fetched data
            aspects_summary = [
                {'aspectName': aspect[0], 'positivity': round(aspect[1], 2) if aspect[1] is not None else 0}
                for aspect in aspect_data
            ]

            # Close the cursor
            cursor.close()

            # Prepare the response
            restaurant = {
                'id': row[0],
                'restaurant_name': row[1],
                'cuisine': row[2],
                'star_rating': float(row[3]) if isinstance(row[3], Decimal) else row[3],
                'no_reviews': float(row[4]) if isinstance(row[4], Decimal) else row[4],
                'trip_advisor_url': row[5],
                'aspectsSummary': aspects_summary,
                'totalPagesOfReviews': total_pages_of_reviews
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
        cursor.execute("SELECT star_rating, no_reviews FROM restaurant_info WHERE id = %s", (restaurant_id,))
        restaurant_info = cursor.fetchone()
        if not restaurant_info:
            return {"error": "Restaurant not found"}, 404

        # Query for reviews
        cursor.execute("""
            SELECT r.id AS reviewId, r.author AS reviewerName, r.date AS reviewDate, r.review AS reviewText,
            q.category, 
                CASE 
                    WHEN q.polarity = 'positive' THEN 1 
                    WHEN q.polarity = 'negative' THEN 0 
                    ELSE -1  -- Assuming you may want a default value for other cases
                END AS polarity,
            q.opinion
            FROM reviews r
            LEFT JOIN quadruples q ON r.id = q.review_id
            WHERE r.restaurant = %s
            LIMIT %s OFFSET %s
        """, (restaurant_id, per_page, offset))
        reviews_data = cursor.fetchall()

        # Organizing reviews by id to handle aspect reviews
        reviews = {}
        for row in reviews_data:
            if row[0] not in reviews:
                reviews[row[0]] = {
                    'reviewId': row[0],
                    'reviewerName': row[1],
                    'reviewDate': row[2],
                    'reviewText': row[3],
                    'aspectReviews': []
                }
            reviews[row[0]]['aspectReviews'].append({
                'categoryName': row[4],
                'positivity': row[5]
            })

        # Fetching total review counts from each star rating
        cursor.execute("""
            SELECT rating, COUNT(*) as count
            FROM reviews
            WHERE restaurant = %s
            GROUP BY rating
        """, (restaurant_id,))
        ratings_breakdown = cursor.fetchall()
        total_reviews_from_each_star = {row[0]: row[1] for row in ratings_breakdown}

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
    app.run(debug=True, host='0.0.0.0', port=port)