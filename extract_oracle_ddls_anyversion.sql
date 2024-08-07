-- -----------------------------------------------------------------------------------
-- File Name    : extract_oracle_ddls_anyversion.sql
-- Author       : Raghavendra Rao
-- Description  : Extracts the DDLs of TABLE(all),FUNCTION,PACKAGE,PACKAGE BODY,PROCEDURE
--              : SEQUENCE,TRIGGER,TYPE,TYPE BODY,VIEW,MVIEW 
-- Call Syntax  : @extract_oracle_ddls_anyversion.sql (schema)
-- Last Modified: 08 August,2024 
-- SQL*Plus link: https://docs.oracle.com/cd/B10500_01/server.920/a90842.pdf
-- -----------------------------------------------------------------------------------

-- Make up the SQLplus
set verify off
set serveroutput on
set feed off
set pagesize 0 tab off newp none emb on heading off feedback off verify off echo off trimspool on
set long 2000000000 linesize 32767
var v_ddl_beginner varchar2(30)
var v_ddl_terminator varchar2(30)
BEGIN
   :v_ddl_beginner := '--START_OF_DDL';
   :v_ddl_terminator := CHR(10) || '--END_OF_DDL';
END;
/

BEGIN
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',FALSE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE', FALSE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',FALSE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',FALSE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',FALSE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS',FALSE);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SIZE_BYTE_KEYWORD',   FALSE);
END;
/

prompt ########################################
prompt ## Oracle Version
prompt ########################################
select banner from v$version where rownum=1;

prompt ########################################
prompt ## SYNONYM
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('SYNONYM', synonym_name)
    || :v_ddl_terminator ddl
FROM
    dba_synonyms dba_syn 
WHERE
    dba_syn.owner = UPPER('&1')
ORDER BY
    synonym_name;

prompt ########################################
prompt ## DATABASE LINKS
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('DB_LINK', db_link)
    || :v_ddl_terminator ddl
FROM
    dba_db_links dba_lin
WHERE
    dba_lin.owner = UPPER('&1')
ORDER BY
    db_link;

prompt ########################################
prompt ## TYPE SPECIFICATION
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TYPE_SPEC', dba_obj.object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj
WHERE
    dba_obj.owner = UPPER('&1') 
    AND dba_obj.OBJECT_TYPE = 'TYPE' 
    AND dba_obj.OBJECT_NAME NOT LIKE 'SYS_%' 
    AND dba_obj.status = 'VALID'
ORDER BY 
    dba_obj.object_name;

prompt ########################################
prompt ## TYPE BODY
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TYPE_BODY', dba_obj.object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj 
WHERE
    dba_obj.owner = UPPER('&1') 
    AND dba_obj.OBJECT_TYPE = 'TYPE BODY'
    AND dba_obj.OBJECT_NAME NOT LIKE 'SYS_%' 
    AND dba_obj.status = 'VALID'
ORDER BY 
    dba_obj.object_name;

prompt ########################################
prompt ## SEQUENCES
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('SEQUENCE', sequence_name)
    || :v_ddl_terminator ddl
FROM
    dba_sequences dba_seq
WHERE
    dba_seq.sequence_owner = UPPER('&1')
    AND NOT EXISTS
        (SELECT
            object_name
        FROM
            dba_objects
        WHERE
            object_type='SEQUENCE'
        AND generated='Y'
        AND dba_objects.owner= dba_seq.SEQUENCE_OWNER 
        AND dba_objects.object_name=dba_seq.sequence_name) 
ORDER BY
   sequence_name;

prompt ########################################
prompt ## TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
        :v_ddl_beginner ||
        dbms_metadata.get_ddl('TABLE', dba_tab.table_name) ||:v_ddl_terminator ddl
FROM
    dba_tables dba_tab
