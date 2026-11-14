# N100-Schizophrenia-EEG
R analysis of auditory N100 suppression during self-generated tones in schizophrenia.

# Research Question
Does N100 suppression during self-generated tones differ between people with schizophrenia and healthy controls?

# Dataset
This project uses the publicly available dataset *EEG Data from Basic Sensory Task in Schizophrenia*, obtained from Kaggle (Roach, 2019).

The original dataset is licensed under CC BY-NC-SA 4.0. Please consult the original dataset page for its terms of use.

Participant-level data are not included in this repository.
URL for original dataset: https://www.kaggle.com/datasets/broach/button-tone-sz/data?select=ERPdata.csv

# Analysis
The analysis examines auditory event-related potentials (ERPs) at three electrode sites:
- Fz
- FCz
- Cz

N100 suppression is calculated within the 80–100 ms time window.
The analysis includes descriptive statistics, visualisations and a mixed-design analysis of variance (ANOVA) comparing diagnostic groups and electrode sites.

# Software
- R

# Repository Structure
- `ERP analysis.R` – R script for data processing and statistical analysis.
- `README.md` – Project overview and instructions.
- `LICENSE` – MIT licence for original code.

# Author
Fatima Jalap
