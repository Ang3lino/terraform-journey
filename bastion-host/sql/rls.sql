
-- SET SESSION AUTHORIZATION awsuser;

-- Creating users, granting permissions
-- ****************************************************************************

-- Create users and roles referenced in the policy statements.
CREATE ROLE analyst;
CREATE ROLE consumer;
CREATE ROLE dbadmin;
CREATE ROLE auditor;

-- SHOW search_path;

-- DROP USER bob;
-- DROP USER alice;
-- DROP USER joe;
-- DROP USER molly;
-- DROP USER bruce;

CREATE USER bob WITH PASSWORD 'Name_is_bob_1';
CREATE USER alice WITH PASSWORD 'Name_is_alice_1';
CREATE USER joe WITH PASSWORD 'Name_is_joe_1';
CREATE USER molly WITH PASSWORD 'Name_is_molly_1';
CREATE USER bruce WITH PASSWORD 'Name_is_bruce_1';

-- sys:secadmin bob, analyst alice, consumer joe, dbadming molly, auditor bruce
GRANT ROLE sys:secadmin TO bob;
GRANT ROLE analyst TO alice;
GRANT ROLE consumer TO joe;
GRANT ROLE dbadmin TO molly;
GRANT ROLE auditor TO bruce;

GRANT ALL ON TABLE tickit_category_redshift TO PUBLIC;
GRANT ALL ON TABLE tickit_sales_redshift TO PUBLIC;
GRANT ALL ON TABLE tickit_event_redshift TO PUBLIC;

-- Create table and schema referenced in the policy statements.
CREATE SCHEMA target_schema;
GRANT ALL ON SCHEMA target_schema TO PUBLIC;

CREATE TABLE target_schema.target_event_table (LIKE tickit_event_redshift);
GRANT ALL ON TABLE target_schema.target_event_table TO PUBLIC;

-- Creating RLS policies, testing RLS
-- ****************************************************************************
-- Change session to analyst alice.
SET SESSION AUTHORIZATION alice;

-- Check the tuples visible to analyst alice.
-- Should contain all 3 categories.
SELECT catgroup, count(*)
    FROM tickit_category_redshift
    GROUP BY catgroup 
    ORDER BY catgroup;

--  catgroup | count
-- ----------+-------
--  Concerts |     6
--  Shows    |     6
--  Sports   |    10
-- (3 rows)

-- Change session to security administrator bob.
SET SESSION AUTHORIZATION bob;

CREATE RLS POLICY policy_concerts
    WITH (catgroup VARCHAR(10))
    USING (catgroup = 'Concerts');

SELECT poldb, polname, polalias, polatts, polqual, polenabled, polmodifiedby 
    FROM svv_rls_policy 
    WHERE poldb = CURRENT_DATABASE();

--  poldb |     polname     | polalias  |                         polatts                         |                      polqual                      | polenabled | polmodifiedby
-- -------+-----------------+-----------+---------------------------------------------------------+---------------------------------------------------+------------+---------------
--  dev   | policy_concerts | rls_table | [{"colname":"catgroup","type":"character varying(10)"}] | "rls_table"."catgroup" = CAST('Concerts' AS TEXT) | t          | bob
-- (1 row)

-- sys:secadmin bob, analyst alice, consumer joe, dbadming molly, auditor bruce
-- attached to alice, molly
ATTACH RLS POLICY policy_concerts ON tickit_category_redshift TO ROLE analyst, ROLE dbadmin;

ALTER TABLE tickit_category_redshift ROW LEVEL SECURITY ON;

SELECT * FROM svv_rls_attached_policy;

--  relschema |         relname          | relkind |     polname     | grantor | grantee | granteekind | is_pol_on | is_rls_on | rls_conjunction_type
-- -----------+--------------------------+---------+-----------------+---------+---------+-------------+-----------+-----------+----------------------
--  public    | tickit_category_redshift | table   | policy_concerts | bob     | analyst | role        | t         | t         | and
--  public    | tickit_category_redshift | table   | policy_concerts | bob     | dbadmin | role        | t         | t         | and
-- (2 rows)