WHERE
    dba_tab.owner = UPPER('&1')
    AND dba_tab.IOT_TYPE IS NULL
    AND dba_tab.CLUSTER_NAME IS NULL
    AND TRIM(dba_tab.CACHE) = 'N'
    AND dba_tab.COMPRESSION != 'ENABLED'
    AND TRIM(dba_tab.BUFFER_POOL) != 'KEEP'
    AND dba_tab.NESTED = 'NO'
    AND dba_tab.status = 'VALID'
    AND NOT EXISTS
        (SELECT
            object_name
        FROM
            dba_objects
        WHERE
            object_type = 'MATERIALIZED VIEW'
            AND owner = dba_tab.owner
            AND object_name=dba_tab.table_name)
ORDER BY
    dba_tab.table_name;

prompt ########################################
prompt ## PARTITION TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TABLE', dba_par.table_name) || :v_ddl_terminator ddl
FROM
    dba_part_tables dba_par,
    dba_tables dba_tab
WHERE
    dba_par.owner = UPPER('&1') 
    AND dba_par.status = 'VALID'
    AND TRIM(dba_tab.CACHE) = 'N'
    AND dba_tab.table_name = dba_par.table_name
    AND dba_tab.owner = UPPER('&1') 
    AND dba_par.table_name NOT LIKE 'BIN$%$_'
ORDER BY
    dba_par.table_name;

prompt ########################################
prompt ## CACHE TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TABLE', table_name) || :v_ddl_terminator ddl
FROM
    dba_tables dba_tab 
WHERE
    dba_tab.owner = UPPER('&1')
    AND trim(CACHE) = 'Y'
    AND dba_tab.status = 'VALID'
ORDER BY
    table_name;

prompt ########################################
prompt ## CLUSTER TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TABLE', table_name) ||:v_ddl_terminator ddl
FROM
    dba_tables dba_tab
WHERE
    dba_tab.owner = UPPER('&1') 
    AND CLUSTER_NAME IS NOT NULL
    AND dba_tab.status = 'VALID'
ORDER BY
    table_name;

prompt ########################################
prompt ## KEEP TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TABLE', table_name) || :v_ddl_terminator ddl
FROM
    dba_tables dba_tab 
WHERE
    dba_tab.owner = UPPER('&1')
    AND BUFFER_POOL != 'DEFAULT'
    AND dba_tab.status = 'VALID'
ORDER BY
    table_name;

prompt ########################################
prompt ## IOT TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
        :v_ddl_beginner ||
        dbms_metadata.get_ddl('TABLE', table_name) || :v_ddl_terminator ddl
FROM
    dba_tables dba_tab
WHERE
    dba_tab.owner = UPPER('&1') 
    AND IOT_TYPE IS NOT NULL 
    AND dba_tab.status = 'VALID'
    AND table_name NOT LIKE 'BIN$%$_'
ORDER BY
    table_name;

prompt ########################################
prompt ## COMPRESSED TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TABLE', table_name) || :v_ddl_terminator ddl
FROM
    dba_tables dba_tab
WHERE
    dba_tab.owner = UPPER('&1') 
    AND COMPRESSION = 'ENABLED'
    AND dba_tab.status = 'VALID'
ORDER BY
    table_name;

prompt ########################################
prompt ## EXTERNAL TABLE DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TABLE', table_name)
    || :v_ddl_terminator ddl
FROM
    dba_external_tables dba_ext
WHERE
    dba_ext.owner = UPPER('&1')
ORDER BY
    table_name;


prompt ########################################
prompt ## INDEXES DDL
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('INDEX', index_name)
    || :v_ddl_terminator ddl
FROM
    dba_indexes dba_ind
WHERE
    dba_ind.owner = UPPER('&1')
    AND generated = 'N'
    AND index_type != 'LOB'
    AND status != 'UNUSABLE'
    AND NOT EXISTS
        (SELECT
            constraint_name
        FROM
            dba_constraints
        WHERE
            owner=dba_ind.owner
			AND constraint_type IN('P','U')
			AND (dba_ind.index_name=dba_constraints.constraint_name
            OR dba_ind.index_name=dba_constraints.index_name))
    AND NOT EXISTS
        (SELECT
            object_name
        FROM
            dba_objects
        WHERE
            object_type = 'MATERIALIZED VIEW'
			AND owner = dba_ind.owner
			AND dba_objects.object_name=dba_ind.table_name)
    AND NOT EXISTS
        (SELECT
            queue_table
        FROM
            DBA_QUEUE_TABLES
        WHERE
            owner = dba_ind.owner
            AND queue_table = dba_ind.table_name)
    AND index_name NOT LIKE 'BIN$%$_'
