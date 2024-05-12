import csv
import json
from pyabsa import ABSAInstruction

def predict_reviews(csv_file, model):
    predictions = []
    with open(csv_file, 'r', newline='', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        for row in reader:
            review_text = row['Review']
            result = model.predict(review_text)
            row['Quadruples'] = result['Quadruples']
            predictions.append(row)
    return predictions

if __name__ == "__main__":
    model = ABSAInstruction.ABSAGenerator("checkpoints/multitask/kevinscariaate_tk-instruct-base-def-pos-neg-neut-combined-instruction-instruction")

    csv_file = "dataset\cleaned_reviews\cleaned_reviews_ROME.csv"
    jsonl_file = "reviews_ROME.jsonl"

    predictions = predict_reviews(csv_file, model)

    with open(jsonl_file, 'w', encoding='utf-8') as file:
        for prediction in predictions:
            json.dump(prediction, file)
            file.write('\n')

    print("Predictions saved to:", jsonl_file)