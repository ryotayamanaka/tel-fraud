# Telfraud

## Prerequisits

- Database Cloud Service instance
- Graph Server and Client instance (from Marketplace)

## Download the scripts (on DBCS instance)

Login to the **DBCS** instance and install Git.

    $ sudo su -
    # yum-config-manager --add-repo https://yum.oracle.com/repo/OracleLinux/OL&/latest/x86_64/
    # wget http://yum.oracle.com/RPM-GPG-KEY-oracle-ol7
    # gpg --quiet --with-fingerprint ./RPM-GPG-KEY-oracle-ol7
    # rpm --import ./RPM-GPG-KEY-oracle-ol7
    # yum install -y git
    # exit

Clone this repository at the home directory of `oracle` user.

    $ sudo su - oracle
    $ cd ~
    $ git clone https://github.com/ryotayamanaka/telfraud.git

Login to the **Graph Server** instance and install Git.

    $ sudo yum install -y git

Clone this repository at the home directory of `opc` user.

    $ cd ~
    $ git clone https://github.com/ryotayamanaka/telfraud.git

## Prepare dataset (on DBCS instance)

### Pre-created dataset

Sample dataset is under `/data/scale-100/` directory.

    $ ls /data/scale-100/*.csv
    account.csv customer.csv transaction.csv

Copy the 3 CSV files under `/data/` for loading.

    $ cp ./data/scale-100/*.csv ./data/

### Larger dataset (optional)

For creating a graph with larger number of accounts (e.g. 10000), run this script.

    $ cd script/
    $ python3 create_graph.py 10000

This script creates 3 CSV files.

    $ ls *.csv
    account.csv customer.csv transaction.csv

Locate the CSV files under `/data/` directory.

    $ mv *.csv ../data/

## Load dataset to tables (on DBCS instance)

Check the service name of the PDB. `<connect-string>` below is `<ip-address>:1521/<service-name>`.

    $ lsnrctl status

Move to `script/` directory.

    $ cd ~/telfraud/script/

Create a database user, `telfraud`.

    $ sqlplus sys/Welcome1@<connect-string> as sysdba @create-user.sql

Create tables, `account`, `customer`, and `transaction`.

    $ sqlplus telfraud/WELcome123##@<connect-string> @create-table.sql

Load the data from the CSV file.

    $ sqlldr telfraud/WELcome123##@<connect-string> sqlldr_acc.ctl direct=true
    $ sqlldr telfraud/WELcome123##@<connect-string> sqlldr_cst.ctl direct=true
    $ sqlldr telfraud/WELcome123##@<connect-string> sqlldr_txn.ctl direct=true

Exit from the `DBCS`.

    $ exit

## Modify the data

The addtional fixes below are required for the demo scenario.

```
DELETE FROM transaction WHERE acc_id_dst BETWEEN 0 AND 9;

UPDATE account SET is_suspect = 1 WHERE acc_id BETWEEN 0 AND 9;

UPDATE account SET is_victim = 1 WHERE acc_id IN (66, 64, 74);

INSERT INTO transaction VALUES　(12, 5, 10001, null, null);
INSERT INTO transaction VALUES　(12, 6, 10002, null, null);
INSERT INTO transaction VALUES　(12, 0, 10003, null, null);

COMMIT;
```

## Create property graph (on Graph Server instance)

Then start a client shell instance that connects to the server

    $ opgpy --base_url https://localhost:7007 --user telfraud
    enter password for user telfraud (press Enter for no password): WELcome123##
    Oracle Graph Server Shell 21.3.0
    >>>

Follow this notebook to create graphs.

[`telfraud.ipynb`](./telfraud.ipynb)

## Demo (using Graph Viz)

Follow this memo to demo on Graph Viz.

[`memo.md`](./memo.md)

Upload the visualization settings file before running the demo.

[`telfraud_settings.json`](./telfraud_settings.json)

