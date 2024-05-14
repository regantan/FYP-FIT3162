import unittest
import numpy as np
from decimal import Decimal
import sys
import os

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

class TestSimilarityCalculations(unittest.TestCase):

    def setUp(self):
        pass
    
    def test_cosine_similarity_zero_vectors(self):
        vec1 = np.array([0, 0])
        vec2 = np.array([0, 0])
        self.assertEqual(float(cosine_similarity(vec1, vec2)), 0.0)

    def test_cosine_similarity_perpendicular_vectors(self):
        vec1 = np.array([1, 0])
        vec2 = np.array([0, 1])
        self.assertEqual(float(cosine_similarity(vec1, vec2)), 0.0)

    def test_cosine_similarity_same_vectors(self):
        vec1 = np.array([1, 1])
        vec2 = np.array([1, 1])
        self.assertEqual(float(round(cosine_similarity(vec1, vec2))), 1.0)

    def test_cuisine_similarity_no_overlap(self):
        cuisines1 = ['Italian']
        cuisines2 = ['Chinese']
        self.assertEqual(cuisine_similarity(cuisines1, cuisines2), 0)

    def test_cuisine_similarity_complete_overlap(self):
        cuisines1 = ['Italian', 'Mexican']
        cuisines2 = ['Italian', 'Mexican']
        self.assertEqual(cuisine_similarity(cuisines1, cuisines2), 1)

    def test_compute_similarities(self):
        aspect_scores = {
            'Restaurant1': {'scores': {'Food': 3, 'Service': 5}, 'cuisines': ['Italian'], 'location': 'NYC'},
            'Restaurant2': {'scores': {'Food': 3, 'Service': 4}, 'cuisines': ['Italian', 'Mexican'], 'location': 'NYC'},
            'Restaurant3': {'scores': {'Food': 2, 'Service': 1}, 'cuisines': ['Chinese'], 'location': 'SF'}
        }
        similarities = compute_similarities(aspect_scores)
        self.assertIn('Restaurant2', [sim[0] for sim in similarities['Restaurant1']])
        self.assertTrue(all(sim[0] != 'Restaurant3' for sim in similarities['Restaurant1']))  # No SF restaurants should be compared with NYC

def run_test():
    unittest.main(argv=[''], defaultTest='TestSimilarityCalculations', exit=False)

run_test()