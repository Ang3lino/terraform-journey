
-- Loading step...
CREATE TABLE public.category (                 
     catid smallint NOT NULL ENCODE raw distkey,
     catgroup character varying(10) ENCODE lzo, 
     catname character varying(10) ENCODE lzo,  
     catdesc character varying(50) ENCODE lzo   
);

CREATE TABLE public.sales (                         
    salesid integer NOT NULL ENCODE az64,           
    listid integer NOT NULL ENCODE az64 distkey,    
    sellerid integer NOT NULL ENCODE az64,          
    buyerid integer NOT NULL ENCODE az64,           
    eventid integer NOT NULL ENCODE az64,           
    dateid smallint NOT NULL ENCODE raw,            
    qtysold smallint NOT NULL ENCODE az64,          
    pricepaid numeric(8,2) ENCODE az64,             
    commission numeric(8,2) ENCODE az64,            
    saletime timestamp without time zone ENCODE az64
);

CREATE TABLE public.event (                          
    eventid integer NOT NULL ENCODE az64 distkey,    
    venueid smallint NOT NULL ENCODE az64,           
    catid smallint NOT NULL ENCODE az64,             
    dateid smallint NOT NULL ENCODE raw,             
    eventname character varying(200) ENCODE lzo,     
    starttime timestamp without time zone ENCODE az64
);

truncate category;
COPY category FROM 's3://tf-angelttv-datalake/category/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

COPY sales FROM 's3://tf-angelttv-datalake/sales/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

COPY event FROM 's3://tf-angelttv-datalake/event/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

-- ALTER TABLE category RENAME TO tickit_category_redshift;
-- ALTER TABLE sales RENAME TO tickit_sales_redshift;
-- ALTER TABLE event RENAME TO tickit_event_redshift;


select count(*) from category;
-- 11

INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;

INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;

INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;

INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;
INSERT INTO category SELECT * FROM category;

select count(*) from category;
-- 720896

SET enable_result_cache_for_session TO off;  -- Amazon Redshift now ignores the results cache
SHOW enable_result_cache_for_session ;


-- QID
SELECT catgroup, count(*) FROM category
GROUP BY catgroup ORDER BY catgroup;

--  catgroup | count  
-- ----------+--------
--  Concerts | 196608
--  Shows    | 196608
--  Sports   | 327680
-- (3 rows)


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

--  userid | query |  label  |  xid  |    pid     | db  |         starttime          |          endtime           | aborted | insert_pristine | concurrency_scaling_status |                                                                                                              btrim                              
-- --------+-------+---------+-------+------------+-----+----------------------------+----------------------------+---------+-----------------+----------------------------+------------------------------------------------------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------
--     100 |  3732 | default | 17843 | 1073881372 | dev | 2024-12-10 23:39:34.387765 | 2024-12-10 23:39:34.405159 |       0 |               0 |                          6 | SELECT userid ,query ,trim(label) AS label ,xid ,pid ,trim(database) AS db ,starttime ,endtime ,aborted ,insert_pristine ,concurrency_scaling_st atus ,trim(querytxt) FROM stl_query WHERE userid <> 1 ORDER BY pid, starttime ;
--     100 |  3727 | default | 17821 | 1073881372 | dev | 2024-12-10 23:39:18.274936 | 2024-12-10 23:39:18.293663 |       0 |               0 |                          6 | SELECT * FROM stl_query WHERE userid <> 1 ORDER BY starttime DESC LIMIT 10;
--     100 |  3724 | default | 17802 | 1073881372 | dev | 2024-12-10 23:38:58.391097 | 2024-12-10 23:39:04.454623 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM category GROUP BY catgroup ORDER BY catgroup;


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
  WHERE query IN (3724)
;

--  userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
-- --------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
--     100 | 17802 |  3724 |           100 | 2024-12-10 23:38:58.392392 | 2024-12-10 23:39:04.453746 |                0 |         6056217

select userid, query, elapsed, source_query from svl_qlog 
where userid > 1
and query = 3724 
order by query desc;

--  userid | query | elapsed | source_query                                                                                                                                                    --------+-------+---------+--------------
--     100 |  3724 | 6063526 |             
-- (1 row)


SELECT * FROM svv_table_info;

