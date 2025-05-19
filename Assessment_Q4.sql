-- Step 1: Calculate the average profit per transaction for each customer
-- Profit per transaction is 0.1% (i.e., 0.001) of the transaction value
WITH avg_profit_per_txn AS (
    SELECT 
        c.id AS customer_id,
        AVG(0.001 * s.confirmed_amount) AS profit_per_txn
    FROM adashi_staging.users_customuser c 
    JOIN adashi_staging.savings_savingsaccount s
	ON c.id = s.owner_id AND s.confirmed_amount > 0 -- only consider confirmed inflow transactions
    GROUP BY c.id
)

-- Step 2: Calculate the CLV based on tenure and transaction frequency
SELECT 
    c.id AS customer_id,
    CONCAT(first_name, ' ', last_name) AS name,

    -- Tenure: number of months since the customer signed up
    TIMESTAMPDIFF(MONTH, c.date_joined, NOW()) AS tenure_months,

    -- Count of inflow transactions (not sum of amounts)
    COUNT(s.id) AS total_transactions,

    -- Estimated CLV using the formula:
    -- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_txn and finally * 0.01 to convert kobo to naira
    -- NULLIF to avoid division by zero in case tenure is 0
    ROUND(((COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, c.date_joined, NOW()), 0)) * 12 * ppt.profit_per_txn) * 0.01, 2) AS estimated_clv

FROM adashi_staging.users_customuser c 
JOIN adashi_staging.savings_savingsaccount s
    ON c.id = s.owner_id
    AND s.confirmed_amount > 0  -- only include confirmed inflow transactions
JOIN avg_profit_per_txn ppt
    ON c.id = ppt.customer_id

GROUP BY c.id, name, c.date_joined, ppt.profit_per_txn
ORDER BY estimated_clv DESC;
