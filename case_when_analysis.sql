-- ============================================================
-- PHASE 6: CASE WHEN ANALYSIS (5 Queries)
-- ============================================================
USE bank_management;

-- 1. Categorize customers by activity (based on number of transactions made)
SELECT
    c.ID AS client_id,
    c.First_Name,
    c.Last_name,
    COUNT(t.ID) AS transaction_count,
    CASE
        WHEN COUNT(t.ID) = 0                     THEN 'Inactive'
        WHEN COUNT(t.ID) BETWEEN 1 AND 5         THEN 'Low Activity'
        WHEN COUNT(t.ID) BETWEEN 6 AND 15        THEN 'Moderate Activity'
        ELSE 'High Activity'
    END AS activity_level
FROM clients c
LEFT JOIN account a     ON a.Client_ID = c.ID
LEFT JOIN transaction t ON t.Source_Account_ID = a.ID
GROUP BY c.ID, c.First_Name, c.Last_name
ORDER BY transaction_count DESC;

-- 2. Categorize transaction amounts
SELECT
    ID,
    Amount_Transactions,
    CASE
        WHEN Amount_Transactions IS NULL          THEN 'Unknown'
        WHEN Amount_Transactions = 0               THEN 'Zero (Inquiry/Fee)'
        WHEN Amount_Transactions < 100              THEN 'Small'
        WHEN Amount_Transactions BETWEEN 100 AND 999 THEN 'Medium'
        ELSE 'Large'
    END AS amount_category
FROM transaction
ORDER BY Amount_Transactions DESC;

-- 3. Categorize branches by performance (based on total transaction amount)
SELECT
    b.ID AS branch_id,
    b.Name AS branch_name,
    SUM(t.Amount_Transactions) AS total_transaction_amount,
    CASE
        WHEN SUM(t.Amount_Transactions) IS NULL        THEN 'No Activity'
        WHEN SUM(t.Amount_Transactions) < 500           THEN 'Underperforming'
        WHEN SUM(t.Amount_Transactions) BETWEEN 500 AND 2000 THEN 'Average'
        ELSE 'Top Performing'
    END AS performance_category
FROM branches b
LEFT JOIN account a     ON a.Branch_ID = b.ID
LEFT JOIN transaction t ON t.Source_Account_ID = a.ID AND t.Amount_Transactions IS NOT NULL
GROUP BY b.ID, b.Name
ORDER BY total_transaction_amount DESC;

-- 4. Categorize account types (by average balance of accounts of that type)
SELECT
    at.ID AS account_type_id,
    at.Description_Type,
    ROUND(AVG(a.Balance_account), 2) AS avg_balance,
    CASE
        WHEN AVG(a.Balance_account) < 500                  THEN 'Basic Tier'
        WHEN AVG(a.Balance_account) BETWEEN 500 AND 2000    THEN 'Standard Tier'
        ELSE 'Premium Tier'
    END AS account_tier
FROM account_types at
JOIN account a ON a.account_type_id = at.ID
GROUP BY at.ID, at.Description_Type
ORDER BY avg_balance DESC;

-- 5. Categorize customers by spending (total outgoing transaction amount)
SELECT
    c.ID AS client_id,
    c.First_Name,
    c.Last_name,
    SUM(t.Amount_Transactions) AS total_spent,
    CASE
        WHEN SUM(t.Amount_Transactions) IS NULL           THEN 'No Spending'
        WHEN SUM(t.Amount_Transactions) < 500              THEN 'Low Spender'
        WHEN SUM(t.Amount_Transactions) BETWEEN 500 AND 2000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS spending_category
FROM clients c
LEFT JOIN account a     ON a.Client_ID = c.ID
LEFT JOIN transaction t ON t.Source_Account_ID = a.ID AND t.Amount_Transactions IS NOT NULL
GROUP BY c.ID, c.First_Name, c.Last_name
ORDER BY total_spent DESC;
