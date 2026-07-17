-- ============================================================
-- PHASE 5: SUBQUERY ANALYSIS (8 Queries)
-- ============================================================
USE bank_management;

-- 1. Transactions above the average amount
SELECT ID, Amount_Transactions, Date_issued
FROM transaction
WHERE Amount_Transactions > (
    SELECT AVG(Amount_Transactions) FROM transaction WHERE Amount_Transactions IS NOT NULL
)
ORDER BY Amount_Transactions DESC;

-- 2. Highest transaction (full row, via subquery)
SELECT *
FROM transaction
WHERE Amount_Transactions = (
    SELECT MAX(Amount_Transactions) FROM transaction
);

-- 3. Lowest transaction (full row, via subquery; excludes NULL amounts)
SELECT *
FROM transaction
WHERE Amount_Transactions = (
    SELECT MIN(Amount_Transactions) FROM transaction WHERE Amount_Transactions IS NOT NULL
);

-- 4. Client with the highest total transaction amount
SELECT c.ID, c.First_Name, c.Last_name
FROM clients c
WHERE c.ID = (
    SELECT a.Client_ID
    FROM account a
    JOIN transaction t ON t.Source_Account_ID = a.ID
    WHERE t.Amount_Transactions IS NOT NULL
    GROUP BY a.Client_ID
    ORDER BY SUM(t.Amount_Transactions) DESC
    LIMIT 1
);

-- 5. Branch with the highest transaction volume (count of transactions)
SELECT b.ID, b.Name
FROM branches b
WHERE b.ID = (
    SELECT a.Branch_ID
    FROM account a
    JOIN transaction t ON t.Source_Account_ID = a.ID
    GROUP BY a.Branch_ID
    ORDER BY COUNT(t.ID) DESC
    LIMIT 1
);

-- 6. Account type with the highest total transaction amount
SELECT at.ID, at.Description_Type
FROM account_types at
WHERE at.ID = (
    SELECT a.account_type_id
    FROM account a
    JOIN transaction t ON t.Source_Account_ID = a.ID
    WHERE t.Amount_Transactions IS NOT NULL
    GROUP BY a.account_type_id
    ORDER BY SUM(t.Amount_Transactions) DESC
    LIMIT 1
);

-- 7. Clients spending (total outgoing transaction amount) above the average client spend
SELECT client_id, First_Name, Last_name, total_spent
FROM (
    SELECT
        c.ID AS client_id,
        c.First_Name,
        c.Last_name,
        SUM(t.Amount_Transactions) AS total_spent
    FROM clients c
    JOIN account a     ON a.Client_ID = c.ID
    JOIN transaction t ON t.Source_Account_ID = a.ID
    WHERE t.Amount_Transactions IS NOT NULL
    GROUP BY c.ID, c.First_Name, c.Last_name
) AS client_totals
WHERE total_spent > (
    SELECT AVG(total_spent) FROM (
        SELECT SUM(t.Amount_Transactions) AS total_spent
        FROM account a
        JOIN transaction t ON t.Source_Account_ID = a.ID
        WHERE t.Amount_Transactions IS NOT NULL
        GROUP BY a.Client_ID
    ) AS per_client
)
ORDER BY total_spent DESC;

-- 8. Second highest transaction
SELECT MAX(Amount_Transactions) AS second_highest_transaction
FROM transaction
WHERE Amount_Transactions < (
    SELECT MAX(Amount_Transactions) FROM transaction
);
