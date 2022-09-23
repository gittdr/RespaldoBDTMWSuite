SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
	

CREATE   PROCEDURE [dbo].[get_columns_csv_sp] (@tablename varchar(128),@csv varchar(4000) OUTPUT)
as

/*
*
* NAME:get_columns_csv_sp
* dbo.get_columns_csv_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Returns a comma separated list of column names for a table
*
* RETURNS:  
*
* RESULT SETS: 

* PARAMETERS:
* 001 - tablename	varchar(128)	name of table
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* city
* 
* REVISION HISTORY:
* 07/18/07 PTS 32403 - EMK - Created
*/

declare @cols varchar(4000)
--declare @csv varchar(4000)

SET @cols = ''
SET @csv = ''

If not exists (SELECT * FROM dbo.sysobjects WHERE id = object_id(@tablename) and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	return -1

SELECT @cols = @cols + c.name + ', '
    FROM syscolumns c INNER JOIN sysobjects o ON o.id = c.id

    WHERE o.name = @tablename
    ORDER BY colid

SELECT @csv  = Substring(@cols, 1, Datalength(@cols) - 2)


GO
GRANT EXECUTE ON  [dbo].[get_columns_csv_sp] TO [public]
GO
