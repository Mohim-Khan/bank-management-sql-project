-- ============================================================
-- PHASE 1: BASIC ANALYSIS (5 Queries)
-- ============================================================
USE bank_management;

-- 1. Total number of clients
SELECT COUNT(*) AS total_clients
FROM clients;

-- 2. Total number of accounts
SELECT COUNT(*) AS total_accounts
FROM account;

-- 3. Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transaction;

-- 4. Highest transaction amount
SELECT MAX(Amount_Transactions) AS highest_transaction_amount
FROM transaction;

-- 5. Lowest transaction amount
SELECT MIN(Amount_Transactions) AS lowest_transaction_amount
FROM transaction
WHERE Amount_Transactions IS NOT NULL;
