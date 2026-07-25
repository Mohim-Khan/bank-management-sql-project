# 🏦 Bank Management Analysis Using MySQL

## 📌 Project Overview

This project is an end-to-end SQL portfolio project built using **MySQL 8** to
analyze a relational **Bank Management System** database. The database consists
of six related tables representing clients, accounts, branches, account types,
transactions, and transaction types — built from scratch from raw CSV exports,
loaded via pure SQL, and validated for referential integrity before any analysis
was run.

The objective of this project is to answer real-world banking business questions
by applying SQL to extract meaningful insights that support data-driven decisions.

![Bank ER Diagram](diagram/bank_er_diagram.png)

---

# 🎯 Business Problem

Banks generate transactions every day across multiple branches and account types.
Understanding customer behavior, transaction activity, and branch performance is
essential for improving operational efficiency and making informed business
decisions.

This project analyzes banking data to identify transaction trends, customer
activity, branch performance, and account type usage using SQL.

---

# 🎯 Project Objectives

* Analyze customer and account information.
* Evaluate branch performance.
* Analyze transaction patterns.
* Identify high-value customers.
* Compare account types based on transaction activity.
* Generate business insights using SQL.

---

# ❓ Project Q&A

### 1. What problem am I solving?

Banks process transactions across many branches, account types, and customers
every day, but that data is only useful if it can be queried and understood.
This project takes a fragmented set of raw banking data — six separate CSVs
with no built-in relationships — and turns it into a properly structured,
queryable database that can answer real operational questions: which branches
perform best, which customers drive the most transaction volume, how spending
breaks down by account type, and where activity is trending month to month.

### 2. How did I collect, clean, and analyze the data?

**Collect** — The source data came as six CSV exports (`clients`, `account`,
`account_types`, `branches`, `transaction`, `transaction_type`), each
representing one entity in the bank's operations.

**Clean** — Before loading anything, I explored each file to identify primary
keys, map foreign key relationships, and check for missing values. I found
several legitimate (not corrupted) NULL patterns — e.g. `clients.Age` was
never populated by the source system, and `transaction.Destination_Account_ID`
is NULL for single-leg transactions like ATM withdrawals. I built a pure-SQL
loader (`LOAD DATA INFILE` + `NULLIF()` + `TRIM()`) that converts literal
`"NULL"` strings into real SQL NULLs and strips stray whitespace from client
names, instead of silently importing dirty data or guessing values to fill
gaps.

**Analyze** — I designed a normalized MySQL schema with proper primary and
foreign keys, validated it (row counts matched the source CSVs exactly, zero
orphaned foreign keys across all 6 relationships), then wrote 43 SQL queries
across 7 phases of increasing complexity — from basic aggregation, through
`GROUP BY`/`HAVING`, subqueries, `CASE WHEN` segmentation, and finally CTEs
for reusable summary tables.

### 3. What insights did my analysis actually uncover?

* **Main Branch Berlin drives disproportionate volume** — €12,647 in total
  transactions, more than 7× the second-ranked branch (Leipzig, €1,661).
* **One customer accounts for an outsized share of activity** — Ellis Kirk's
  €13,330 in total transactions is more than 6× the next-highest customer.
* **A single transaction dominates the top-end** — the highest transaction on
  record is €10,000, dwarfing the next-largest at €721.
* **Transfers are the primary transaction type**, making up roughly half of
  all transaction activity (30 of 62), ahead of ATM deposits (15) and ATM
  withdrawals (9).
* **Savings accounts are the most common product** (9 of 43 accounts), ahead
  of Online Banking (6) and Student accounts (5).
* **Overdraft fees never triggered once** in this dataset — a finding worth
  flagging to a real bank as either healthy customer behavior or a possible
  gap in fee logging.

---

# 🗃️ Database Overview

The project uses a relational database consisting of **6 tables**:

| Table | Description |
|---|---|
| `clients` | Stores customer information |
| `account` | Stores customer bank accounts |
| `account_types` | Stores different account categories |
| `branches` | Stores branch information |
| `transaction` | Stores transaction records |
| `transaction_type` | Stores transaction categories |

**Data volume:** 14 clients · 43 accounts · 62 transactions · 10 branches · 10 account types · 5 transaction types

---

# 🧩 Database Schema

The database follows a normalized relational structure using **Primary Keys**
(`ID` on every table) and **Foreign Keys** enforced with `FOREIGN KEY` constraints.

### Relationships

* One Client → Many Accounts
* One Branch → Many Accounts
* One Account Type → Many Accounts
* One Account → Many Transactions (as **source** account)
* One Account → Many Transactions (as **destination** account, nullable — e.g.
  ATM withdrawals have no destination account)
* One Transaction Type → Many Transactions

### Data Quality Notes

A few columns contain legitimate, expected NULLs rather than data errors:
* `clients.Age` — not populated by the source system (derivable from `DOB` if needed)
* `account.Deleted_at` — no accounts have been soft-deleted
* `transaction.Total_Balance` — only populated on "Balance Inquiry" transactions
* `transaction.Destination_Account_ID` — NULL for single-leg transaction types
  (ATM withdrawal/deposit, balance inquiry)

These were preserved as real `NULL`s during import (not imputed), and handled
with `IS NOT NULL` / `COALESCE` in the relevant analysis queries.

---

# 🛠️ SQL Skills Used

### Basic SQL
* SELECT, WHERE, ORDER BY, LIMIT

