-- Copyright 2004-2018 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (http://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE T1(C1 INT NOT NULL, C2 INT NOT NULL, C3 INT, C4 INT);
> ok

ALTER TABLE T1 ADD CONSTRAINT PK_1 PRIMARY KEY(C1, C2);
> ok

ALTER TABLE T1 ADD CONSTRAINT U_1 UNIQUE(C3, C4);
> ok

CREATE TABLE T2(C1 INT, C2 INT, C3 INT, C4 INT);
> ok

ALTER TABLE T2 ADD CONSTRAINT FK_1 FOREIGN KEY (C3, C4) REFERENCES T1(C1, C3) ON DELETE SET NULL;
> ok

ALTER TABLE T2 ADD CONSTRAINT CH_1 CHECK C4 > 0;
> ok

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS LIMIT 0;
> CONSTRAINT_CATALOG CONSTRAINT_SCHEMA CONSTRAINT_NAME CONSTRAINT_TYPE TABLE_CATALOG TABLE_SCHEMA TABLE_NAME IS_DEFERRABLE INITIALLY_DEFERRED
> ------------------ ----------------- --------------- --------------- ------------- ------------ ---------- ------------- ------------------
> rows: 0

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE, TABLE_NAME, IS_DEFERRABLE, INITIALLY_DEFERRED FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_CATALOG = DATABASE() AND CONSTRAINT_SCHEMA = SCHEMA() AND TABLE_CATALOG = DATABASE() AND TABLE_SCHEMA = SCHEMA()
    ORDER BY TABLE_NAME, CONSTRAINT_NAME;
> CONSTRAINT_NAME CONSTRAINT_TYPE TABLE_NAME IS_DEFERRABLE INITIALLY_DEFERRED
> --------------- --------------- ---------- ------------- ------------------
> PK_1            PRIMARY KEY     T1         NO            NO
> U_1             UNIQUE          T1         NO            NO
> CH_1            CHECK           T2         NO            NO
> FK_1            FOREIGN KEY     T2         NO            NO
> rows (ordered): 4

SELECT * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE LIMIT 0;
> CONSTRAINT_CATALOG CONSTRAINT_SCHEMA CONSTRAINT_NAME TABLE_CATALOG TABLE_SCHEMA TABLE_NAME COLUMN_NAME ORDINAL_POSITION POSITION_IN_UNIQUE_CONSTRAINT
> ------------------ ----------------- --------------- ------------- ------------ ---------- ----------- ---------------- -----------------------------
> rows: 0

SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, POSITION_IN_UNIQUE_CONSTRAINT FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE CONSTRAINT_CATALOG = DATABASE() AND CONSTRAINT_SCHEMA = SCHEMA() AND TABLE_CATALOG = DATABASE() AND TABLE_SCHEMA = SCHEMA()
    ORDER BY TABLE_NAME, CONSTRAINT_NAME, ORDINAL_POSITION;
> CONSTRAINT_NAME TABLE_NAME COLUMN_NAME ORDINAL_POSITION POSITION_IN_UNIQUE_CONSTRAINT
> --------------- ---------- ----------- ---------------- -----------------------------
> PK_1            T1         C1          1                null
> PK_1            T1         C2          2                null
> U_1             T1         C3          1                null
> U_1             T1         C4          2                null
> FK_1            T2         C3          1                1
> FK_1            T2         C4          2                2
> rows (ordered): 6

SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS LIMIT 0;
> CONSTRAINT_CATALOG CONSTRAINT_SCHEMA CONSTRAINT_NAME UNIQUE_CONSTRAINT_CATALOG UNIQUE_CONSTRAINT_SCHEMA UNIQUE_CONSTRAINT_NAME MATCH_OPTION UPDATE_RULE DELETE_RULE
> ------------------ ----------------- --------------- ------------------------- ------------------------ ---------------------- ------------ ----------- -----------
> rows: 0

-- H2 returns name of the index istead of name of the referenced constraint as UNIQUE_CONSTRAINT_NAME
SELECT CONSTRAINT_NAME, SUBSTRING(UNIQUE_CONSTRAINT_NAME, 0, 11) AS UCN_PART, MATCH_OPTION, UPDATE_RULE, DELETE_RULE FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
    WHERE CONSTRAINT_CATALOG = DATABASE() AND CONSTRAINT_SCHEMA = SCHEMA() AND UNIQUE_CONSTRAINT_CATALOG = DATABASE() AND UNIQUE_CONSTRAINT_SCHEMA = SCHEMA()
    ORDER BY CONSTRAINT_NAME, UNIQUE_CONSTRAINT_NAME;
> CONSTRAINT_NAME UCN_PART    MATCH_OPTION UPDATE_RULE DELETE_RULE
> --------------- ----------- ------------ ----------- -----------
> FK_1            FK_1_INDEX_ NONE         RESTRICT    SET NULL
> rows (ordered): 1

DROP TABLE T2;
> ok

DROP TABLE T1;
> ok
