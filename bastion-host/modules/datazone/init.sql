

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
IAM_ROLE default
CSV ;

COPY sales FROM 's3://tf-angelttv-datalake/sales/'
IAM_ROLE default
CSV ;

COPY event FROM 's3://tf-angelttv-datalake/event/'
IAM_ROLE default
CSV ;