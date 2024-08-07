Extract Oracle DDLs of any version
---

#### Overview

The `extract_oracle_ddls_anyversion.sql` script is designed to extract DDL statements for various database objects such as tables, functions, packages, procedures, sequences, triggers, types, views, and materialized views from a specified schema in an Oracle database. This script is useful for database administrators and developers who need to capture the structure of database objects for documentation, migration, or backup purposes.

**Note:** 
* Wrapped functions are extracted as is, user has to unwrap to extract full definition
* Users,Roles, Grants, Comments are not extracted as part of the script. 

#### Script Information

- **File Name**: `extract_oracle_ddls_anyversion.sql`

- **Description**: Extracts the DDLs of TABLE (all), FUNCTION, PACKAGE, PACKAGE BODY, PROCEDURE, SEQUENCE, TRIGGER, TYPE, TYPE BODY, VIEW, and MVIEW.
- **SQL*Plus Documentation**: [SQL*Plus User's Guide and Reference](https://docs.oracle.com/cd/B10500_01/server.920/a90842.pdf)

#### Call Syntax

To execute the script, use the following command in SQL*Plus, replacing `(schema)` with the name of the schema for which you want to extract the DDLs:

```sql
@extract_oracle_ddls_anyversion.sql (schema)
```

#### Example Usage

```sh
SQL> @extract_oracle_ddls_anyversion.sql HR
```

In this example, `HR` is the schema for which the DDL statements will be extracted.

#### Script Features

- **Extracts DDL Statements**: Retrieves DDL statements for various object types, including:
  - Tables (all tables in the schema)
  - Functions
  - Packages
  - Package Bodies
  - Procedures
  - Sequences
  - Triggers
  - Types
  - Type Bodies
  - Views
  - Materialized Views (MVIEW)
- **Output**: The extracted DDL statements can be spooled to a file for later use.

#### Instructions

1. **Place the `extract_oracle_ddls_anyversion.sql` File**:
   Ensure the `extract_oracle_ddls_anyversion.sql` file is located in a directory accessible to your SQL*Plus session or provide the full path when running the script.

2. **Execute the Script in SQL*Plus**:
   Open SQL*Plus and run the script with the specified schema name as a parameter.

3. **Spool the Output (Optional)**:
   You can use the `SPOOL` command in SQL*Plus to capture the output of the script in a file. For example:

   ```sh
   SQL> SPOOL ddl_output.sql
   SQL> @extract_oracle_ddls_anyversion.sql HR
   SQL> SPOOL OFF
   ```

   This will save the extracted DDL statements to `ddl_output.sql`.

#### Notes

- Ensure you have the necessary privileges to access the schema and extract the DDL statements.
- Review the SQL*Plus documentation for additional options and details on running scripts.

This script simplifies the process of capturing the DDL statements for various database objects, making it easier to document, migrate, or backup your Oracle database schema.

### Author
Name: Raghavendra Rao
Email: ragavendra.dba@gmail.com
