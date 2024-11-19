

-- **************************************************************************************************************************************************
-- Creating a masking policy 
-- **************************************************************************************************************************************************

CREATE TABLE credit_cards (
  customer_id INT,
  credit_card TEXT
);

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


-- **************************************************************************************************************************************************
-- CREATE MASK POLICY AND ATTACH TO THEM 
-- **************************************************************************************************************************************************

RESET SESSION AUTHORIZATION;

-- create a masking policy that fully masks the credit card number
CREATE MASKING POLICY mask_credit_card_full
WITH (credit_card VARCHAR(256))
USING ('000000XXXX0000'::TEXT);

-- create a user-defined function that partially obfuscates credit card data
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

-- Create a masking policy that applies the REDACT_CREDIT_CARD function
CREATE MASKING POLICY mask_credit_card_partial
WITH (credit_card VARCHAR(256))
USING (REDACT_CREDIT_CARD(credit_card));

-- Confirm the masking policies using the associated system views
SELECT * FROM svv_masking_policy;

--  policy_database |       policy_name        |                        input_columns                        |                                              policy_expression                                              | policy_modified_by | policy_modified_time
-- -----------------+--------------------------+-------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------+--------------------+----------------------
--  dev             | mask_credit_card_full    | [{"colname":"credit_card","type":"character varying(256)"}] | [{"expr":"CAST('000000XXXX0000' AS VARCHAR)","type":"character varying"}]                                   | awsuser            | 2024-11-14 21:57:43
--  dev             | mask_credit_card_partial | [{"colname":"credit_card","type":"character varying(256)"}] | [{"expr":"\"public\".\"redact_credit_card\"(\"masked_table\".\"credit_card\")","type":"character varying"}] | awsuser            | 2024-11-14 21:57:50
-- (2 rows)

SELECT * FROM svv_attached_masking_policy;   

--  policy_name | schema_name | table_name | table_type | grantor | grantee | grantee_type | priority | input_columns | output_columns
-- -------------+-------------+------------+------------+---------+---------+--------------+----------+---------------+----------------
-- (0 rows)


--attach mask_credit_card_full to the credit card table as the default policy
--all users will see this masking policy unless a higher priority masking policy is attached to them or their role
ATTACH MASKING POLICY mask_credit_card_full
ON credit_cards(credit_card)
TO PUBLIC;

--attach mask_credit_card_partial to the analytics role
--users with the analytics role can see partial credit card information
ATTACH MASKING POLICY mask_credit_card_partial
ON credit_cards(credit_card)
TO ROLE analytics_role
PRIORITY 10;

--confirm the masking policies are applied to the table and role in the associated system view
SELECT * FROM svv_attached_masking_policy;

--        policy_name        | schema_name |  table_name  | table_type | grantor |    grantee     | grantee_type | priority |  input_columns  | output_columns
-- --------------------------+-------------+--------------+------------+---------+----------------+--------------+----------+-----------------+-----------------
--  mask_credit_card_full    | public      | credit_cards | table      | awsuser | public         | public       |        0 | ["credit_card"] | ["credit_card"]
--  mask_credit_card_partial | public      | credit_cards | table      | awsuser | analytics_role | role         |       10 | ["credit_card"] | ["credit_card"]
-- (2 rows)

--confirm the full masking policy is in place for normal users by selecting from the credit card table as regular_user
SET SESSION AUTHORIZATION regular_user;
SELECT * FROM credit_cards;

--  customer_id |  credit_card
-- -------------+----------------
--          100 | 000000XXXX0000
--          100 | 000000XXXX0000
--          102 | 000000XXXX0000
--          102 | 000000XXXX0000
--          102 | 000000XXXX0000
--          103 | 000000XXXX0000
-- (6 rows)

--confirm the partial masking policy is in place for users with the analytics role by selecting from the credit card table as analytics_user
SET SESSION AUTHORIZATION analytics_user;
SELECT * FROM credit_cards;

--  customer_id |   credit_card
-- -------------+-----------------
--          100 | 453299XXXXX4842
--          100 | 471600XXXXX5888
--          102 | 524311XXXXX2649
--          102 | 601172XXXXX4675
--          102 | 601137XXXXX9710
--          103 | 373611XXXXX5635
-- (6 rows)


-- **************************************************************************************************************************************************
-- ATTACHING MASK POLICY 
-- **************************************************************************************************************************************************

--attach mask_credit_card_full to the credit card table as the default policy
--all users will see this masking policy unless a higher priority masking policy is attached to them or their role
ATTACH MASKING POLICY mask_credit_card_full
ON credit_cards(credit_card)
TO PUBLIC;

--attach mask_credit_card_partial to the analytics role
--users with the analytics role can see partial credit card information
ATTACH MASKING POLICY mask_credit_card_partial
ON credit_cards(credit_card)
TO ROLE analytics_role
PRIORITY 10;

--confirm the masking policies are applied to the table and role in the associated system view
SELECT * FROM svv_attached_masking_policy;

--        policy_name        | schema_name |  table_name  | table_type | grantor |    grantee     | grantee_type | priority |  input_columns  | output_columns
-- --------------------------+-------------+--------------+------------+---------+----------------+--------------+----------+-----------------+-----------------
--  mask_credit_card_full    | public      | credit_cards | table      | awsuser | public         | public       |        0 | ["credit_card"] | ["credit_card"]
--  mask_credit_card_partial | public      | credit_cards | table      | awsuser | analytics_role | role         |       10 | ["credit_card"] | ["credit_card"]
-- (2 rows)

--confirm the full masking policy is in place for normal users by selecting from the credit card table as regular_user
SET SESSION AUTHORIZATION regular_user;
SELECT * FROM credit_cards;

--  customer_id |  credit_card
-- -------------+----------------
--          100 | 000000XXXX0000
--          100 | 000000XXXX0000
--          102 | 000000XXXX0000
--          102 | 000000XXXX0000
--          102 | 000000XXXX0000
--          103 | 000000XXXX0000
-- (6 rows)

--confirm the partial masking policy is in place for users with the analytics role by selecting from the credit card table as analytics_user
SET SESSION AUTHORIZATION analytics_user;
SELECT * FROM credit_cards;

--  customer_id |   credit_card
-- -------------+-----------------
--          100 | 453299XXXXX4842
--          100 | 471600XXXXX5888
--          102 | 524311XXXXX2649
--          102 | 601172XXXXX4675
--          102 | 601137XXXXX9710
--          103 | 373611XXXXX5635
-- (6 rows)

-- **************************************************************************************************************************************************
-- ALTERING MASK POLICY
-- **************************************************************************************************************************************************

--reset session authorization to the default
RESET SESSION AUTHORIZATION;

--alter the mask_credit_card_full policy
ALTER MASKING POLICY mask_credit_card_full USING ('00000000000000'::TEXT);	
	
--confirm the full masking policy is in place after altering the policy, and that results are altered from '000000XXXX0000' to '00000000000000'
SELECT * FROM credit_cards;

--  customer_id |  credit_card
-- -------------+----------------
--          100 | 00000000000000
--          100 | 00000000000000
--          102 | 00000000000000
--          102 | 00000000000000
--          102 | 00000000000000
--          103 | 00000000000000
-- (6 rows)


-- **************************************************************************************************************************************************
-- Detaching and dropping a masking policy
-- **************************************************************************************************************************************************

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


