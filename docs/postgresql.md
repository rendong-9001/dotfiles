## Postgresql
### Select 
```sql
SELECT column1, column2
FROM table_name
WHERE condition
ORDER BY column1, column2;
```
### Insert
```sql
INSERT INTO table_name (column1, column2)
VALUES (value1, value2);
```
### Update
```sql
UPDATE table_name
SET column1 = value1, column2 = value2
WHERE condition;
```
### Delete
```sql
DELETE FROM table_name
WHERE condition;
```
### Return
```sql
INSERT INTO table_name (column1, column2)
VALUES (value1, value2)
RETURNING column1, column2;
```
### Copy 
```sql
COPY table_name (column1, column2)
FROM '/path/to/csv/file'
WITH (FORMAT csv);
```
### Case
```sql
SELECT column1,
       CASE
           WHEN condition1 THEN result1
           WHEN condition2 THEN result2
           ELSE result3
       END
FROM table_name;
```
### Join
```sql
SELECT a.column1, b.column2
FROM table1 a
JOIN table2 b ON a.common_column = b.common_column;
```
### Subquery
```sql
SELECT column1
FROM table_name
WHERE column2 = (SELECT column2
                 FROM another_table
                 WHERE condition);
```
### With
```sql
WITH cte_name AS (
    SELECT column1
    FROM table_name
    WHERE condition
)
SELECT column2
FROM cte_name;
```
### Using
```sql
DELETE FROM table1
USING table2
WHERE table1.id = table2.id;
```
### Window Function
```sql
SELECT column1,
       ROW_NUMBER() OVER (PARTITION BY column2 ORDER BY column3) AS row_num
FROM table_name;
```
### Array
```sql
SELECT column1, array_column[1] AS first_element
FROM table_name;

SELECT column1
FROM table_name
WHERE array_column @> ARRAY[1, 2];
```
### Json
```sql
SELECT json_column->'key' AS value
FROM table_name;

UPDATE table_name
SET jsonb_column = jsonb_set(jsonb_column, '{key}', '"new_value"')
WHERE condition;
```
### Lock
```sql
LOCK table_name IN ACCESS EXCLUSIVE MODE;
```
### Transaction
```sql
BEGIN;
UPDATE table_name
SET column1 = value1
WHERE condition;
COMMIT;
```
