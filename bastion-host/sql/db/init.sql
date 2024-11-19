
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

COPY category FROM 's3://tf-angelttv-datalake/category/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

COPY sales FROM 's3://tf-angelttv-datalake/sales/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

COPY event FROM 's3://tf-angelttv-datalake/event/'
IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
CSV ;

ALTER TABLE category RENAME TO tickit_category_redshift;
ALTER TABLE sales RENAME TO tickit_sales_redshift;
ALTER TABLE event RENAME TO tickit_event_redshift;

-- CREATE OR REPLACE PROCEDURE unload_data_to_s3(
--     table_name IN VARCHAR,  -- Table name passed as argument
--     s3_prefix IN VARCHAR    -- Prefix for the S3 file name
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     unload_query TEXT;  -- Variable to hold the dynamic SQL query
-- BEGIN
--     -- Construct the dynamic query using || for concatenation
--     unload_query := 'UNLOAD (
--                         ''SELECT * FROM ' || quote_ident(table_name) || '''
--                     ) TO ''s3://tf-angelttv-datalake/' || s3_prefix || '_'' 
--                     IAM_ROLE ''arn:aws:iam::343218182633:role/RedshiftAdminRole''
--                     PARALLEL OFF
--                     ALLOWOVERWRITE
--                     DELIMITER '',''
--                     GZIP;';
--     RAISE NOTICE 'Executing query: %', unload_query;
--     EXECUTE unload_query;
--     RAISE NOTICE 'Data unloaded from table % to S3 with prefix %', table_name, s3_prefix;
-- END;
-- $$;
-- CALL unload_data_to_s3('category', 'category');