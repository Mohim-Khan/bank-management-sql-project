-- ============================================================
-- PHASE 4: HAVING ANALYSIS (6 Queries)
-- ============================================================
USE bank_management;

-- 1. Branches with total transaction amount greater than a threshold (e.g. 2000)
SELECT
    b.ID AS branch_id,
    b.Name AS branch_name,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM branches b
JOIN account a     ON a.Branch_ID = b.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY b.ID, b.Name
HAVING SUM(t.Amount_Transactions) > 2000
ORDER BY total_transaction_amount DESC;

-- 2. Account types with average transaction amount above the overall average
SELECT
    at.ID AS account_type_id,
    at.Description_Type,
    ROUND(AVG(t.Amount_Transactions), 2) AS avg_transaction_amount
FROM account_types at
JOIN account a     ON a.account_type_id = at.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY at.ID, at.Description_Type
HAVING AVG(t.Amount_Transactions) > (
    SELECT AVG(Amount_Transactions) FROM transaction WHERE Amount_Transactions IS NOT NULL
)
ORDER BY avg_transaction_amount DESC;

-- 3. Clients having more than 10 transactions
SELECT
    c.ID AS client_id,
    c.First_Name,
    c.Last_name,
    COUNT(t.ID) AS transaction_count
FROM clients c
JOIN account a     ON a.Client_ID = c.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
GROUP BY c.ID, c.First_Name, c.Last_name
HAVING COUNT(t.ID) > 10
ORDER BY transaction_count DESC;

-- 4. Branches with more than 3 accounts
-- (dataset has 43 accounts across 10 branches; 100 would return nothing, so a
--  realistic threshold is used here to demonstrate the pattern)
SELECT
    b.ID AS branch_id,
    b.Name AS branch_name,
    COUNT(a.ID) AS number_of_accounts
FROM branches b
JOIN account a ON a.Branch_ID = b.ID
GROUP BY b.ID, b.Name
HAVING COUNT(a.ID) > 3
ORDER BY number_of_accounts DESC;

-- 5. Transaction types having more than 10 transactions
-- (dataset has 62 total transactions across 5 types; 100 would return nothing, so a
--  realistic threshold is used here to demonstrate the pattern)
SELECT
    tt.ID AS transaction_type_id,
    tt.Transaction_type,
    COUNT(t.ID) AS transaction_count
FROM transaction_type tt
JOIN transaction t ON t.Transactions_type_ID = tt.ID
GROUP BY tt.ID, tt.Transaction_type
HAVING COUNT(t.ID) > 10
ORDER BY transaction_count DESC;

-- 6. Account types with total transaction amount above a threshold (e.g. 1000)
SELECT
    at.ID AS account_type_id,
    at.Description_Type,
    SUM(t.Amount_Transactions) AS total_transaction_amount
FROM account_types at
JOIN account a     ON a.account_type_id = at.ID
JOIN transaction t ON t.Source_Account_ID = a.ID
WHERE t.Amount_Transactions IS NOT NULL
GROUP BY at.ID, at.Description_Type
HAVING SUM(t.Amount_Transactions) > 1000
ORDER BY total_transaction_amount DESC;