--  database | schema | table_id |         table         | encoded |  diststyle   |   sortkey1    | max_varchar | sortkey1_enc | sortkey_num | size | pct_used | empty | unsorted | stats_off | tbl_rows | skew_sortkey1 | skew_rows | estimated_visible_rows | risk_event | vacuum_sort_benefit |        create_time         
-- ----------+--------+----------+-----------------------+---------+--------------+---------------+-------------+--------------+-------------+------+----------+-------+----------+-----------+ ----------+---------------+-----------+------------------------+------------+---------------------+----------------------------
--  dev      | public |   106664 | tickit_event_redshift | Y       | KEY(eventid) | AUTO(SORTKEY) |         200 |              |           0 |   18 |   0.0049 |     0 |          |      0.00 | 8798 |               |      1.01 |                   8798 |            |                     | 2024-12-10 21:56:19.303883
--  dev      | public |   106662 | tickit_sales_redshift | Y       | KEY(listid)  | AUTO(SORTKEY) |           0 |              |           0 |   26 |   0.0071 |     0 |          |      0.00 | 172456 |               |      1.01 |                 172456 |            |                     | 2024-12-10 21:56:19.266247
--  dev      | public |   106660 | category              | Y       | KEY(catid)   | AUTO(SORTKEY) |          50 |              |           0 |   14 |   0.0038 |     0 |          |    100.00 | 720896 |               |      1.20 |                 720896 |            |                     | 2024-12-10 21:56:19.205739
-- (3 rows)


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

