-- ============================================================
-- PHASE 7: CTE ANALYSIS (5 Queries)
-- ============================================================
USE bank_management;

-- 1. Customer transaction summary
WITH customer_txns AS (
    SELECT
        c.ID AS client_id,
        c.First_Name,
        c.Last_name,
        a.ID AS account_id,
        t.Amount_Transactions
    FROM clients c
    JOIN account a     ON a.Client_ID = c.ID
    JOIN transaction t ON t.Source_Account_ID = a.ID
    WHERE t.Amount_Transactions IS NOT NULL
)
SELECT
    client_id,
    First_Name,
    Last_name,
    COUNT(*)                       AS total_transactions,
    COUNT(DISTINCT account_id)     AS accounts_used,
    SUM(Amount_Transactions)       AS total_amount,
    ROUND(AVG(Amount_Transactions), 2) AS avg_amount
FROM customer_txns
GROUP BY client_id, First_Name, Last_name
ORDER BY total_amount DESC;

-- 2. Branch performance summary
WITH branch_txns AS (
    SELECT
        b.ID AS branch_id,
        b.Name AS branch_name,
        a.ID AS account_id,
        t.ID AS transaction_id,
        t.Amount_Transactions
    FROM branches b
    JOIN account a     ON a.Branch_ID = b.ID
    LEFT JOIN transaction t ON t.Source_Account_ID = a.ID AND t.Amount_Transactions IS NOT NULL
)
SELECT
    branch_id,
    branch_name,
    COUNT(DISTINCT account_id)   AS total_accounts,
    COUNT(transaction_id)        AS total_transactions,
    COALESCE(SUM(Amount_Transactions), 0)      AS total_amount,
    ROUND(AVG(Amount_Transactions), 2)         AS avg_amount
FROM branch_txns
GROUP BY branch_id, branch_name
ORDER BY total_amount DESC;

-- 3. Account type summary
WITH type_txns AS (
    SELECT
        at.ID AS account_type_id,
        at.Description_Type,
        a.ID AS account_id,
        a.Balance_account,
        t.ID AS transaction_id,
        t.Amount_Transactions
    FROM account_types at
    JOIN account a     ON a.account_type_id = at.ID
    LEFT JOIN transaction t ON t.Source_Account_ID = a.ID AND t.Amount_Transactions IS NOT NULL
)
SELECT
    account_type_id,
    Description_Type,
    COUNT(DISTINCT account_id)          AS total_accounts,
    ROUND(AVG(Balance_account), 2)      AS avg_balance,
    COUNT(transaction_id)               AS total_transactions,
    COALESCE(SUM(Amount_Transactions), 0) AS total_transaction_amount
FROM type_txns
GROUP BY account_type_id, Description_Type
ORDER BY total_transaction_amount DESC;

-- 4. Monthly summary
WITH monthly AS (
    SELECT
        DATE_FORMAT(Date_issued, '%Y-%m') AS txn_month,
        Amount_Transactions
    FROM transaction
)
SELECT
    txn_month,
    COUNT(*)                                   AS transaction_count,
    COALESCE(SUM(Amount_Transactions), 0)      AS total_amount,
    ROUND(AVG(Amount_Transactions), 2)         AS avg_amount
FROM monthly
GROUP BY txn_month
ORDER BY txn_month;

-- 5. High-value customer summary (customers whose total spend is above the overall average)
WITH client_totals AS (
    SELECT
        c.ID AS client_id,
        c.First_Name,
        c.Last_name,
        SUM(t.Amount_Transactions) AS total_spent,
        COUNT(t.ID)                AS transaction_count
    FROM clients c
    JOIN account a     ON a.Client_ID = c.ID
    JOIN transaction t ON t.Source_Account_ID = a.ID
    WHERE t.Amount_Transactions IS NOT NULL
    GROUP BY c.ID, c.First_Name, c.Last_name
),
overall_avg AS (
    SELECT AVG(total_spent) AS avg_spent FROM client_totals
)
SELECT
    ct.client_id,
    ct.First_Name,
    ct.Last_name,
    ct.total_spent,
    ct.transaction_count
FROM client_totals ct
CROSS JOIN overall_avg oa
WHERE ct.total_spent > oa.avg_spent
ORDER BY ct.total_spent DESC;
