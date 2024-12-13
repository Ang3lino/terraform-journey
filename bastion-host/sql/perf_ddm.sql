
-- Creating a masking policy 
-- **************************************************************************************************************************************************

CREATE TABLE credit_cards (
  customer_id INT,
  credit_card TEXT
);

truncate credit_cards;
INSERT INTO credit_cards
VALUES
  (100, '4532993817514842'),
  (100, '4716002041425888'),
  (102, '5243112427642649'),
  (102, '6011720771834675'),
  (102, '6011378662059710'),
  (103, '373611968625635')
;

--run GRANT to grant permission to use the SELECT statement on the table
GRANT SELECT ON credit_cards TO PUBLIC;

--create two users
CREATE USER regular_user WITH PASSWORD '1234Test!';
CREATE USER analytics_user WITH PASSWORD '1234Test!';

--create the analytics_role role and grant it to analytics_user
--regular_user does not have a role
CREATE ROLE analytics_role;
GRANT ROLE analytics_role TO analytics_user;


CREATE OR REPLACE PROCEDURE run_insert_n_times(n INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    counter INTEGER := 0;  -- Initialize a counter variable
BEGIN
    -- Loop to run the query n times
    FOR counter IN 1..n LOOP
        INSERT INTO credit_cards SELECT * FROM credit_cards;
    END LOOP;
    COMMIT;
END;
$$;

call run_insert_n_times(20);
select count(*) from credit_cards;
--   count  
-- ---------
--  6291456
-- (1 row)


-- CREATE MASK POLICY AND ATTACH TO THEM 
-- **************************************************************************************************************************************************
RESET SESSION AUTHORIZATION;

-- create a masking policy that fully masks the credit card number
CREATE MASKING POLICY mask_credit_card_full
WITH (credit_card VARCHAR(256))
USING ('000000XXXX0000'::TEXT);

CREATE FUNCTION REDACT_CREDIT_CARD (credit_card TEXT)
RETURNS TEXT IMMUTABLE
AS $$
    import re
    regexp = re.compile("^([0-9]{6})[0-9]{5,6}([0-9]{4})")
    match = regexp.search(credit_card)
    if match != None:
        first = match.group(1)
        last = match.group(2)
    else:
        first = "000000"
        last = "0000"
    return "{}XXXXX{}".format(first, last)
$$ LANGUAGE plpythonu;

CREATE MASKING POLICY mask_credit_card_partial
WITH (credit_card VARCHAR(256))
USING (REDACT_CREDIT_CARD(credit_card));

SELECT * FROM svv_masking_policy;
SELECT * FROM svv_attached_masking_policy;   

ATTACH MASKING POLICY mask_credit_card_full
ON credit_cards(credit_card)
TO PUBLIC;

ATTACH MASKING POLICY mask_credit_card_partial
ON credit_cards(credit_card)
TO ROLE analytics_role
PRIORITY 10;

SELECT * FROM svv_attached_masking_policy;


-- Comparison test
-- *********************************************************************************
SET enable_result_cache_for_session TO off;  -- Amazon Redshift now ignores the results cache

--confirm the full masking policy is in place for normal users by selecting from the credit card table as regular_user
SET SESSION AUTHORIZATION regular_user;
SELECT * FROM credit_cards;

--confirm the partial masking policy is in place for users with the analytics role by selecting from the credit card table as analytics_user
SET SESSION AUTHORIZATION analytics_user;
SELECT * FROM credit_cards;

RESET SESSION AUTHORIZATION;
SELECT * FROM credit_cards;

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

--  userid | query |  label  |  xid  |    pid     | db  |         starttime          |          endtime           | aborted | insert_pristine | concurrency_scaling_status |                        btrim                        
-- --------+-------+---------+-------+------------+-----+----------------------------+----------------------------+---------+-----------------+----------------------------+-----------------------------------------------------
--     100 |  5921 | default | 41975 | 1073946753 | dev | 2024-12-13 03:20:50.510665 | 2024-12-13 03:20:53.038984 |       0 |               0 |                         19 | SELECT * FROM credit_cards;
--     102 |  5907 | default | 41869 | 1073946753 | dev | 2024-12-13 03:19:59.165962 | 2024-12-13 03:20:32.097104 |       0 |               0 |                          9 | SELECT * FROM credit_cards;
--     101 |  5903 | default | 41836 | 1073946753 | dev | 2024-12-13 03:19:31.743405 | 2024-12-13 03:19:34.422121 |       0 |               0 |                         19 | SELECT * FROM credit_cards;
-- ...

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
  WHERE query IN (5921 , 5907 , 5903)
  ORDER BY userid
;

--  userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
-- --------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
--     100 | 41975 |  5921 |           100 | 2024-12-13 03:20:50.511357 | 2024-12-13 03:20:53.038086 |                0 |         2525097
--     101 | 41836 |  5903 |           100 | 2024-12-13 03:19:31.744268 | 2024-12-13 03:19:34.421093 |                0 |         2675789
--     102 | 41869 |  5907 |           100 | 2024-12-13 03:19:59.167245 | 2024-12-13 03:20:32.095304 |                0 |        32927384
-- (3 rows)

select * from svl_user_info order by usesysid;

--     usename     | usesysid | usecreatedb | usesuper | usecatupd | useconnlimit | syslogaccess | sessiontimeout |        last_ddl_ts         | external_id 
-- ----------------+----------+-------------+----------+-----------+--------------+--------------+----------------+----------------------------+-------------
--  awsuser        |      100 | t           | t        | f         | UNLIMITED    | UNRESTRICTED |              0 | 2024-12-12 21:41:17.200543 | 
--  regular_user   |      101 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 02:59:26.555141 | 
--  analytics_user |      102 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-13 02:59:26.585139 | 
-- (3 rows)


--reset session authorization to the default
RESET SESSION AUTHORIZATION;

--detach both masking policies from the credit_cards table
DETACH MASKING POLICY mask_credit_card_full 
ON credit_cards(credit_card) 
FROM PUBLIC;

DETACH MASKING POLICY mask_credit_card_partial 
ON credit_cards(credit_card) 
FROM ROLE analytics_role;

--drop both masking policies
DROP MASKING POLICY mask_credit_card_full;
DROP MASKING POLICY mask_credit_card_partial; 

select * from credit_cards;


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

--  userid | query |  label  |  xid  |    pid     | db  |         starttime          |          endtime           | aborted | insert_pristine | concurrency_scaling_status |                                                                  btrim                                                                                                                   
-- --------+-------+---------+-------+------------+-----+----------------------------+----------------------------+---------+-----------------+----------------------------+------------------------------------------------------------------ ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--     100 |  6088 | default | 43606 | 1073946753 | dev | 2024-12-13 03:33:57.201263 | 2024-12-13 03:34:00.167047 |       0 |               0 |                         19 | select * from credit_cards;
--     100 |  5980 | default | 42513 | 1073946753 | dev | 2024-12-13 03:25:08.706251 | 2024-12-13 03:25:09.47718  |       0 |               0 |                          6 | select * from svl_user_info;
--     100 |  5955 | default | 42276 | 1073946753 | dev | 2024-12-13 03:23:19.983943 | 2024-12-13 03:23:26.212617 |       0 |               0 |                          6 | select userid , xid , query , service_class , service_class_start _time , service_class_end_time , total_queue_time , total_exec_time from STL_WLM_QUERY WHERE query IN (5921 , 5907 , 5903) ORDER BY userid ;
--     100 |  5934 | default | 42065 | 1073946753 | dev | 2024-12-13 03:21:45.241513 | 2024-12-13 03:21:50.752329 |       0 |               0 |                          6 | SELECT userid ,query ,trim(label) AS label ,xid ,pid ,trim(databa se) AS db ,starttime ,endtime ,aborted ,insert_pristine ,concurrency_scaling_status ,trim(querytxt) FROM stl_query WHERE userid <> 1 ORDER BY starttime DESC LIMIT 10 ;
--     100 |  5921 | default | 41975 | 1073946753 | dev | 2024-12-13 03:20:50.510665 | 2024-12-13 03:20:53.038984 |       0 |               0 |                         19 | SELECT * FROM credit_cards;
--     102 |  5907 | default | 41869 | 1073946753 | dev | 2024-12-13 03:19:59.165962 | 2024-12-13 03:20:32.097104 |       0 |               0 |                          9 | SELECT * FROM credit_cards;
--     101 |  5903 | default | 41836 | 1073946753 | dev | 2024-12-13 03:19:31.743405 | 2024-12-13 03:19:34.422121 |       0 |               0 |                         19 | SELECT * FROM credit_cards;
--     100 |  5737 | default | 40224 | 1073946753 | dev | 2024-12-13 03:06:16.659792 | 2024-12-13 03:06:16.668409 |       0 |               0 |                         19 | select count(*) from credit_cards;
--     100 |  5734 | default | 40219 | 1073946753 | dev | 2024-12-13 03:06:14.649715 | 2024-12-13 03:06:15.696234 |       0 |               0 |                          3 | INSERT INTO credit_cards SELECT * FROM credit_cards
--     100 |  5731 | default | 40219 | 1073946753 | dev | 2024-12-13 03:06:14.128131 | 2024-12-13 03:06:14.638956 |       0 |               0 |                          3 | INSERT INTO credit_cards SELECT * FROM credit_cards
-- (10 rows)


select 
  userid , xid , query
  , service_class , service_class_start_time , service_class_end_time
  , total_queue_time , total_exec_time
from STL_WLM_QUERY 
  WHERE query IN (5921 , 5907 , 5903, 6088)
  ORDER BY userid
;

--  userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
-- --------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
--     100 | 41975 |  5921 |           100 | 2024-12-13 03:20:50.511357 | 2024-12-13 03:20:53.038086 |                0 |         2525097
--     100 | 43606 |  6088 |           100 | 2024-12-13 03:33:57.202125 | 2024-12-13 03:34:00.166034 |                0 |         2961840
--     101 | 41836 |  5903 |           100 | 2024-12-13 03:19:31.744268 | 2024-12-13 03:19:34.421093 |                0 |         2675789
--     102 | 41869 |  5907 |           100 | 2024-12-13 03:19:59.167245 | 2024-12-13 03:20:32.095304 |                0 |        32927384
-- (4 rows)