### Aggregate Functions
* SUM(), AVG(), COUNT(), MAX(), MIN()

### Data Aggregation
* GROUP BY, HAVING

### Joins
* INNER JOIN, LEFT JOIN

### Data Import
* LOAD DATA INFILE, NULLIF(), TRIM()

### Intermediate SQL
* Subqueries (scalar & correlated)
* CASE WHEN
* Common Table Expressions (CTE)

---

# 🗺️ Project Roadmap

### Phase 0 — Project Planning
* Explored the raw dataset (6 CSVs) and identified primary/foreign keys
* Designed and created the normalized MySQL schema
* Imported data via `LOAD DATA INFILE`, converting literal `"NULL"` strings to
  real SQL NULLs and trimming whitespace from client names
* Validated the import: row counts match source CSVs exactly, zero orphaned
  foreign keys across all 6 relationships
* Built the ER Diagram with Graphviz

### Phase 1 — Basic Analysis (5 queries)
* Total clients, total accounts, total transactions
* Highest and lowest transaction amount

### Phase 2 — Customer & Account Analysis (8 queries)
* Accounts by account type, accounts by branch, clients by branch
* Average/total transaction amount by account type and by branch
* Monthly transaction count

### Phase 3 — Transaction Analysis (6 queries)
* Top 10 highest transactions
* Top branches, account types, and customers by transaction volume
* Highest transaction accounts
* Transaction type distribution

### Phase 4 — HAVING Analysis (6 queries)
* Branches exceeding transaction amount thresholds
* Account types with above-average transaction amounts
* Customers with more than 10 transactions
* Branches with more than 3 accounts
* Transaction types used more than 10 times
* Account types exceeding a transaction amount threshold

### Phase 5 — Subquery Analysis (8 queries)
* Transactions above the average amount
* Highest / lowest / second-highest transaction
* Customer with the highest transaction volume
* Branch with the highest transaction volume
* Account type with the highest transaction volume
* Customers spending above the average

### Phase 6 — CASE WHEN Analysis (5 queries)
* Customer activity segmentation (Inactive / Low / Moderate / High)
* Transaction amount categories (Zero / Small / Medium / Large)
* Branch performance categories
* Account type tiers (by average balance)
* Customer spending categories

### Phase 7 — CTE Analysis (5 queries)
* Customer transaction summary
* Branch performance summary
* Account type summary
* Monthly transaction summary
* High-value customer summary

---

# 📈 Business Questions

This project answers **43 business questions** across 7 phases, including:

* Which branch processes the highest transaction volume?
* Which customers perform the highest number of transactions?
* Which account type is the most popular?
* Which transaction type is used most frequently?
* Which customers spend above the average transaction amount?
* Which branches generate the highest transaction value?
* Which account types contribute the most to total transaction volume?
* What does the monthly transaction trend look like?

---

# 💡 Key Business Insights

* **Main Branch Berlin leads all branches** in total transaction volume
  (€12,647) — more than 7× the second-ranked branch (Leipzig, €1,661).
* **One customer, Ellis Kirk, accounts for the largest share of transaction
  volume** (€13,330 total), well ahead of the next customer (€2,013).
* **€10,000** is the single highest transaction on record — an ATM withdrawal
  far larger than the next-largest transaction (€721).
* **Transfers dominate transaction activity**, making up 30 of 62 total
  transactions, followed by ATM deposits (15) and ATM withdrawals (9).
* **Savings accounts are the most popular account type** (9 of 43 accounts),
  ahead of Online Banking (6) and Student accounts (5).
* **Overdraft fees never occurred** in this dataset (0 transactions of that
  type) — worth flagging for a real bank as either good customer discipline or
  a sign the fee isn't being triggered/logged correctly.

---

# 📂 Project Structure

```text
bank_project/
├── README.md
├── data/                                   # source CSVs
│   ├── clients.csv
│   ├── Account.csv
│   ├── Account_types.csv
│   ├── branches.csv
│   ├── transaction.csv
│   └── transaction_type.csv
├── diagram/
│   ├── bank_er_diagram.dot                 # Graphviz source
│   └── bank_er_diagram.png                 # rendered ER diagram
└── sql/
    ├── 01_create_schema.sql                # DDL: tables, PKs, FKs, indexes
    ├── 00_load_data.sql                    # data import (Linux/Mac)
    ├── 00_load_data_windows.sql            # data import (Windows)
    ├── load_data.py                        # Python/pandas alternative loader
    ├── 02_phase1_basic_analysis.sql
    ├── 03_phase2_customer_account_analysis.sql
    ├── 04_phase3_transaction_analysis.sql
    ├── 05_phase4_having_analysis.sql
    ├── 06_phase5_subquery_analysis.sql
    ├── 07_phase6_case_when_analysis.sql
    ├── 08_phase7_cte_analysis.sql
    └── 09_all_queries_combined.sql         # all 43 queries in one file
```

---

# 🚀 Tools & Technologies

* MySQL 8.0
* MySQL Workbench / MySQL CLI
* Graphviz (ER Diagram)
* Python (`mysql-connector-python`) — alternative data loader
* Git & GitHub

---

# 📌 Future Improvements

* Add window functions (`RANK()`, `LAG()`, running totals) for deeper trend analysis
* Build an interactive Power BI or Tableau dashboard on top of this schema
* Extend with stored procedures and views for reusable reporting
* Perform customer segmentation with Python (clustering on transaction behavior)
* Scale the dataset up and re-tune the Phase 4 `HAVING` thresholds to match
