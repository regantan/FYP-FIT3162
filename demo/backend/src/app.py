import socket
from flask import Flask
from flask_mysqldb import MySQL
import os 
from dotenv import load_dotenv

load_dotenv()  # This is the crucial part

app = Flask(__name__)

# Configure MySQL connection
app.config['MYSQL_HOST'] = os.getenv('MYSQL_HOST')
app.config['MYSQL_PORT'] = int(os.getenv('MYSQL_PORT', 3306))
app.config['MYSQL_USER'] = os.getenv('MYSQL_USER')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD')
app.config['MYSQL_DB'] = os.getenv('MYSQL_DB')

mysql = MySQL(app)

@app.route('/')
def home():
    print("Host:", os.getenv('MYSQL_HOST'))
    print("User:", os.getenv('MYSQL_USER'))
    print("Password:", os.getenv('MYSQL_PASSWORD'))
    print("Database:", os.getenv('MYSQL_DB'))

    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM restaurants")
    restaurants = cursor.fetchall()
    cursor.close()
    return {'restaurants': restaurants}

@app.route('/api/recommended_restaurants')
def recommended_restaurants():
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM restaurants WHERE recommended = 1")  # Assuming there's a 'recommended' flag in your table
    restaurants = cursor.fetchall()
    cursor.close()
    return {'restaurants': [dict(row) for row in restaurants]}

@app.route('/api/restaurant_details/<int:restaurant_id>')
def restaurant_details(restaurant_id):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM restaurants WHERE restaurantId = %s", (restaurant_id,))
    restaurant = cursor.fetchone()
    cursor.close()
    return {'restaurant': dict(restaurant) if restaurant else {}}

@app.route('/api/reviews/<int:restaurant_id>/<int:page>')
def reviews(restaurant_id, page):
    per_page = 10
    offset = (page - 1) * per_page
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT * FROM reviews WHERE restaurantId = %s LIMIT %s OFFSET %s", (restaurant_id, per_page, offset))
    reviews = cursor.fetchall()
    cursor.close()
    return {'reviews': [dict(review) for review in reviews]}

@app.route('/api/similar_restaurants/<int:restaurant_id>')
def similar_restaurants(restaurant_id):
    cursor = mysql.connection.cursor()
    # Implement your logic for finding similar restaurants, for example:
    cursor.execute("SELECT * FROM restaurants WHERE category = (SELECT category FROM restaurants WHERE restaurantId = %s) AND restaurantId != %s", (restaurant_id, restaurant_id))
    similar_restaurants = cursor.fetchall()
    cursor.close()
    return {'similar_restaurants': [dict(restaurant) for restaurant in similar_restaurants]}

def find_free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]

if __name__ == '__main__':
    port = find_free_port()
    app.run(debug=True, host='0.0.0.0', port=port)