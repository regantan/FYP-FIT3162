import unittest
from pyabsa import ABSAInstruction

# Copy into quadruplet_testing.ipynb to test
class OpinionTermTestCase(unittest.TestCase):
    def setUp(self):
        self.inputs = ["Parking was hard to find",
                      "The food is good",
                      "The service could be improved",
                      "Foods are delicious but service is normal",
                      "Yummy"]
        self.expected_aspects = ["hard to find", "good", "improved", "delicious", "Yummy"]
        self.generator = ABSAInstruction.ABSAGenerator("checkpoints/multitask/kevinscariaate_tk-instruct-base-def-pos-neg-neut-combined-instruction-instruction")


    def test_opinion_term(self):
        for sentence, expected_sentiment in zip(self.inputs, self.expected_aspects):
            with self.subTest(sentence=sentence):
                predicted_sentence = self.generator.predict(sentence)['Quadruples']
                predicted_data = [aspect['opinion'] for aspect in predicted_sentence]
                self.assertIn(expected_sentiment, predicted_data)



def run_test():
    unittest.main(argv = [''], defaultTest='OpinionTermTestCase', exit=False)

run_test()