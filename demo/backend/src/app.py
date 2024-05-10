from flask import Flask
from database import create_connection

app = Flask(__name__)

DATABASE = 'pythonsqlite.db'

@app.route('/')
def home():
    # Connect to the database
    conn = create_connection(DATABASE)
    if conn:
        # Perform database operations, for example, querying
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM projects")
        projects = cursor.fetchall()
        conn.close()  # Close the database connection
        return f"Projects in the database: {projects}"
    else:
        return "Error! cannot connect to the database."

if __name__ == '__main__':
    app.run(debug=True)
