# Business Survival Project

This is the main project for my Undergrad Thesis. The current version of the research question
is: *How do the survival rates of the businesses correlate with their respective industries?*

# Structure

The project consists of:

- **/data/**: the repository with the main data about survival rates across the industries. For more information refer to [US Bureau of Labor Statistics](https://www.bls.gov/bdm/bdmage.htm#Information).
- `main.py`: the main script, which plots the business survival rates over time by establishment year. 
- `industries.py`: the script that plots average business survival rates over time by industry. It also produces *averages.csv* and *processed_data.csv* for later use.
- `stats.py`: the main script for statistical analysis. It does two jobs: does the LMM, and Likelihood Ratio Test.
- `README.md`: this is what you are reading right now.
- `requirements.txt`: self-explanatory.
- `.gitignore`: self-explanatory.
- `processed_data.csv`: this is the first dataframe saved in a form of a csv. It has all the industries and all the years.
- `averages.csv`: here we grouped the survival rates by industries and establishment years.  
- `stats.ipynb`: a Jupiter notebook that presents the coherent picture of the study in an organized manner.

# Usage

Once you have python and an activated virtual environment, run:
```
pip install -r requirements.txt
```

Then just run either of the scripts:
```shell
python main.py
```

# Preliminary results

The graphs made by `main.py` and `industries.py` look like this:

[placeholder]

From the industries' graph we can make a couple of observations:
- *information* sector consistently has the lowest survival rates;
- *agriculture* sector has the highest survival rate in the first 10 years after a business establishment;
- *management* sector has the highest survival rate after the first 10 years after a business establishment;
- *utilities* sector has consistently one of the highest survival rates throughout the time frame.

## Methodology

To check if any of the observations are statistically significant, we plan to use **Mixed Effects** model with the
following specifications:

- Fixed Effects:
  - *Time*: To capture the trends over years.
- Random Effects:
  - *Industry Affiliation*: To assess overall differences between industries.

With this, the model can be specified as: 
$`\text{SurvivalRate}_{it} = \beta_0 + \beta_1 \cdot \text{Time}_t + u_i + \beta_3 \cdot (\text{Time}_t \times \text{Industry}_i) + \epsilon_{it}`$

Where:
- $`/beta_0`$: Overall intercept;
- $`/beta_1`$: Fixed effect of time;
- $`/beta_2`$: Random effect of industry;
- $`/beta_3`$: Interaction term between industry and time;
- $`/epsilon_{it}`$: Residual error term.

