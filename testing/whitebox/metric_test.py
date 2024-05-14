import unittest


class MetricEvaluationTestCase(unittest.TestCase):
    def setUp(self):

        # all same except aspect
        self.predictions_list = [
            [("music", "positive", "good", "FOOD#QUALITY"), ("service", "negative", "bad", "SERVICE#GENERAL")],
            [("music", "positive", "delicious", "FOOD#QUALITY")]
        ]
        self.ground_truth_list = [
            [("food", "positive", "delicious", "FOOD#QUALITY"), ("service", "negative", "poor", "SERVICE#GENERAL")],
            [("food", "positive", "tasty", "FOOD#QUALITY")]]

        # all same except polarity
        self.predictions_list2 = [
            [("food", "negative", "good", "FOOD#QUALITY"), ("service", "negative", "bad", "SERVICE#GENERAL")],
            [("food", "negative", "delicious", "FOOD#QUALITY")]
        ]
        self.ground_truth_list2 = [
            [("food", "positive", "delicious", "FOOD#QUALITY"), ("service", "negative", "poor", "SERVICE#GENERAL")],
            [("food", "positive", "tasty", "FOOD#QUALITY")]]

        # all same except opinion
        self.predictions_list3 = [
            [("food", "positive", "plenty", "FOOD#QUALITY"), ("service", "negative", "bad", "SERVICE#GENERAL")],
            [("food", "positive", "plenty", "FOOD#QUALITY")]
        ]
        self.ground_truth_list3 = [
            [("food", "positive", "delicious", "FOOD#QUALITY"), ("service", "negative", "poor", "SERVICE#GENERAL")],
            [("food", "positive", "tasty", "FOOD#QUALITY")]]

        # all same except category
        self.predictions_list4 = [
            [("food", "positive", "good", "SERVICE#GENERAL"), ("service", "negative", "bad", "SERVICE#GENERAL")],
            [("food", "positive", "delicious", "SERVICE#GENERAL")]
        ]
        self.ground_truth_list4 = [
            [("food", "positive", "delicious", "FOOD#QUALITY"), ("service", "negative", "poor", "SERVICE#GENERAL")],
            [("food", "positive", "tasty", "FOOD#QUALITY")]]




    def test_metric_evaluation(self):
        evaluation = evaluate_aspect_polarity_opinion_category(self.predictions_list, self.ground_truth_list)
        evaluation2 = evaluate_aspect_polarity_opinion_category(self.predictions_list2, self.ground_truth_list2)
        evaluation3 = evaluate_aspect_polarity_opinion_category(self.predictions_list3, self.ground_truth_list3)
        evaluation4 = evaluate_aspect_polarity_opinion_category(self.predictions_list4, self.ground_truth_list4)
        print("First evaluation:", evaluation)
        print("Second evaluation:", evaluation2)
        print("Third evaluation:", evaluation3)
        print("Last evaluation:", evaluation4)
        
def run_test():
    unittest.main(argv=[''], defaultTest='MetricEvaluationTestCase', exit=False)


run_test()