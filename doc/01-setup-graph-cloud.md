## Download the scripts

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
    $ git clone https://github.com/ryotayamanaka/moneyflows.git

Login to the **Graph Server** instance and install Git.

    $ sudo yum install -y git

Clone this repository at the home directory of `opc` user.

    $ cd ~
    $ git clone https://github.com/ryotayamanaka/moneyflows.git

## Prepare dataset

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

## Load dataset to tables

Check the service name of the PDB. `<connect-string>` below is `<ip-address>:1521/<service-name>`.

    $ lsnrctl status

Move to `script/` directory.

    $ cd ~/moneyflows/script/

Create a database user, `moneyflows`.

    $ sqlplus sys/Welcome1@<connect-string> as sysdba @create-user.sql

Create tables, `account`, `customer`, and `transaction`.

    $ sqlplus moneyflows/WELcome123##@<connect-string> @create-table.sql

Load the data from the CSV file.

    $ sqlldr moneyflows/WELcome123##@<connect-string> sqlldr_acc.ctl direct=true
    $ sqlldr moneyflows/WELcome123##@<connect-string> sqlldr_cst.ctl direct=true
    $ sqlldr moneyflows/WELcome123##@<connect-string> sqlldr_txn.ctl direct=true

Exit from the `DBCS`.

    $ exit

## Create property graph

Then start a client shell instance that connects to the server

    $ opgpy --base_url https://localhost:7007 --user telfraud
    enter password for user moneyflows (press Enter for no password): WELcome123##
    Oracle Graph Server Shell 21.3.0
    >>>

Set the create property graph statement.

[`create-pg.pgql`](../script/create-pg.pgql)

    >>> statement = open('/home/opc/telfraud/script/create-pg.pgql', 'r').read()

Run the statement.

    >>> session.prepare_pgql(statement).execute()
    False

Get the created graph and try a PGQL query.

    >>> graph = session.get_graph("telfraud")
    >>> graph
    PgxGraph(name: Moneyflows, v: 180, e: 3100, directed: True, memory(Mb): 0)
    >>> graph.query_pgql("""
            SELECT a1.acc_id AS a1_acc_id, t.datetime, t.amount, a2.acc_id AS a2_acc_id
            FROM MATCH (a1)-[t:transferred_to]->(a2)
            LIMIT 5
        """).print()

If you need to recreate the graph, destroy the graph first and run the statement above again.

    >>> graph.destroy()

To make this graph accessable from other sessions, you need to publish the graph. The privilege to publish graphs (= `PGX_SESSION_ADD_PUBLISHED_GRAPH`) has been already granted when the user is created.

    >>> graph.publish()
