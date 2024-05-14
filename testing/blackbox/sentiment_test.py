import unittest
from pyabsa import ABSAInstruction

# Copy into quadruplet_testing.ipynb to test
class SentimentPolarityTestCase(unittest.TestCase):
    def setUp(self):
        self.inputs = ["Parking was hard to find",
                       "The food is good",
                       "The service could be improved",
                       "Foods are delicious but service is normal",
                       "Yummy"]
        self.expected_sentiments = ["negative", "positive", "negative", "positive", "positive"]
        self.generator = ABSAInstruction.ABSAGenerator("checkpoints/multitask/kevinscariaate_tk-instruct-base-def-pos-neg-neut-combined-instruction-instruction")


    def test_sentiment_analysis(self):
        for sentence, expected_sentiment in zip(self.inputs, self.expected_sentiments):
            with self.subTest(sentence=sentence):
                predicted_sentence = self.generator.predict(sentence)['Quadruples']
                predicted_data = [aspect['polarity'] for aspect in predicted_sentence]
                self.assertIn(expected_sentiment, predicted_data)



def run_test():
    unittest.main(argv = [''], defaultTest='SentimentPolarityTestCase',  exit=False)

run_test()