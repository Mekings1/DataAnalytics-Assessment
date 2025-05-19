# DataAnalytics-Assessment

## Question 1: High-Value Customers with Multiple Products
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

### Approach:
Filtered plans table using flags: is_regular_savings and is_a_fund to extract savings and investment transactions.
Used JOIN to connect users_customuser, savings_savingsaccount, and filtered_plan CTE to ensure only matching keys are returned hence actual transactions was completed.
Applied conditional aggregation using COUNT(CASE WHEN ...) to count the accurate number of savings and investments.

### Challenges:
Spent a lot of time looking at the tables and trying to understanding the database schema.
Absence of dictionary to help decide on how best to navigate the schema.
Ensuring the correct categorization of plan types.
Needed to include both plan type flags in the join condition to avoid duplicating or misclassifying transactions.


## Question 2: Transaction Frequency Analysis
Task: Calculate the average number of transactions per customer per month and categorize them:
"High Frequency" (≥10 transactions/month)
"Medium Frequency" (3-9 transactions/month)
"Low Frequency" (≤2 transactions/month)

### Approach:
Built separate CTEs for deposits and withdrawals, counting transactions per user per month.
Combined them with UNION ALL and calculated the average per user.
Used a CASE statement to classify frequency based on defined thresholds.

### Challenges:
Withdrawal table was not mentioned in the task hint so I spent a lot of time trying to justify why I need to bring it in.
Required alignment of deposit and withdrawal structures to unify via UNION ALL.
Needed to use AVG() correctly to avoid skewed results — had to group by customer and use consistent count logic.
Still trying to figure out if the AVG aggregate actually signify per user per month giving that all user are aggregated and counted as well.


## Question 3: Account Inactivity Alert

Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .


### Approach:

Created CTEs to tag plan types (Savings, Investments).
Filtered savings_savingsaccount for inflow records (confirmed_amount > 0).
Used MAX(transaction_date) to get last inflow date per account.
Calculated DATEDIFF(NOW(), last_transaction_date) to measure inactivity and filtered by > 365 days.

### Challenges:
Given the complexity of the database sometimes it challenge to decide as to what should really count in giving accurate results.
There is a high risk of misinterpreting what the expected output should be.

## Overall challenges
Time Constraints hence I am stopping at Question 3
Unfamiliarity with database schema
Minimal knowledge on how to measure query performance
