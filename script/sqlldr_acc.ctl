OPTIONS (SKIP=1)
LOAD DATA
CHARACTERSET UTF8
INFILE '../data/account.csv'
TRUNCATE INTO TABLE account
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
(
  acc_id
, tel_number
, cst_id
, is_suspect
, is_victim
)
