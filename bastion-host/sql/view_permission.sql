
SET SESSION AUTHORIZATION awsuser;
CREATE SCHEMA admin;

CREATE OR REPLACE VIEW admin.v_get_obj_priv_by_user
AS
SELECT
    * 
FROM 
    (
    SELECT 
        schemaname
        ,objectname
        ,usename
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'select') AS sel
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'insert') AS ins
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'update') AS upd
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'delete') AS del
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'references') AS ref
    FROM
        (
        SELECT schemaname, 't' AS obj_type, tablename AS objectname, QUOTE_IDENT(schemaname) || '.' || QUOTE_IDENT(tablename) AS fullobj FROM pg_tables
        WHERE schemaname !~ '^information_schema|catalog_history|pg_'
        UNION
        SELECT schemaname, 'v' AS obj_type, viewname AS objectname, QUOTE_IDENT(schemaname) || '.' || QUOTE_IDENT(viewname) AS fullobj FROM pg_views
        WHERE schemaname !~ '^information_schema|catalog_history|pg_'
        ) AS objs
        ,(SELECT * FROM pg_user) AS usrs
    ORDER BY fullobj
    )
WHERE (sel = true or ins = true or upd = true or del = true or ref = true)
;

SELECT * FROM admin.v_get_obj_priv_by_user;
-- SELECT * FROM admin.v_get_obj_priv_by_user WHERE usename = 'alice';
