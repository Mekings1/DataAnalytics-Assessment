-- Select regular savings plans
WITH savings_plan AS (
    SELECT id, 'Savings' AS type
    FROM adashi_staging.plans_plan
    WHERE is_regular_savings = 1
),

-- Select investment plans
investment_plan AS (
    SELECT id, 'Investments' AS type
    FROM adashi_staging.plans_plan
    WHERE is_a_fund = 1
),

-- Combine savings and investment plans
savings_and_investments AS (
    SELECT * FROM savings_plan
    UNION ALL
    SELECT * FROM investment_plan
),

-- Get the most recent inflow (confirmed_amount > 0) per user-plan combination
latest_inflows AS (
    SELECT 
        s.owner_id,
        s.plan_id,
        MAX(s.transaction_date) AS last_transaction_date
    FROM adashi_staging.savings_savingsaccount s
    WHERE s.confirmed_amount > 0  -- only inflows
    GROUP BY s.owner_id, s.plan_id
),

-- Join with plan type and compute days since last transaction
joined_with_type AS (
    SELECT 
        li.plan_id,
        li.owner_id,
        si.type,
        li.last_transaction_date,
        DATEDIFF(NOW(), li.last_transaction_date) AS inactivity_days
    FROM latest_inflows li
    JOIN savings_and_investments si
        ON li.plan_id = si.id
)

-- Final output: accounts inactive for more than 1 year
SELECT *
FROM joined_with_type
WHERE inactivity_days > 365
ORDER BY inactivity_days DESC;