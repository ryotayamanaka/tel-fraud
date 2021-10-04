DROP USER telfraud;

CREATE USER telfraud
IDENTIFIED BY WELcome123##
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT
  create session
, create table
, create view
, graph_developer
, pgx_session_add_published_graph
TO telfraud;

GRANT
  alter session 
, create procedure 
, create sequence 
, create session 
, create table 
, create trigger 
, create type 
, create view 
TO telfraud;

EXIT