--  userid | query |  label  |  xid  |    pid     | db  |         starttime          |          endtime           | aborted | insert_pristine | concurrency_scaling_status |                   btrim                                                                                        
-- --------+-------+---------+-------+------------+-----+----------------------------+----------------------------+---------+-----------------+----------------------------+------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ---------------------------
--     102 |  3955 | default | 19776 | 1073881372 | dev | 2024-12-10 23:55:24.509284 | 2024-12-10 23:55:29.858691 |       0 |               0 |                         19 | SELECT catgroup, c ount(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     100 |  3845 | default | 18895 | 1073881372 | dev | 2024-12-10 23:48:01.504655 | 2024-12-10 23:48:08.245752 |       0 |               0 |                          6 | select userid , xi d , query , service_class , service_class_start_time , service_class_end_time , total_queue_time , total_exec_time from STL_WLM_QUERY WHERE query IN (3724) ;
--     100 |  3786 | default | 18278 | 1073881372 | dev | 2024-12-10 23:42:45.010259 | 2024-12-10 23:42:45.443704 |       0 |               0 |                          6 | SELECT * FROM svv_ table_info;


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
  WHERE query IN (3955 )
;

--  userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
-- --------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
--     102 | 19776 |  3955 |           100 | 2024-12-10 23:55:24.510629 | 2024-12-10 23:55:29.858033 |                0 |         5344827
-- (1 row)


-- Comparing both
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
  WHERE query IN (3724, 3955)
;

select userid, query, elapsed, source_query from svl_qlog 
where userid > 1
and query IN (3724, 3955)
order by query desc;


reset session AUTHORIZATION;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

set session AUTHORIZATION alice;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

reset session AUTHORIZATION;
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
where
userid <> 1
order by service_class_start_time desc 
limit 10
;

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
         ,trim(querytxt) as querytxt
    FROM stl_query
    WHERE userid <> 1
        AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
    ORDER BY starttime DESC, userid
    LIMIT 10
;

--  userid | query |  label  |  xid  |    pid     | db  |         starttime          |          endtime           | aborted | insert_pristine | concurrency_scaling_status |                                           querytxt                                           
-- --------+-------+---------+-------+------------+-----+----------------------------+----------------------------+---------+-----------------+----------------------------+----------------------------------------------------------------------------------------------
--     102 |  4109 | default | 20931 | 1073881372 | dev | 2024-12-11 00:04:40.615797 | 2024-12-11 00:04:40.641496 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     102 |  4106 | default | 20930 | 1073881372 | dev | 2024-12-11 00:04:40.577114 | 2024-12-11 00:04:40.600723 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     102 |  4103 | default | 20929 | 1073881372 | dev | 2024-12-11 00:04:40.537403 | 2024-12-11 00:04:40.561803 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     102 |  4100 | default | 20928 | 1073881372 | dev | 2024-12-11 00:04:40.386413 | 2024-12-11 00:04:40.522143 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     100 |  4088 | default | 20872 | 1073881372 | dev | 2024-12-11 00:04:18.301306 | 2024-12-11 00:04:18.339752 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     100 |  4085 | default | 20871 | 1073881372 | dev | 2024-12-11 00:04:18.236467 | 2024-12-11 00:04:18.282042 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     100 |  4082 | default | 20870 | 1073881372 | dev | 2024-12-11 00:04:18.121834 | 2024-12-11 00:04:18.221301 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     100 |  4079 | default | 20849 | 1073881372 | dev | 2024-12-11 00:04:02.199884 | 2024-12-11 00:04:07.332246 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     102 |  3955 | default | 19776 | 1073881372 | dev | 2024-12-10 23:55:24.509284 | 2024-12-10 23:55:29.858691 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
--     100 |  2233 | default |  7816 | 1073897604 | dev | 2024-12-10 22:15:55.341021 | 2024-12-10 22:15:55.462163 |       0 |               0 |                         19 | SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
-- (10 rows)


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
where
userid <> 1
and query in (
    SELECT 
            query 
        FROM stl_query
        WHERE userid <> 1
            AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 8
)
order by service_class_start_time desc 
limit 10
;

 userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
--------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
    102 | 20931 |  4109 |           100 | 2024-12-11 00:04:40.616572 | 2024-12-11 00:04:40.640826 |                0 |           23818
    102 | 20930 |  4106 |           100 | 2024-12-11 00:04:40.577828 | 2024-12-11 00:04:40.599977 |                0 |           21719
    102 | 20929 |  4103 |           100 | 2024-12-11 00:04:40.53814  | 2024-12-11 00:04:40.561117 |                0 |           22545
    102 | 20928 |  4100 |           100 | 2024-12-11 00:04:40.387119 | 2024-12-11 00:04:40.52149  |                0 |          133933
    100 | 20872 |  4088 |           100 | 2024-12-11 00:04:18.302531 | 2024-12-11 00:04:18.339003 |                0 |           35716
    100 | 20871 |  4085 |           100 | 2024-12-11 00:04:18.237285 | 2024-12-11 00:04:18.28129  |                0 |           43561
    100 | 20870 |  4082 |           100 | 2024-12-11 00:04:18.122541 | 2024-12-11 00:04:18.220624 |                0 |           97470
    100 | 20849 |  4079 |           100 | 2024-12-11 00:04:02.201175 | 2024-12-11 00:04:07.331389 |                0 |         5127020
(8 rows)

select userid
    , avg(total_exec_time) as avg_total_exec_time 
    from STL_WLM_QUERY
where userid <> 1
and query in (
    SELECT query FROM stl_query
        WHERE userid <> 1 AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 8
)
group by userid
;

--  userid | avg_total_exec_time 
-- --------+---------------------
--     100 |             1325941
--     102 |               50503
-- (2 rows)



reset session AUTHORIZATION;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

set session AUTHORIZATION alice;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

reset session AUTHORIZATION;

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
where
userid <> 1
and query in (
    SELECT 
            query 
        FROM stl_query
        WHERE userid <> 1
            AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 20
)
order by service_class_start_time desc 
;

select userid
    , avg(total_exec_time) as avg_total_exec_time 
from STL_WLM_QUERY
where userid <> 1
and query in (
    SELECT query FROM stl_query
        WHERE userid <> 1 AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 20
) group by userid ;

--  userid | avg_total_exec_time 
-- --------+---------------------
--     100 |              563353
--     102 |               27030
-- (2 rows)



reset session AUTHORIZATION;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

set session AUTHORIZATION alice;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

reset session AUTHORIZATION;

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
where
userid <> 1
and query in (
    SELECT 
            query 
        FROM stl_query
        WHERE userid <> 1
            AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 40
)
order by service_class_start_time desc 
;

--  userid |  xid  | query | service_class |  service_class_start_time  |   service_class_end_time   | total_queue_time | total_exec_time 
-- --------+-------+-------+---------------+----------------------------+----------------------------+------------------+-----------------
--     102 | 26141 |  4870 |           100 | 2024-12-11 00:47:31.57959  | 2024-12-11 00:47:31.608112 |                0 |           28040
--     102 | 26140 |  4867 |           100 | 2024-12-11 00:47:31.540098 | 2024-12-11 00:47:31.562859 |                0 |           22233
--     102 | 26139 |  4864 |           100 | 2024-12-11 00:47:31.500452 | 2024-12-11 00:47:31.523778 |                0 |           22847
--     102 | 26138 |  4861 |           100 | 2024-12-11 00:47:31.461204 | 2024-12-11 00:47:31.483491 |                0 |           21725
--     102 | 26137 |  4858 |           100 | 2024-12-11 00:47:31.423504 | 2024-12-11 00:47:31.445139 |                0 |           21166
--     102 | 26136 |  4855 |           100 | 2024-12-11 00:47:31.385839 | 2024-12-11 00:47:31.407244 |                0 |           20934
--     102 | 26135 |  4852 |           100 | 2024-12-11 00:47:31.348002 | 2024-12-11 00:47:31.369669 |                0 |           21137
--     102 | 26134 |  4849 |           100 | 2024-12-11 00:47:31.309633 | 2024-12-11 00:47:31.332146 |                0 |           22047
--     102 | 26133 |  4846 |           100 | 2024-12-11 00:47:31.271041 | 2024-12-11 00:47:31.293371 |                0 |           21686
--     102 | 26132 |  4843 |           100 | 2024-12-11 00:47:31.230754 | 2024-12-11 00:47:31.254307 |                0 |           23070
--     102 | 26131 |  4840 |           100 | 2024-12-11 00:47:31.191825 | 2024-12-11 00:47:31.214755 |                0 |           22369
--     102 | 26130 |  4837 |           100 | 2024-12-11 00:47:31.152427 | 2024-12-11 00:47:31.175001 |                0 |           22100
--     102 | 26129 |  4834 |           100 | 2024-12-11 00:47:31.115272 | 2024-12-11 00:47:31.136327 |                0 |           20608
--     102 | 26128 |  4831 |           100 | 2024-12-11 00:47:31.078034 | 2024-12-11 00:47:31.099849 |                0 |           21327
--     102 | 26127 |  4828 |           100 | 2024-12-11 00:47:31.03848  | 2024-12-11 00:47:31.062199 |                0 |           23259
--     102 | 26126 |  4825 |           100 | 2024-12-11 00:47:30.988744 | 2024-12-11 00:47:31.015773 |                0 |           26571
--     102 | 26125 |  4822 |           100 | 2024-12-11 00:47:30.951258 | 2024-12-11 00:47:30.973329 |                0 |           21599
--     102 | 26124 |  4819 |           100 | 2024-12-11 00:47:30.912719 | 2024-12-11 00:47:30.934962 |                0 |           21783
--     102 | 26123 |  4816 |           100 | 2024-12-11 00:47:30.872943 | 2024-12-11 00:47:30.896653 |                0 |           23244
--     102 | 26122 |  4813 |           100 | 2024-12-11 00:47:30.833781 | 2024-12-11 00:47:30.856652 |                0 |           22390
--     100 | 26120 |  4809 |           100 | 2024-12-11 00:47:30.782187 | 2024-12-11 00:47:30.814904 |                0 |           31917
--     100 | 26119 |  4806 |           100 | 2024-12-11 00:47:30.729604 | 2024-12-11 00:47:30.761375 |                0 |           31289
--     100 | 26118 |  4803 |           100 | 2024-12-11 00:47:30.685201 | 2024-12-11 00:47:30.713618 |                0 |           27930
--     100 | 26117 |  4800 |           100 | 2024-12-11 00:47:30.640872 | 2024-12-11 00:47:30.669343 |                0 |           27988
--     100 | 26116 |  4797 |           100 | 2024-12-11 00:47:30.597254 | 2024-12-11 00:47:30.625187 |                0 |           27465
--     100 | 26115 |  4794 |           100 | 2024-12-11 00:47:30.552367 | 2024-12-11 00:47:30.581217 |                0 |           28305
--     100 | 26114 |  4791 |           100 | 2024-12-11 00:47:30.506916 | 2024-12-11 00:47:30.536102 |                0 |           28703
--     100 | 26113 |  4788 |           100 | 2024-12-11 00:47:30.453844 | 2024-12-11 00:47:30.491044 |                0 |           36513
--     100 | 26112 |  4785 |           100 | 2024-12-11 00:47:30.375203 | 2024-12-11 00:47:30.428689 |                0 |           53015
--     100 | 26111 |  4782 |           100 | 2024-12-11 00:47:30.326612 | 2024-12-11 00:47:30.359543 |                0 |           32188
--     100 | 26110 |  4779 |           100 | 2024-12-11 00:47:30.272664 | 2024-12-11 00:47:30.305554 |                0 |           32411
--     100 | 26109 |  4776 |           100 | 2024-12-11 00:47:30.228863 | 2024-12-11 00:47:30.256548 |                0 |           27138
--     100 | 26108 |  4773 |           100 | 2024-12-11 00:47:30.18596  | 2024-12-11 00:47:30.213687 |                0 |           27186
--     100 | 26107 |  4770 |           100 | 2024-12-11 00:47:30.143664 | 2024-12-11 00:47:30.17084  |                0 |           26708
--     100 | 26106 |  4767 |           100 | 2024-12-11 00:47:30.097151 | 2024-12-11 00:47:30.125125 |                0 |           27501
--     100 | 26105 |  4764 |           100 | 2024-12-11 00:47:30.052811 | 2024-12-11 00:47:30.081116 |                0 |           27831
--     100 | 26104 |  4761 |           100 | 2024-12-11 00:47:30.010125 | 2024-12-11 00:47:30.037111 |                0 |           26515
--     100 | 26103 |  4758 |           100 | 2024-12-11 00:47:29.966758 | 2024-12-11 00:47:29.994289 |                0 |           27065
--     100 | 26102 |  4755 |           100 | 2024-12-11 00:47:29.919569 | 2024-12-11 00:47:29.950878 |                0 |           30845
--     100 | 26101 |  4752 |           100 | 2024-12-11 00:47:29.778995 | 2024-12-11 00:47:29.902543 |                0 |          122664

select userid
    , avg(total_exec_time) as avg_total_exec_time 
from STL_WLM_QUERY
where userid <> 1
and query in (
    SELECT query FROM stl_query
        WHERE userid <> 1 AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 40
) group by userid ;

--  userid | avg_total_exec_time 
-- --------+---------------------
--     100 |               35058
--     102 |               22506
-- (2 rows)


set session AUTHORIZATION bob;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

set session AUTHORIZATION alice;

SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;
SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;

reset session AUTHORIZATION;


create or replace view v_temp as 
    SELECT 
            query 
        FROM stl_query
        WHERE userid in (101, 102)
            AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup;'
        ORDER BY starttime DESC, userid
        LIMIT 80;

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
where
userid <> 1
and query in ( select * from v_temp)
order by service_class_start_time desc 
;

select userid
    , avg(total_exec_time) as avg_total_exec_time 
from STL_WLM_QUERY
where userid <> 1
and query in (select * from v_temp) group by userid ;

--  userid | avg_total_exec_time 
-- --------+---------------------
--     102 |               23120
--     101 |               29186
-- (2 rows)

select * from svl_user_info;

 usename | usesysid | usecreatedb | usesuper | usecatupd | useconnlimit | syslogaccess | sessiontimeout |        last_ddl_ts         | external_id 
---------+----------+-------------+----------+-----------+--------------+--------------+----------------+----------------------------+-------------
 awsuser |      100 | t           | t        | f         | UNLIMITED    | UNRESTRICTED |              0 | 2024-12-10 21:21:04.941681 | 
 bob     |      101 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-10 23:55:07.657123 | 
 alice   |      102 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-10 23:55:07.686184 | 
 joe     |      103 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-10 23:55:07.716913 | 
 molly   |      104 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-10 23:55:07.747399 | 
 bruce   |      105 | f           | f        | f         | UNLIMITED    | RESTRICTED   |              0 | 2024-12-10 23:55:07.77943  | 
(6 rows)

-- -- n <- 100
-- set session AUTHORIZATION bob;
-- call run_query_multiple_times(100);

-- set session authorization alice;
-- call run_query_multiple_times(100);

-- reset session authorization;
-- select * from svl_user_info;


-- CREATE OR REPLACE PROCEDURE run_query_multiple_times(n INTEGER)
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     i INTEGER;
-- BEGIN
--     -- Run the query n times
--     FOR i IN 1..n LOOP
--         -- Execute the query (this will just run the query to count catgroup occurrences)
--         EXECUTE 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup';
--     END LOOP;
-- END;
-- $$;



-- CREATE OR REPLACE VIEW v_temp AS
-- SELECT 
--     query
-- FROM stl_query
-- WHERE 
--     userid in (101, 102)
--     -- userid <> 1
--     AND querytxt = 'SELECT catgroup, count(*) FROM tickit_category_redshift GROUP BY catgroup ORDER BY catgroup'
-- ORDER BY starttime DESC, userid
-- LIMIT 200; -- Capture the most recent 2*n occurrences

-- select 
--   userid , xid , query , service_class
--   , service_class_start_time , service_class_end_time
--   , total_queue_time , total_exec_time
-- from STL_WLM_QUERY 
-- where userid <> 1 and query in ( select * from v_temp)
-- order by service_class_start_time desc 
-- ;

-- select userid, avg(total_exec_time) as avg_total_exec_time 
-- from STL_WLM_QUERY
-- where userid <> 1
-- and query in (select * from v_temp) group by userid ;

