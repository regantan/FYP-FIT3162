import unittest


class MetricEvaluationTestCase(unittest.TestCase):
    def setUp(self):
        self.predictions_list = [
            [("food", "positive", "good", "FOOD#QUALITY"), ("service", "negative", "bad", "SERVICE#GENERAL")],
            [("food", "positive", "delicious", "FOOD#QUALITY")]
        ]
        self.ground_truth_list = [
            [("food", "positive", "delicious", "FOOD#QUALITY"), ("service", "negative", "poor", "SERVICE#GENERAL")],
            [("food", "positive", "tasty", "FOOD#QUALITY")]]

        self.predictions_list2 = [
            [(), ()],
            [()]
        ]
        self.ground_truth_list2 = [
            [(), ()],
            [()]


        ]

    def test_metric_evaluation(self):
        micro_evaluation = evaluate_aspect_and_sentiment_micro_macro(self.predictions_list, self.ground_truth_list)['Micro']
        macro_evaluation = evaluate_aspect_and_sentiment_micro_macro(self.predictions_list, self.ground_truth_list)['Macro']
        for performance in micro_evaluation:
            self.assertEqual(performance['Precision'],1.0)
            self.assertEqual(performance['Recall'], 1.0)
            self.assertEqual(performance['F1'], 1.0)

        for performance in macro_evaluation:
            self.assertEqual(performance['Precision'], 1.0)
            self.assertEqual(performance['Recall'], 1.0)
            self.assertEqual(performance['F1'], 1.0)

        micro_evaluation2 = evaluate_aspect_and_sentiment_micro_macro(self.predictions_list2, self.ground_truth_list2)['Micro']
        macro_evaluation2 = evaluate_aspect_and_sentiment_micro_macro(self.predictions_list2, self.ground_truth_list2)['Macro']
        for performance in micro_evaluation2:
            self.assertEqual(performance['Precision'], 0)
            self.assertEqual(performance['Recall'], 0)
            self.assertEqual(performance['F1'], 0)

        for performance in macro_evaluation2:
            self.assertEqual(performance['Precision'], 0)
            self.assertEqual(performance['Recall'], 0)
            self.assertEqual(performance['F1'], 0)


def run_test():
    unittest.main(argv=[''], defaultTest='MetricEvaluationTestCase', exit=False)


run_test()