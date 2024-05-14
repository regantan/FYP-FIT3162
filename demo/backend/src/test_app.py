import unittest
from flask_testing import TestCase
from your_flask_app_file import app, mysql  # Adjust the import according to your app structure
from unittest.mock import patch, MagicMock

class TestConfig:
    TESTING = True
    MYSQL_HOST = 'localhost'
    MYSQL_PORT = 3306
    MYSQL_USER = 'test'
    MYSQL_PASSWORD = 'test'
    MYSQL_DB = 'test_db'

class MyTests(TestCase):

    def create_app(self):
        app.config.from_object(TestConfig)
        return app

    def setUp(self):
        # Set up your testing environment before each test
        pass

    def tearDown(self):
        # Clean up after each test
        pass


    @patch('builtins.open', new_callable=unittest.mock.mock_open, read_data='b"{}"')
    @patch('pickle.load')
    @patch('your_flask_app_file.mysql.connection.cursor')
    def test_similar_restaurants_endpoint(self, mock_cursor, mock_pickle_load, mock_open):
        # Setup mock
        mock_cursor.return_value.__enter__.return_value.execute.return_value = None
        mock_cursor.return_value.__enter__.return_value.fetchone.return_value = ('Test Restaurant',)
        mock_pickle_load.return_value = {'Test Restaurant': [('Other Restaurant', 0.9)]}
        
        response = self.client.get('/api/similar_restaurants/1/1')
        self.assert200(response)
        self.assertIn('Other Restaurant', response.json[0]['restaurant_name'])

    @patch('your_flask_app_file.mysql.connection.cursor')
    def test_fetch_aspect_scores(self, mock_cursor):
        mock_cursor.return_value.__enter__.return_value.execute.return_value = None
        mock_cursor.return_value.__enter__.return_value.fetchall.return_value = [
            ('Restaurant', 'Italian', 'NYC', 'Food', 1.0)
        ]
        scores = fetch_aspect_scores()
        self.assertIsNotNone(scores)
        self.assertEqual(scores['Restaurant']['scores']['Food'], 1.0)

    def test_cosine_similarity(self):
        vec1 = np.array([1, 0])
        vec2 = np.array([0, 1])
        self.assertEqual(float(cosine_similarity(vec1, vec2)), 0.0)

if __name__ == '__main__':
    unittest.main()
