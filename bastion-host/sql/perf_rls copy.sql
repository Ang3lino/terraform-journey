
-- Loading step...
CREATE TABLE public.category (                 
     catid smallint NOT NULL ENCODE raw distkey,
     catgroup character varying(10) ENCODE lzo, 
     catname character varying(10) ENCODE lzo,  
     catdesc character varying(50) ENCODE lzo   
);


truncate category;
COPY category FROM 's3://tf-angelttv-datalake/category/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

-- ALTER TABLE category RENAME TO tickit_category_redshift;
-- ALTER TABLE sales RENAME TO tickit_sales_redshift;
-- ALTER TABLE event RENAME TO tickit_event_redshift;


CREATE OR REPLACE PROCEDURE run_query_n_times(n INTEGER, query TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    counter INTEGER := 0;  -- Initialize a counter variable
BEGIN
    -- Loop to run the query n times
    FOR counter IN 1..n LOOP
        EXECUTE query;
    END LOOP;
END;
$$;


select count(*) from category;
-- 11

CALL run_query_n_times(20, 'INSERT INTO category SELECT * FROM category;');
select count(*) from category; -- ~11M
--   count   
-- ----------
--  11534336


SET enable_result_cache_for_session TO off;  -- Amazon Redshift now ignores the results cache
SHOW enable_result_cache_for_session ;


SELECT catgroup, count(*) FROM category GROUP BY catgroup ORDER BY catgroup;

--  catgroup |  count  
-- ----------+---------
--  Concerts | 3145728
--  Shows    | 3145728
--  Sports   | 5242880
-- (3 rows)


SELECT * FROM svv_table_info;

--  database | schema | table_id |    table     |     encoded     | diststyle  |   sortkey1    | max_varchar | sortkey1_enc | sortkey_num | size | pct_used | empty | unsorted | stats_off | tbl_rows | skew_sortkey1 | skew_rows | estimated_ visible_rows | risk_event | vacuum_sort_benefit |        create_time         
-- ----------+--------+----------+--------------+-----------------+------------+---------------+-------------+--------------+-------------+------+----------+-------+----------+-----------+----------+---------------+-----------+----------- -------------+------------+---------------------+----------------------------
--  dev      | public |   106660 | credit_cards | Y, AUTO(ENCODE) | AUTO(EVEN) | AUTO(SORTKEY) |         256 |              |           0 |   34 |   0.0093 |     0 |          |      0.00 |  6291456 |               |           |           6291456 |            |                     | 2024-12-13 02:59:26.127869
--  dev      | public |   106673 | category     | Y               | KEY(catid) | AUTO(SORTKEY) |          50 |              |           0 |   52 |   0.0143 |     0 |          |      0.00 | 11534336 |               |      1.20 |           11534336 |            |                     | 2024-12-13 03:40:41.384417
-- (2 rows)

ALTER TABLE category RENAME TO tickit_category_redshift;


--- Apply RLS 
-- Creating users, granting permissions
-- ****************************************************************************

CREATE ROLE analyst;
CREATE ROLE consumer;
CREATE ROLE dbadmin;
CREATE ROLE auditor;

CREATE USER bob WITH PASSWORD 'Name_is_bob_1';
CREATE USER alice WITH PASSWORD 'Name_is_alice_1';
CREATE USER joe WITH PASSWORD 'Name_is_joe_1';
CREATE USER molly WITH PASSWORD 'Name_is_molly_1';
CREATE USER bruce WITH PASSWORD 'Name_is_bruce_1';

GRANT ROLE sys:secadmin TO bob;
GRANT ROLE analyst TO alice;
GRANT ROLE consumer TO joe;
GRANT ROLE dbadmin TO molly;
GRANT ROLE auditor TO bruce;

GRANT ALL ON TABLE tickit_category_redshift TO PUBLIC;
GRANT ALL ON TABLE tickit_sales_redshift TO PUBLIC;
GRANT ALL ON TABLE tickit_event_redshift TO PUBLIC;

CREATE SCHEMA target_schema;
GRANT ALL ON SCHEMA target_schema TO PUBLIC;

CREATE TABLE target_schema.target_event_table (LIKE tickit_event_redshift);
GRANT ALL ON TABLE target_schema.target_event_table TO PUBLIC;


-- Change session to security administrator bob.
SET SESSION AUTHORIZATION bob;

CREATE RLS POLICY policy_concerts
    WITH (catgroup VARCHAR(10))
    USING (catgroup = 'Concerts');

SELECT poldb, polname, polalias, polatts, polqual, polenabled, polmodifiedby 
    FROM svv_rls_policy 
    WHERE poldb = CURRENT_DATABASE();

ATTACH RLS POLICY policy_concerts ON tickit_category_redshift TO ROLE analyst, ROLE dbadmin;

ALTER TABLE tickit_category_redshift ROW LEVEL SECURITY ON;

SELECT * FROM svv_rls_attached_policy;

SELECT * FROM svl_user_info;

--     usename     | usesysid | usecreatedb | usesuper | usecatupd | useconnlimit | syslogaccess | sessiontimeout |        last_ddl_ts         | external_id 
-- ----------------+----------+-------------+----------+-----------+--------------+--------------+----------------+----------------------------+-------------
--  regular_user   |      101 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 02:59:26.555141 | 
--  bob            |      103 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 04:44:49.855559 | 
--  joe            |      105 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 04:44:49.918079 | 
--  bruce          |      107 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 04:44:49.981697 | 
--  awsuser        |      100 | t           | t        | f         | UNLIMITED    | UNRESTRICTED |              0 | 2024-12-12 21:41:17.200543 | 
--  analytics_user |      102 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 02:59:26.585139 | 
--  alice          |      104 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 04:44:49.88621  | 
--  molly          |      106 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 04:44:49.949702 | 
-- (8 rows)

SET SESSION AUTHORIZATION alice;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

SET SESSION AUTHORIZATION bob;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

SET SESSION AUTHORIZATION awsuser;

SELECT 
        userid 
        ,query 
        ,trim(label) AS label
        ,xid 
        ,pid 
        ,trim(database) AS db 
        ,starttime 
        ,endtime 
        ,aborted 
        ,insert_pristine 
        ,concurrency_scaling_status 
         ,trim(querytxt) 
    FROM stl_query
    WHERE userid <> 1
    ORDER BY starttime DESC
    LIMIT 10
;

 userid | query |  label  |  xid  |    pid     | db  |         starttime          |          endtime           | aborted | insert_pristine | concurrency_scaling_status |                                                                  btrim                                                                                                                   
--------+-------+---------+-------+------------+-----+----------------------------+----------------------------+---------+-----------------+----------------------------+------------------------------------------------------------------ ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    100 |  7114 | default | 52719 | 1073766631 | dev | 2024-12-13 04:49:23.714897 | 2024-12-13 04:49:23.788063 |       0 |               0 |                          6 | SELECT * FROM svl_user_info;
    103 |  7110 | default | 52717 | 1073766631 | dev | 2024-12-13 04:49:23.358952 | 2024-12-13 04:49:23.642048 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    104 |  7106 | default | 52715 | 1073766631 | dev | 2024-12-13 04:49:23.174728 | 2024-12-13 04:49:23.343153 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    100 |  7098 | default | 52675 | 1073766631 | dev | 2024-12-13 04:48:59.513813 | 2024-12-13 04:48:59.533787 |       0 |               0 |                          6 | SELECT userid ,query ,trim(label) AS label ,xid ,pid ,trim(databa se) AS db ,starttime ,endtime ,aborted ,insert_pristine ,concurrency_scaling_status ,trim(querytxt) FROM stl_query WHERE userid <> 1 ORDER BY starttime DESC LIMIT 10 ;
    103 |  7094 | default | 52673 | 1073766631 | dev | 2024-12-13 04:48:59.179835 | 2024-12-13 04:48:59.481975 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    104 |  7090 | default | 52671 | 1073766631 | dev | 2024-12-13 04:48:58.996612 | 2024-12-13 04:48:59.164851 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    103 |  7065 | default | 52411 | 1073766631 | dev | 2024-12-13 04:46:58.667673 | 2024-12-13 04:47:04.640711 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    104 |  7061 | default | 52409 | 1073766631 | dev | 2024-12-13 04:46:58.482528 | 2024-12-13 04:46:58.649854 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    104 |  7057 | default | 52378 | 1073766631 | dev | 2024-12-13 04:46:31.751052 | 2024-12-13 04:46:31.951389 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
    104 |  7034 | default | 52188 | 1073766631 | dev | 2024-12-13 04:45:05.075426 | 2024-12-13 04:45:10.349007 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
(10 rows)


select 
  userid
  , xid
  , query
  , service_class
  , service_class_start_time
  , service_class_end_time
  , total_queue_time
  , total_exec_time
from STL_WLM_QUERY 
  WHERE query IN (7110 ,7106)
;

--  userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
-- --------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
--     104 | 52715 |  7106 |           100 | 2024-12-13 04:49:23.175483 | 2024-12-13 04:49:23.342534 |                0 |          166595
--     103 | 52717 |  7110 |           100 | 2024-12-13 04:49:23.359719 | 2024-12-13 04:49:23.641373 |                0 |          281174
-- (2 rows)
