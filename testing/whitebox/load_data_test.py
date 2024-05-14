import unittest
import pandas as pd

class TestLoadData(unittest.TestCase):
    def test_csv_loading(self):
        csv_file = "C:/Users/regan/Documents/FYP-FIT3162/dataset/cleaned_reviews/cleaned_reviews_ROME.csv"

        chunksize = 100000
        df_list =[]

        for rows in pd.read_csv(csv_file, chunksize = chunksize):
            df_list.append(rows)

        df = pd.concat(df_list,axis = 0)

        self.assertEqual(df.shape,(31314, 6))

def run_test():
    unittest.main(argv=[''], defaultTest='TestLoadData', exit=False)


run_test()