# Business Survival Project

This is the main project for my Undergrad Thesis. The current version of the research question
is: *How do the survival rates of the businesses correlate with their respective industries?*

# Structure

The project consists of:

- **/data/**: the repository with the main data about survival rates across the industries. For more information refer to [US Bureau of Labor Statistics](https://www.bls.gov/bdm/bdmage.htm#Information).
- `main.py`: the main script, which plots the business survival rates over time by establishment year. 
- `industries.py`: the script that plots average business survival rates over time by industry. 
- `README.md`: this is what you are reading right now.
- `requirements.txt`: self-explanatory.
- `.gitignore`: self-explanatory.

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

To check if any of the observations are statistically significant, we plan to use **ANOVA**
testing. 
