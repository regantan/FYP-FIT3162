import numpy as np
import pandas as pd

# Function to perform stratified sampling based on ratings and then ensure restaurant diversity
def stratified_sampling(data, n_samples=1250):
    # Calculate the number of samples for each rating proportionally
    rating_counts = data['Rating'].value_counts(normalize=True) * n_samples
    rating_counts = rating_counts.round().astype(int)  # Ensure integer counts, sum might not be exactly 1250 due to rounding
    
    # Correct any rounding discrepancies by adjusting the largest category
    if rating_counts.sum() != n_samples:
        max_rating = rating_counts.idxmax()
        rating_counts[max_rating] += n_samples - rating_counts.sum()

    # Sample data according to calculated counts, ensuring random sampling within each rating category
    sampled_data = pd.DataFrame()  # Initialize an empty dataframe to hold sampled data
    for rating, count in rating_counts.items():
        sampled_reviews = data[data['Rating'] == rating].sample(n=count, random_state=42)
        sampled_data = pd.concat([sampled_data, sampled_reviews])

    # Shuffle the sampled data to mix ratings
    sampled_data = sampled_data.sample(frac=1, random_state=42).reset_index(drop=True)
    return sampled_data

def main():
    # Load the datasets
    reviews_kl = pd.read_csv('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/Reviews_KL.csv')
    reviews_rome = pd.read_csv('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/Reviews_Rome.csv')
    
    # Perform stratified sampling
    sampled_kl = stratified_sampling(reviews_kl)
    sampled_rome = stratified_sampling(reviews_rome)
    
    # Save the sampled data to CSV
    sampled_kl.to_csv('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/Sampled_Reviews_KL.csv', index=False)
    sampled_rome.to_csv('/Users/wongcheehao/Documents/Monash/FIT3162/FYP-FIT3162/dataset/Sampled_Reviews_Rome.csv', index=False)

    # Checking the final samples
    sampled_kl_info = sampled_kl.info()
    sampled_rome_info = sampled_rome.info()

    sampled_kl.head(), sampled_rome.head(), sampled_kl_info, sampled_rome_info

if __name__ == '__main__':
    main()