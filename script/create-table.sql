DROP TABLE account;
DROP TABLE customer;
DROP TABLE transaction;

CREATE TABLE account (
  acc_id NUMBER NOT NULL
, tel_number VARCHAR2(255)
, cst_id NUMBER NOT NULL
, is_suspect NUMBER(1)
, is_victim NUMBER(1)
, CONSTRAINT account_pk PRIMARY KEY (acc_id)
);

CREATE TABLE customer (
  cst_id NUMBER NOT NULL
, first_name VARCHAR2(255)
, last_name VARCHAR2(255)
, CONSTRAINT customer_pk PRIMARY KEY (cst_id)
);

CREATE TABLE transaction (
  acc_id_src NUMBER
, acc_id_dst NUMBER
, txn_id NUMBER
, datetime TIMESTAMP
, amount NUMBER
, CONSTRAINT transaction_pk PRIMARY KEY (txn_id)
);

EXIT
