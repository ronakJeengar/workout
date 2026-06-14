# Metrics Specification - Workout Tracker V1.1

This document defines the key performance indicators (KPIs) used to monitor stability, user behavior, and retention post-launch of the Workout App.

---

## 1. Retention Metrics

### Day 1 (D1) Retention
* **Definition**: The percentage of unique users who return to the app and perform any interaction exactly 1 day (between 24 and 48 hours) after their first launch (Day 0).
* **Formula**: 
  $$\text{D1 Retention} = \frac{\text{Users active on Day 1}}{\text{Users who installed on Day 0}} \times 100$$
* **Target**: $> 60\%$

### Day 7 (D7) Retention
* **Definition**: The percentage of unique users who return to the app and perform any interaction exactly 7 days after their first launch (Day 0).
* **Formula**:
  $$\text{D7 Retention} = \frac{\text{Users active on Day 7}}{\text{Users who installed on Day 0}} \times 100$$
* **Target**: $> 30\%$

---

## 2. Stability Metrics

### Crash-Free Users %
* **Definition**: The percentage of unique active users who do not experience a critical application crash or state-level failure during a given period.
* **Formula**:
  $$\text{Crash-Free Users \%} = \frac{\text{Active Users} - \text{Users with } \ge 1 \text{ Crash}}{\text{Active Users}} \times 100$$
* **Target**: $\ge 99.5\%$

### Database schema integrity
* **Definition**: The proportion of database reads that load successfully without schema drift or file corruption.
* **Formula**:
  $$\text{Database Integrity \%} = \frac{\text{Successful DB transactions}}{\text{Total DB transactions}} \times 100$$
* **Target**: $100\%$ (achieved via silent watchdog recovery isolating anomalies)

---

## 3. Engagement Metrics

### Session Completion Rate
* **Definition**: The percentage of started workout sessions that are successfully completed (ended with summary screen) vs. abandoned (aborted midway).
* **Formula**:
  $$\text{Completion Rate} = \frac{\text{Completed Workout Sessions}}{\text{Started Workout Sessions}} \times 100$$
* **Target**: $> 80\%$

### Average Workouts / Week
* **Definition**: The average number of completed workouts logged per active user per week.
* **Formula**:
  $$\text{Avg Workouts/Week} = \frac{\text{Total Completed Sessions in last 7 Days}}{\text{Total Active Users in last 7 Days}}$$
* **Target**: $\ge 2.5$ workouts/week