-- Change session to analyst alice.
SET SESSION AUTHORIZATION alice;

-- Check that tuples with only `Concert` category will be visible to analyst alice.
SELECT catgroup, count(*)
FROM tickit_category_redshift
GROUP BY catgroup ORDER BY catgroup;

--  catgroup | count
-- ----------+-------
--  Concerts |     6
-- (1 row)

-- Change session to consumer joe.
SET SESSION AUTHORIZATION joe;

-- Although the policy is attached to a different role, no tuples will be
-- visible to consumer joe because the default deny all policy is applied.
SELECT catgroup, count(*)
FROM tickit_category_redshift
GROUP BY catgroup ORDER BY catgroup;

--  catgroup | count
-- ----------+-------
-- (0 rows)


-- Change session to dbadmin molly.
SET SESSION AUTHORIZATION molly;

-- Check that tuples with only `Concert` category will be visible to dbadmin molly.
SELECT catgroup, count(*)
FROM tickit_category_redshift
GROUP BY catgroup ORDER BY catgroup;

--  catgroup | count
-- ----------+-------
--  Concerts |     6
-- (1 row)

-- Check that EXPLAIN output contains RLS SecureScan to prevent disclosure of
-- sensitive information such as RLS filters.
EXPLAIN SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

--                                               QUERY PLAN
-- -------------------------------------------------------------------------------------------------------
--  XN Merge  (cost=1000000000000.39..1000000000000.40 rows=1 width=10)
--    Merge Key: catgroup
--    ->  XN Network  (cost=1000000000000.39..1000000000000.40 rows=1 width=10)
--          Send to leader
--          ->  XN Sort  (cost=1000000000000.39..1000000000000.40 rows=1 width=10)
--                Sort Key: catgroup
--                ->  XN HashAggregate  (cost=0.38..0.38 rows=1 width=10)
--                      ->  XN RLS SecureScan tickit_category_redshift  (cost=0.00..0.35 rows=7 width=10)
-- (8 rows)

-- Change session to security administrator bob.
SET SESSION AUTHORIZATION bob;

-- sys:secadmin bob, analyst alice, consumer joe, dbadming molly, auditor bruce

-- Grant IGNORE RLS permission so that RLS policies do not get applicable to role dbadmin.
-- molly modified
GRANT IGNORE RLS TO ROLE dbadmin;

-- Grant EXPLAIN RLS permission so that anyone in role auditor can view complete EXPLAIN output.
-- bruce modified
GRANT EXPLAIN RLS TO ROLE auditor;

-- Change session to dbadmin molly.
SET SESSION AUTHORIZATION molly;

-- Check that all tuples are visible to dbadmin molly because `IGNORE RLS` is granted to role dbadmin.
SELECT catgroup, count(*)
FROM tickit_category_redshift
GROUP BY catgroup ORDER BY catgroup;

--  catgroup | count
-- ----------+-------
--  Concerts |     3
--  Shows    |     3
--  Sports   |     5
-- (3 rows)

SET SESSION AUTHORIZATION bruce;

-- Check explain plan is visible to auditor bruce because `EXPLAIN RLS` is granted to role auditor.
EXPLAIN SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

--                                                  QUERY PLAN
-- -------------------------------------------------------------------------------------------------------------
--  XN Merge  (cost=1000000000000.04..1000000000000.04 rows=1 width=10)
--    Merge Key: catgroup
--    ->  XN Network  (cost=1000000000000.04..1000000000000.04 rows=1 width=10)
--          Send to leader
--          ->  XN Sort  (cost=1000000000000.04..1000000000000.04 rows=1 width=10)
--                Sort Key: catgroup
--                ->  XN HashAggregate  (cost=0.02..0.03 rows=1 width=10)
--                      ->  XN Network  (cost=0.00..0.02 rows=1 width=10)
--                            Distribute Round Robin
--                            ->  XN RLS SecureScan tickit_category_redshift  (cost=0.00..0.02 rows=1 width=10)
--                                  ->  XN Result  (cost=0.00..0.01 rows=1 width=0)
--                                        One-Time Filter: false
-- (12 rows)

