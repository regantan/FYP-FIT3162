import requests
import unittest

class APITestCase(unittest.TestCase):
    base_url = "http://127.0.0.1:5000/api"  

    def test_get_restaurants(self):
        response = requests.get(f"{self.base_url}/recommended_restaurants/Rome/1")
        self.assertEqual(response.status_code, 200)  # Check if the request was successful
        restaurants = response.json()
        
        self.assertIsInstance(restaurants, list)  # Check if the response contains a list
        self.assertEqual(len(restaurants), 10)   # Check if the list is not empty
        self.assertIsInstance(restaurants[0], dict)   # Check if the list contains dictionaries
        
        # Check if the dictionary contains the expected keys of a restaurant
        self.assertIn("id", restaurants[0])
        self.assertIn("restaurant_name", restaurants[0])    
        self.assertIn("cuisine", restaurants[0])
        self.assertIn("star_rating", restaurants[0])
        self.assertIn("no_reviews", restaurants[0])
        self.assertIn("trip_advisor_url", restaurants[0])
        
        response2 = requests.get(f"{self.base_url}/recommended_restaurants/Rome/2")
        self.assertEqual(response2.status_code, 200)
        restaurants2 = response2.json()
        for i in range(10):
            self.assertNotEqual(restaurants[i], restaurants2[i])    # Check if the two pages of reviews in a restaurants are different

if __name__ == "__main__":
    unittest.main(argv=[''], defaultTest='APITestCase', exit=False)