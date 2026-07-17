-- ============================================================
-- PHASE 3: TRANSACTION ANALYSIS (6 Queries)
-- ============================================================
USE bank_management;

-- 1. Top 10 highest transactions
SELECT
    t.ID,
    t.Amount_Transactions,
    t.Date_issued,
    tt.Transaction_type,
    t.Source_Account_ID,
    t.Destination_Account_ID
FROM transaction t
JOIN transaction_type tt ON tt.ID = t.Transactions_type_ID
WHERE t.Amount_Transactions IS NOT NULL
ORDER BY t.Amount_Transactions DESC
LIMIT 10;

-- 2. Top branches by transaction amount
SELECT
    b.ID   AS branch_id,
    b.Name AS branch_name,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM branches b
JOIN account a     ON a.Branch_ID = b.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY b.ID, b.Name
ORDER BY total_transaction_amount DESC
LIMIT 5;

-- 3. Top account types by transaction amount
SELECT
    at.ID  AS account_type_id,
    at.Description_Type,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM account_types at
JOIN account a     ON a.account_type_id = at.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY at.ID, at.Description_Type
ORDER BY total_transaction_amount DESC
LIMIT 5;

-- 4. Top clients by transaction amount
SELECT
    c.ID AS client_id,
    c.First_Name,
    c.Last_name,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM clients c
JOIN account a     ON a.Client_ID = c.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY c.ID, c.First_Name, c.Last_name
ORDER BY total_transaction_amount DESC
LIMIT 10;

-- 5. Highest transaction accounts (accounts ranked by total outgoing transaction amount)
SELECT
    a.ID AS account_id,
    a.Client_ID,
    a.Branch_ID,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM account a
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY a.ID, a.Client_ID, a.Branch_ID
ORDER BY total_transaction_amount DESC
LIMIT 10;

-- 6. Transaction type distribution
SELECT
    tt.Transaction_type,
    COUNT(t.ID)                                        AS transaction_count,
    ROUND(100.0 * COUNT(t.ID) / (SELECT COUNT(*) FROM transaction), 2) AS pct_of_total
FROM transaction_type tt
LEFT JOIN transaction t ON t.Transactions_type_ID = tt.ID
GROUP BY tt.ID, tt.Transaction_type
ORDER BY transaction_count DESC;
