SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
	

CREATE  PROCEDURE [dbo].[compare_column_count](@table1 varchar(50), @table2 varchar(50))
as

/*
*
* NAME:compare_column_count
* dbo.compare_column_count
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Provide the difference in the number of columns between two tables.
*
* RETURNS:  
*
* Column count difference, -1 if error 
* RESULT SETS: 
* 
*
* PARAMETERS:
*
* 001 - @table1 varchar (50)		Name of first table
* 002 - @table2 varchar (50) 		Name of second table
* 
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* city
* 
* REVISION HISTORY:
* 07/13/07 PTS 32403 - EMK - Created
*/

declare @fl_badtable int, @diff int
select @fl_badtable=0

-- Check existence of each table
If not exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(@table1) and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	select @fl_badtable=1
If not exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(@table2) and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	select @fl_badtable=1

If @fl_badtable=0
	SET @diff= (Select COUNT(COLUMN_NAME) as 'ROWS_RETURNED'
	FROM INFORMATION_SCHEMA.Columns a
	WHERE NOT EXISTS
	(SELECT 1 FROM INFORMATION_SCHEMA.Columns b
	WHERE a.COLUMN_NAME = b.COLUMN_NAME
	AND a.DATA_TYPE = b.DATA_TYPE
	AND b.table_name = @table1
	) AND a.table_name= @table2) 
ELSE
	SET @diff = -1

if @diff = 0 
	SET @diff= (Select COUNT(COLUMN_NAME) as 'ROWS_RETURNED'
	FROM INFORMATION_SCHEMA.Columns a
	WHERE NOT EXISTS
	(SELECT 1 FROM INFORMATION_SCHEMA.Columns b
	WHERE a.COLUMN_NAME = b.COLUMN_NAME
	AND a.DATA_TYPE = b.DATA_TYPE
	AND b.table_name = @table2
	) AND a.table_name= @table1) 
	

SELECT @diff
RETURN @diff

GO
GRANT EXECUTE ON  [dbo].[compare_column_count] TO [public]
GO
