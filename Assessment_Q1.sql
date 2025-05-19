-- Select all plan types that are either savings or investments
WITH filtered_plans AS (
    SELECT id, is_regular_savings, is_a_fund
    FROM adashi_staging.plans_plan
    WHERE is_regular_savings = 1 OR is_a_fund = 1
)

SELECT 
    c.id,
    CONCAT(first_name, ' ', last_name) AS name,

    -- Count number of savings plans for each customer
    COUNT(CASE WHEN p.is_regular_savings = 1 THEN 1 END) AS savings_count,

    -- Count number of investment plans for each customer
    COUNT(CASE WHEN p.is_a_fund = 1 THEN 1 END) AS investment_count,

    -- Total confirmed amount across all plans and converting from kobo to naira
    ROUND(SUM(s.confirmed_amount) * 0.01,2) AS total_amount

FROM adashi_staging.users_customuser AS c

-- Join to get user's savings/investment transactions
JOIN adashi_staging.savings_savingsaccount AS s
    ON c.id = s.owner_id

-- Join with filtered plans to limit to relevant plan types
JOIN filtered_plans AS p
    ON s.plan_id = p.id

GROUP BY 
    c.id, 
    CONCAT(first_name, ' ', last_name)

-- Only include users with both savings and investment plans
HAVING savings_count > 0 AND investment_count > 0

-- Sort by total amount in descending order
ORDER BY total_amount DESC;