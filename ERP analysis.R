# N100 Suppression in Schizophrenia
# Author: Fatima Jalap

# Dataset:
# EEG Data from Basic Sensory Task in Schizophrenia
# Source: Kaggle (Roach, 2019)

# Download the original dataset from Kaggle:
# [https://www.kaggle.com/datasets/broach/button-tone-sz/data?select=ERPdata.csv]

# Required files:
# - demographics.csv
# - erp.csv

#Load packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(afex)
library(emmeans)

# Set your working directory to the folder containing the CSV files.
demographics <- read.csv("demographics.csv")
erp <- read.csv("erp.csv")

#Checking data
dim(demographics)
names(demographics)
dim(erp)
names(erp)
#Range for time recorded
range(erp$time_ms)
#How many participants in each diagnosis group (0:contr, 1:schiz)
table(demographics$group)
#Gender distribution
table(demographics$gender)
#Age 
summary(demographics$age)

#Combining group and erp data
erp <- erp %>%
  left_join(
    demographics %>% select(subject, group),
    by = "subject"
  )

#Correct condition 1 using condition 3 (C1cor = C1-C3)
button_alone <- erp%>%
  filter(condition == 3) %>%
  select (
    subject, time_ms,
    Fz_button_alone = Fz, 
    FCz_button_alone = FCz, 
    Cz_button_alone = Cz
  )

erp_corrected <- erp %>%
  left_join(
    button_alone, 
    by = c("subject", "time_ms")
  ) %>%
  mutate(
    Fz=if_else (condition ==1, 
                Fz-Fz_button_alone, Fz), 
    FCz=if_else(condition == 1,
                FCz-FCz_button_alone, FCz), 
    Cz=if_else(condition == 1, 
               Cz-Cz_button_alone, Cz)
  )%>%
  select(
    subject, condition, Fz, FCz, Cz, time_ms, group
  )

#Keep measurements between 80-100ms for Fz
n100_data_fz <- erp_corrected %>% 
  filter(time_ms >= 80, time_ms <=100) %>%
  select(subject, group, condition, time_ms, Fz)

#N100 per participant and condition for Fz
n100_summary_fz <- n100_data_fz %>%
  group_by(subject, group, condition) %>%
  summarise(
    mean_n100 = mean(Fz, na.rm=TRUE),
    .groups ="drop"
  )

#N100 by condition and group for Fz
n100_con_summary_fz <- n100_summary_fz %>%
  group_by(group, condition) %>%
  summarise(
    mean_vol = mean(mean_n100, na.rm=TRUE), 
    sd_vol = sd(mean_n100, na.rm=TRUE),
    n=n(),
    .groups= "drop"
  )

#Keep measurements between 80-100ms for FCz
n100_data_fcz <- erp_corrected %>% 
  filter(time_ms >= 80, time_ms <=100) %>%
  select(subject, group, condition, time_ms, FCz)

#N100 per participant and condition for FCz
n100_summary_fcz <- n100_data_fcz %>%
  group_by(subject, group, condition) %>%
  summarise(
    mean_n100 = mean(FCz, na.rm=TRUE),
    .groups ="drop"
  )

#N100 by condition and group for FCz
n100_con_summary_fcz <- n100_summary_fcz %>%
  group_by(group, condition) %>%
  summarise(
    mean_vol = mean(mean_n100, na.rm=TRUE), 
    sd_vol = sd(mean_n100, na.rm=TRUE),
    n=n(),
    .groups= "drop"
  )

#Keep measurements between 80-100ms for Cz
n100_data_cz <- erp_corrected %>% 
  filter(time_ms >= 80, time_ms <=100) %>%
  select(subject, group, condition, time_ms, Cz)

#N100 per participant and condition for Cz
n100_summary_cz <- n100_data_cz %>%
  group_by(subject, group, condition) %>%
  summarise(
    mean_n100 = mean(Cz, na.rm=TRUE),
    .groups ="drop"
  )

#N100 by condition and group for Cz
n100_con_summary_cz <- n100_summary_cz %>%
  group_by(group, condition) %>%
  summarise(
    mean_vol = mean(mean_n100, na.rm=TRUE), 
    sd_vol = sd(mean_n100, na.rm=TRUE),
    n=n(),
    .groups= "drop"
  )

