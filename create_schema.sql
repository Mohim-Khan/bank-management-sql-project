-- ============================================================
-- Bank Management Analysis Using MySQL
-- Phase 0 / Step 2: Create Database Schema
-- ============================================================

DROP DATABASE IF EXISTS bank_management;
CREATE DATABASE bank_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bank_management;

-- ------------------------------------------------------------
-- Lookup table: branches
-- ------------------------------------------------------------
CREATE TABLE branches (
    ID          INT PRIMARY KEY,
    Name        VARCHAR(100) NOT NULL,
    Location    VARCHAR(100) NOT NULL,
    Manager     VARCHAR(100) NOT NULL
);

-- ------------------------------------------------------------
-- Lookup table: account_types
-- ------------------------------------------------------------
CREATE TABLE account_types (
    ID                  INT PRIMARY KEY,
    Description_Type    VARCHAR(500) NOT NULL
);

-- ------------------------------------------------------------
-- Lookup table: transaction_type
-- ------------------------------------------------------------
CREATE TABLE transaction_type (
    ID                  INT PRIMARY KEY,
    Transaction_type    VARCHAR(50)  NOT NULL,
    Description         VARCHAR(255),
    Transaction_fee     DECIMAL(10,2) NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------
-- clients
-- ------------------------------------------------------------
CREATE TABLE clients (
    ID              INT PRIMARY KEY,
    First_Name      VARCHAR(100) NOT NULL,
    Last_name       VARCHAR(100) NOT NULL,
    DOB             DATE,
    Address         VARCHAR(255),
    Age             INT NULL,
    Sex             CHAR(1),
    Created_Time    DATETIME,
    Contact_no      VARCHAR(30),
    Work_no         VARCHAR(30)
);

-- ------------------------------------------------------------
-- account  (FK -> clients, account_types, branches)
-- ------------------------------------------------------------
CREATE TABLE account (
    ID                  INT PRIMARY KEY,
    Balance_account     DECIMAL(14,2) NOT NULL DEFAULT 0,
    Status              VARCHAR(20)  NOT NULL,
    Created_at          DATETIME,
    Deleted_at          DATETIME NULL,
    Client_ID           INT NOT NULL,
    account_type_id     INT NOT NULL,
    Branch_ID           INT NOT NULL,
    CONSTRAINT fk_account_client
        FOREIGN KEY (Client_ID) REFERENCES clients(ID),
    CONSTRAINT fk_account_type
        FOREIGN KEY (account_type_id) REFERENCES account_types(ID),
    CONSTRAINT fk_account_branch
        FOREIGN KEY (Branch_ID) REFERENCES branches(ID)
);

-- ------------------------------------------------------------
-- transaction (FK -> transaction_type, account (source & destination))
-- ------------------------------------------------------------
CREATE TABLE transaction (
    ID                          INT PRIMARY KEY,
    Amount_Transactions         DECIMAL(14,2) NULL,
    Date_issued                 DATETIME NOT NULL,
    Deposit                     DECIMAL(14,2) NOT NULL DEFAULT 0,
    Withdraw                    DECIMAL(14,2) NOT NULL DEFAULT 0,
    Transfer                    DECIMAL(14,2) NULL,
    Total_Balance               DECIMAL(14,2) NULL,
    Transactions_type_ID        INT NOT NULL,
    Source_Account_ID           INT NOT NULL,
    Destination_Account_ID      INT NULL,
    CONSTRAINT fk_txn_type
        FOREIGN KEY (Transactions_type_ID) REFERENCES transaction_type(ID),
    CONSTRAINT fk_txn_source
        FOREIGN KEY (Source_Account_ID) REFERENCES account(ID),
    CONSTRAINT fk_txn_dest
        FOREIGN KEY (Destination_Account_ID) REFERENCES account(ID)
);

-- ------------------------------------------------------------
-- Helpful indexes for analysis performance
-- ------------------------------------------------------------
CREATE INDEX idx_account_client   ON account(Client_ID);
CREATE INDEX idx_account_branch   ON account(Branch_ID);
CREATE INDEX idx_account_type     ON account(account_type_id);
CREATE INDEX idx_txn_source       ON transaction(Source_Account_ID);
CREATE INDEX idx_txn_dest         ON transaction(Destination_Account_ID);
CREATE INDEX idx_txn_type         ON transaction(Transactions_type_ID);
CREATE INDEX idx_txn_date         ON transaction(Date_issued);