-- Change session to security administrator bob.
SET SESSION AUTHORIZATION bob;

-- sys:secadmin bob, analyst alice, consumer joe, dbadming molly, auditor bruce
-- alice mod, molly mod
DETACH RLS POLICY policy_concerts ON tickit_category_redshift FROM ROLE analyst, ROLE dbadmin;

-- Change session to analyst alice.
SET SESSION AUTHORIZATION alice;

-- Check that no tuples are visible to analyst alice.
-- Although the policy is detached, no tuples will be visible to analyst alice
-- because of default deny all policy is applied if the table has RLS on.
SELECT catgroup, count(*)
FROM tickit_category_redshift
GROUP BY catgroup ORDER BY catgroup;

--  catgroup | count
-- ----------+-------
-- (0 rows)


-- Checking RLS lock integrity
-- ****************************************************************************
-- Change session to security administrator bob.
SET SESSION AUTHORIZATION bob;

CREATE RLS POLICY policy_events
WITH (eventid INTEGER) AS ev
USING (
    ev.eventid IN (SELECT eventid FROM tickit_sales_redshift WHERE qtysold <3)
);

-- sys:secadmin bob, analyst alice, consumer joe, dbadming molly, auditor bruce

ATTACH RLS POLICY policy_events ON tickit_event_redshift TO ROLE analyst;
ATTACH RLS POLICY policy_events ON target_schema.target_event_table TO ROLE consumer;

RESET SESSION AUTHORIZATION;

-- Can not cannot alter type of dependent column.
ALTER TABLE target_schema.target_event_table ALTER COLUMN eventid TYPE float;
ALTER TABLE tickit_event_redshift ALTER COLUMN eventid TYPE float;
ALTER TABLE tickit_sales_redshift ALTER COLUMN eventid TYPE float;
ALTER TABLE tickit_sales_redshift ALTER COLUMN qtysold TYPE float;

-- ERROR:  cannot alter type of column "eventid" of relation "target_event_table" because it is referenced by some rls policy.
-- ERROR:  cannot alter type of column "eventid" of relation "tickit_event_redshift" because it is referenced by some rls policy.
-- ERROR:  cannot alter type of column "eventid" of relation "tickit_sales_redshift" because it is referenced by some rls policy.
-- ERROR:  cannot alter type of column "qtysold" of relation "tickit_sales_redshift" because it is referenced by some rls policy.

-- Can not cannot rename dependent column.
ALTER TABLE target_schema.target_event_table RENAME COLUMN eventid TO renamed_eventid;
ALTER TABLE tickit_event_redshift RENAME COLUMN eventid TO renamed_eventid;
ALTER TABLE tickit_sales_redshift RENAME COLUMN eventid TO renamed_eventid;
ALTER TABLE tickit_sales_redshift RENAME COLUMN qtysold TO renamed_qtysold;

-- Can not drop dependent column.
ALTER TABLE target_schema.target_event_table DROP COLUMN eventid CASCADE;
ALTER TABLE tickit_event_redshift DROP COLUMN eventid CASCADE;
ALTER TABLE tickit_sales_redshift DROP COLUMN eventid CASCADE;
ALTER TABLE tickit_sales_redshift DROP COLUMN qtysold CASCADE;

-- Can not drop lookup table.
DROP TABLE tickit_sales_redshift CASCADE;

-- Change session to security administrator bob.
SET SESSION AUTHORIZATION bob;

DROP RLS POLICY policy_concerts;
DROP RLS POLICY IF EXISTS policy_events;

ALTER TABLE tickit_category_redshift ROW LEVEL SECURITY OFF;

RESET SESSION AUTHORIZATION;

-- Drop users and roles.
DROP USER bob;
DROP USER alice;
DROP USER joe;
DROP USER molly;
DROP USER bruce;
DROP ROLE analyst;
DROP ROLE consumer;
DROP ROLE auditor FORCE;
DROP ROLE dbadmin FORCE;