#exploring plots 
ggplot(n100_con_summary_cz, aes(x=condition, y=mean_vol)) + 
  geom_point() + 
  labs ( 
    title = "voltage by condition", 
    x = "Condition", 
    y= "Mean voltage"
  )

#Keep the 3 electrodes and relevant time window
erp_plot_data <- erp_corrected %>%
  filter(time_ms >=-200, time_ms <= 500) %>%
  select(subject, group, condition, time_ms, Fz, FCz, Cz) %>%
  pivot_longer(
    cols = c(Fz, FCz, Cz), 
    names_to = "electrode",
    values_to = "voltage"
  )

#Mean voltage at each time point
erp_waveform <- erp_plot_data %>%
  group_by(group, condition, electrode, time_ms) %>%
  summarise (
    mean_voltage = mean(voltage, na.rm=TRUE), 
    .groups = "drop"
    )

#Waveform woooooo
ggplot (
  erp_waveform, 
  aes (x=time_ms, y=mean_voltage, color=factor(condition))
)+
  geom_line(linewidth = 0.6)+
  geom_vline(xintercept=0, linetype="dashed", color="black")+
  geom_vline(xintercept=100, linetype="dashed", color ="black") +
  facet_grid(electrode~group)+
  labs(
    title = "ERP Wavefrom by Group, Condition and Electrode", 
    x = "Time (ms)", 
    y= "Mean voltage (µV)",
    color = "Condition"
  ) +
  theme_minimal()

# Combine participant level summaries of all three electrodes
n100_all <- bind_rows(
  n100_summary_fz %>% mutate(electrode = "Fz"),
  n100_summary_fcz %>% mutate(electrode = "FCz"),
  n100_summary_cz %>% mutate(electrode = "Cz")
)

# Calculate N100 suppression for each participant and electrode
suppression_all <- n100_all %>%
  filter(condition %in% c(1, 2)) %>%
  select(subject, group, electrode, condition, mean_n100) %>%
  pivot_wider(
    names_from = condition,
    values_from = mean_n100,
    names_prefix = "condition_"
  ) %>%
  mutate(
    suppression = condition_1 - condition_2
  )

# Convert group and electrode into factors
suppression_all <- suppression_all %>%
  mutate(
    group = factor(
      as.character(group),
      levels = c("0", "1"),
      labels = c("Control", "Schizophrenia")
    ),
    electrode = factor(
      electrode,
      levels = c("Fz", "FCz", "Cz")
    )
  )

# Check the data before statistical testing
table(suppression_all$group, suppression_all$electrode)

sum(is.na(suppression_all$group))
sum(is.na(suppression_all$suppression))

# Check each participant has one score per electrode
suppression_all %>%
  count(subject, electrode) %>%
  count(n)

#Statistical analysis 
model_suppression <- aov_ez(
  id = "subject",
  dv = "suppression",
  data = suppression_all,
  between = "group",
  within = "electrode",
  type = 3
)

nice(model_suppression)

#quantifying the group difference
group_comparison <- emmeans(model_suppression, ~group)
pairs(group_comparison, infer=c(TRUE, TRUE))

#calculate means and confidence intervals (95%)
figure_data <- suppression_all %>%
  group_by(group, electrode) %>%
  summarise (
    mean_suppression = mean(suppression, na.rm=TRUE), 
    sd= sd(suppression, na.rm=TRUE), 
    n= sum(!is.na(suppression)), 
    se= sd/sqrt(n), 
    ci=qt(0.975, df=n-1)*se, 
    .groups = "drop"
  )

#final figure
ggplot(
  figure_data, 
  aes(
    x=electrode, 
    y=mean_suppression, 
    colour = group, 
    group = group
  )
) +
  geom_line(linewidth = 0.7) +
  geom_point(size=3)+
  geom_errorbar(
    aes(
      ymin = mean_suppression - ci, 
      ymax = mean_suppression +ci
    ), 
    width = 0.12, 
    linewidth = 0.6
  ) +
  labs (
    title = "N100 Suppression by Group and Electrode", 
    x= "Electrode", 
    y= "N100 suppression (µV)", 
    colour = "Group"
  ) +
  theme_classic(base_size = 12)

appendix_stats <- suppression_all %>%
  group_by(group, electrode) %>%
  summarise(
    n = n(),
    Mean = mean(suppression, na.rm = TRUE),
    SD = sd(suppression, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Mean = round(Mean, 2),
    SD = round(SD, 2)
  )

appendix_stats