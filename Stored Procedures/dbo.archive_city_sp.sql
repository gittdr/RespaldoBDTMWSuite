SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
	

CREATE   PROCEDURE [dbo].[archive_city_sp] (@cty_code int)
as

/*
*
* NAME:archive_city
* dbo.archive_city
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Copies a row from the city table to the cityarchive table and then deletes it.  Does same with cityzip.
*
* RETURNS:  
*
* RESULT SETS: 

* PARAMETERS:
* 001 - cty_code	int				City code
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* city
* 
* REVISION HISTORY:
* 07/18/07 PTS 32403 - EMK - Created
*/


declare @issame int, @retval int
declare @str_columns varchar(4000),@str_copyquery varchar(4000)

--Verify original and archive tables are the same
--exec @issame = compare_column_count 'city', 'cityarchive';
--if @issame <> 0  return -1

--exec @issame = compare_column_count 'cityzip', 'cityziparchive';
--if @issame <> 0  return -1


-- 
--Copy the city record
--

--Abort entire transaction on constraint violation
SET XACT_ABORT ON

Begin Tran

	-- Get the column names from the city
	exec get_columns_csv_sp @tablename='city', @csv=@str_columns output
	
	-- Note the REPLACE function is because you cant insert non-null values into the timestamp column.
	SET @str_copyquery = 'INSERT INTO cityarchive (' + @str_columns + ') SELECT ' 
			+ REPLACE ( @str_columns ,'timestamp', 'NULL' )  + ' FROM city where cty_code = ' + str(@cty_code)
	exec(@str_copyquery)
	
	if @@error <> 0 
	Begin
		select -1,'Error copying the city record to the cityarchive table.'	
		Rollback
		Return -1
	End 

	--if not exists(select cty_code from cityarchive where cty_code=@cty_code) 
	
	-- 
	--Copy the cityzip record
	--
	
	-- Get the column names from the cityzip
	exec get_columns_csv_sp @tablename='cityzip', @csv=@str_columns output
	
	SET @str_copyquery = 'INSERT INTO cityziparchive (' + @str_columns + ') SELECT ' 
			+ @str_columns + ' FROM cityzip where cty_code = ' + str(@cty_code)
	exec(@str_copyquery)
	--if not exists(select cty_code from cityziparchive where cty_code=@cty_code) 
	if @@error <> 0 
	Begin
		select -1,'Error copying the cityzip record to the cityarchive table.'	
		Rollback
		Return -1
	End 

	--Delete the city record
	--Trigger should automatically delete the cityzip records

	delete from city where cty_code = @cty_code
	if @@error <> 0 
	Begin
		select -1,'Error deleting the cityzip record to the cityarchive table.'	
		Rollback
		Return -1
	End 

Commit

GO
GRANT EXECUTE ON  [dbo].[archive_city_sp] TO [public]
GO
