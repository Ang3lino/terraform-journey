
UNLOAD (
    'SELECT * FROM "sample_data_dev"."tickit"."event" '
) TO 's3://tf-angelttv-datalake/event/'
    IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
    PARALLEL OFF -- output in one file
    ALLOWOVERWRITE 
    CSV
;

UNLOAD (
    'SELECT * FROM "sample_data_dev"."tickit"."category" '
) TO 's3://tf-angelttv-datalake/category/'
    IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
    PARALLEL OFF -- output in one file
    ALLOWOVERWRITE 
    CSV
;

UNLOAD (
    'SELECT * FROM "sample_data_dev"."tickit"."sales" '
) TO 's3://tf-angelttv-datalake/sales/'
    IAM_ROLE 'arn:aws:iam::343218182633:role/RedshiftAdminRole'
    PARALLEL OFF -- output in one file
    ALLOWOVERWRITE 
    CSV
;