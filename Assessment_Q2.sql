-- Get monthly deposit counts per user
WITH transaction_monthly_deposits AS (
    SELECT 
        c.id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS month,
        COUNT(*) AS monthly_transaction
    FROM adashi_staging.users_customuser c
    JOIN adashi_staging.savings_savingsaccount s
        ON c.id = s.owner_id
    WHERE s.confirmed_amount > 0
    GROUP BY c.id, DATE_FORMAT(s.transaction_date, '%Y-%m')
),

-- Get monthly withdrawal counts per user
transaction_monthly_withdrawal AS (
    SELECT 
        c.id,
        DATE_FORMAT(w.transaction_date, '%Y-%m') AS month,
        COUNT(*) AS monthly_transaction
    FROM adashi_staging.users_customuser c
    JOIN adashi_staging.withdrawals_withdrawal w
        ON c.id = w.owner_id
    WHERE w.amount_withdrawn > 0
    GROUP BY c.id, DATE_FORMAT(w.transaction_date, '%Y-%m')
),

-- Combine both deposit and withdrawal transactions
full_transactions AS (
    SELECT * FROM transaction_monthly_deposits
    UNION ALL
    SELECT * FROM transaction_monthly_withdrawal
),

-- Compute average transactions per month per customer and categorize frequency
average_monthly_transactions AS (
    SELECT 
        id,
        AVG(monthly_transaction) AS avg_txns_per_month,
        CASE 
            WHEN AVG(monthly_transaction) >= 10 THEN 'High Frequency'
            WHEN AVG(monthly_transaction) >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM full_transactions
    GROUP BY id
)

-- Final output: frequency category, number of users, and average transactions
SELECT 
    frequency_category, 
    COUNT(*) AS customer_count, 
    ROUND(AVG(avg_txns_per_month), 1) AS avg_transactions_per_month
FROM average_monthly_transactions
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

