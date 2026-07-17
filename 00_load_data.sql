-- ============================================================
-- Bank Management Analysis - Data Loader (pure SQL version)
-- Loads CSVs into MySQL using LOAD DATA INFILE.
-- Load order (FK-safe): branches, account_types, transaction_type,
--                        clients, account, transaction
--
-- IMPORTANT: MySQL can only LOAD DATA INFILE from a directory it is
-- allowed to read (secure_file_priv). This version is set up for:
--     secure_file_priv = C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- Copy the 6 CSVs into that folder first (you'll need admin rights,
-- since ProgramData is a protected system folder). If your
-- secure_file_priv path is different, run:
--     SHOW VARIABLES LIKE 'secure_file_priv';
-- and update the file paths in each LOAD DATA INFILE statement below.
-- ============================================================

USE bank_management;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE transaction;
TRUNCATE TABLE account;
TRUNCATE TABLE clients;
TRUNCATE TABLE transaction_type;
TRUNCATE TABLE account_types;
TRUNCATE TABLE branches;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- 1. branches
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/branches.csv'
INTO TABLE branches
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, Name, Location, Manager);

-- ------------------------------------------------------------
-- 2. account_types
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Account_types.csv'
INTO TABLE account_types
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, Description_Type);

-- ------------------------------------------------------------
-- 3. transaction_type
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transaction_type.csv'
INTO TABLE transaction_type
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, Transaction_type, Description, Transaction_fee);

-- ------------------------------------------------------------
-- 4. clients
-- CSV headers "Contact_no." / "Work_no." don't match column names
-- Contact_no / Work_no, and First_Name/Last_name have stray
-- whitespace in a few rows ("Dominik ", " Richter") -> load into
-- user variables and TRIM/assign via SET. Age is literal "NULL"
-- in every row -> NULLIF converts it to a real NULL.
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/clients.csv'
INTO TABLE clients
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, @First_Name, @Last_name, @DOB, Address, @Age, Sex, Created_Time, @Contact_no, @Work_no)
SET
    First_Name  = TRIM(@First_Name),
    Last_name   = TRIM(@Last_name),
    DOB         = NULLIF(@DOB, 'NULL'),
    Age         = NULLIF(@Age, 'NULL'),
    Contact_no  = @Contact_no,
    Work_no     = @Work_no;

-- ------------------------------------------------------------
-- 5. account
-- Deleted_at is literal "NULL" in every row -> NULLIF.
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Account.csv'
INTO TABLE account
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, Balance_account, Status, Created_at, @Deleted_at, Client_ID, account_type_id, Branch_ID)
SET
    Deleted_at = NULLIF(@Deleted_at, 'NULL');

-- ------------------------------------------------------------
-- 6. transaction
-- Amount_Transactions, Transfer, Total_Balance, and
-- Destination_Account_ID all contain literal "NULL" strings in
-- some rows -> NULLIF converts each to a real SQL NULL.
-- ------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transaction.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID, @Amount_Transactions, Date_issued, Deposit, Withdraw, @Transfer,
 @Total_Balance, Transactions_type_ID, Source_Account_ID, @Destination_Account_ID)
SET
    Amount_Transactions     = NULLIF(@Amount_Transactions, 'NULL'),
    Transfer                = NULLIF(@Transfer, 'NULL'),
    Total_Balance           = NULLIF(@Total_Balance, 'NULL'),
    Destination_Account_ID  = NULLIF(@Destination_Account_ID, 'NULL');

-- ------------------------------------------------------------
-- Validation: row counts per table
-- ------------------------------------------------------------
SELECT 'branches' AS tbl, COUNT(*) AS cnt FROM branches
UNION ALL SELECT 'account_types', COUNT(*) FROM account_types
UNION ALL SELECT 'transaction_type', COUNT(*) FROM transaction_type
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'account', COUNT(*) FROM account
UNION ALL SELECT 'transaction', COUNT(*) FROM transaction;

-- ------------------------------------------------------------
-- Validation: zero orphaned foreign keys expected on every line
-- ------------------------------------------------------------
SELECT 'account->clients'  AS fk_check, COUNT(*) AS orphans
FROM account a LEFT JOIN clients c ON a.Client_ID = c.ID WHERE c.ID IS NULL
UNION ALL
SELECT 'account->account_types', COUNT(*)
FROM account a LEFT JOIN account_types t ON a.account_type_id = t.ID WHERE t.ID IS NULL
UNION ALL
SELECT 'account->branches', COUNT(*)
FROM account a LEFT JOIN branches b ON a.Branch_ID = b.ID WHERE b.ID IS NULL
UNION ALL
SELECT 'transaction->transaction_type', COUNT(*)
FROM transaction t LEFT JOIN transaction_type tt ON t.Transactions_type_ID = tt.ID WHERE tt.ID IS NULL
UNION ALL
SELECT 'transaction->source_account', COUNT(*)
FROM transaction t LEFT JOIN account a ON t.Source_Account_ID = a.ID WHERE a.ID IS NULL
UNION ALL
SELECT 'transaction->destination_account', COUNT(*)
FROM transaction t LEFT JOIN account a ON t.Destination_Account_ID = a.ID
WHERE t.Destination_Account_ID IS NOT NULL AND a.ID IS NULL;
