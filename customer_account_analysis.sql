-- ============================================================
-- PHASE 2: CUSTOMER & ACCOUNT ANALYSIS (8 Queries)
-- ============================================================
USE bank_management;

-- 1. Number of accounts by account type
SELECT
    at.ID              AS account_type_id,
    at.Description_Type,
    COUNT(a.ID)        AS number_of_accounts
FROM account_types at
LEFT JOIN account a ON a.account_type_id = at.ID
GROUP BY at.ID, at.Description_Type
ORDER BY number_of_accounts DESC;

-- 2. Number of accounts by branch
SELECT
    b.ID          AS branch_id,
    b.Name        AS branch_name,
    COUNT(a.ID)   AS number_of_accounts
FROM branches b
LEFT JOIN account a ON a.Branch_ID = b.ID
GROUP BY b.ID, b.Name
ORDER BY number_of_accounts DESC;

-- 3. Number of clients by branch (distinct clients holding accounts at each branch)
SELECT
    b.ID                        AS branch_id,
    b.Name                      AS branch_name,
    COUNT(DISTINCT a.Client_ID) AS number_of_clients
FROM branches b
LEFT JOIN account a ON a.Branch_ID = b.ID
GROUP BY b.ID, b.Name
ORDER BY number_of_clients DESC;

-- 4. Average transaction amount by account type
SELECT
    at.ID    AS account_type_id,
    at.Description_Type,
    ROUND(AVG(t.Amount_Transactions), 2) AS avg_transaction_amount
FROM account_types at
JOIN account a       ON a.account_type_id = at.ID
JOIN transaction t   ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY at.ID, at.Description_Type
ORDER BY avg_transaction_amount DESC;

-- 5. Total transaction amount by branch
SELECT
    b.ID    AS branch_id,
    b.Name  AS branch_name,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM branches b
JOIN account a     ON a.Branch_ID = b.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY b.ID, b.Name
ORDER BY total_transaction_amount DESC;

-- 6. Total transaction amount by account type
SELECT
    at.ID   AS account_type_id,
    at.Description_Type,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM account_types at
JOIN account a     ON a.account_type_id = at.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY at.ID, at.Description_Type
ORDER BY total_transaction_amount DESC;

-- 7. Average transaction amount by branch
SELECT
    b.ID    AS branch_id,
    b.Name  AS branch_name,
    ROUND(AVG(t.Amount_Transactions), 2) AS avg_transaction_amount
FROM branches b
JOIN account a     ON a.Branch_ID = b.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY b.ID, b.Name
ORDER BY avg_transaction_amount DESC;

-- 8. Monthly transaction count
SELECT
    DATE_FORMAT(Date_issued, '%Y-%m') AS txn_month,
    COUNT(*)                          AS transaction_count
FROM transaction
GROUP BY DATE_FORMAT(Date_issued, '%Y-%m')
ORDER BY txn_month;