ORDER BY
    index_name;


prompt ########################################
prompt ## CONSTRAINTS
prompt ########################################
Prompt ## Foreign Keys
Prompt ###############
prompt

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner || 
    CASE
    WHEN dc.generated = 'USER NAME' THEN
        dbms_metadata.get_ddl('REF_CONSTRAINT', dc.constraint_name)
    WHEN dc.generated = 'GENERATED NAME' THEN
        replace(dbms_metadata.get_ddl('REF_CONSTRAINT', dc.constraint_name),'ADD FOREIGN KEY','ADD CONSTRAINT "'||substr(dc.table_name,1,10)||'_'||substr(dcc.COLUMN_NAME,1,10)||'_FKEY'||'" FOREIGN KEY')
    END
    || :v_ddl_terminator ddl
FROM
    dba_constraints dc,
    dba_cons_columns dcc
WHERE
    dc.owner = UPPER('&1')
    AND dc.constraint_type = 'R'
    AND dc.constraint_name = dcc.constraint_name
    AND dcc.owner = UPPER('&1')
    AND dcc.position = 1
    AND dc.STATUS = 'ENABLED'
    AND dc.constraint_name NOT LIKE 'BIN$%$_'
ORDER BY
    dc.constraint_name;


prompt ########################################
prompt ## VIEWS
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('VIEW', dba_obj.object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj 
WHERE
    dba_obj.owner = UPPER('&1')
    AND dba_obj.object_type = 'VIEW'
    AND dba_obj.status = 'VALID'
ORDER BY 
    object_name;

prompt ########################################
prompt ## MATERIALIZED VIEWS
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('MATERIALIZED_VIEW', dba_obj.object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj 
WHERE
    dba_obj.owner = UPPER('&1') 
    AND STATUS = 'VALID' 
    AND dba_obj.object_type = 'MATERIALIZED VIEW'
ORDER BY 
    object_name;


prompt ########################################
prompt ## TRIGGERS
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('TRIGGER', object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj
WHERE
    dba_obj.owner = UPPER('&1')
    AND object_type = 'TRIGGER'
    AND dba_obj.status = 'VALID'
    AND object_name NOT LIKE 'BIN$%$_'
ORDER BY
    object_name;

prompt ########################################
prompt ## FUNCTIONS
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('FUNCTION', object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj
WHERE
    dba_obj.owner = UPPER('&1')
    AND object_type = 'FUNCTION'
    AND dba_obj.status = 'VALID'
ORDER BY
    object_name;

prompt ########################################
prompt ## PROCEDURES
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('PROCEDURE', object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj
WHERE
    dba_obj.owner = UPPER('&1')
    AND object_type = 'PROCEDURE'
    AND dba_obj.status = 'VALID'
ORDER BY
    object_name;


prompt ########################################
prompt ## PACKAGE SPECIFICATION
prompt ########################################


SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('PACKAGE_SPEC', object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj
WHERE
    dba_obj.owner = UPPER('&1')
    AND object_type = 'PACKAGE'
    AND dba_obj.status = 'VALID'
ORDER BY
    object_name;

prompt ########################################
prompt ## PACKAGE BODY
prompt ########################################

SELECT /*+ NOPARALLEL */
    :v_ddl_beginner ||
    dbms_metadata.get_ddl('PACKAGE_BODY', object_name)
    || :v_ddl_terminator ddl
FROM
    dba_objects dba_obj
WHERE
    dba_obj.owner = UPPER('&1')
    AND object_type = 'PACKAGE BODY'
    AND dba_obj.status = 'VALID'
ORDER BY
    object_name;


SELECT '## Extraction Completed: ' ||to_char(sysdate, 'DD-MM-YYYY HH24:MI:SS') EXTRACTION_TIME FROM dual;
prompt ####################################################################################################################################
