SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE procedure [dbo].[SSRS_RB_retrieve_audit_data]	@startdate		DATETIME,  													
													@enddate		DATETIME, 
													@tablelist		VARCHAR(8000)  
AS  

/**
 * 
 * NAME:
 * dbo.SSRS_RB_retrieve_audit_data
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * stored proc to generate output data from user defined
   audit application
   
 * SAMPLE CALL:
 * EXEC SSRS_RB_retrieve_audit_data '2013-01-01', '2013-12-31' , 'stops'
   
 *
 * PARAMETERS:
 * @startdate	- Start date used looked on audit table
 * @enddate		- End date used looked on audit table
 * @table		- Name of table to return audit data from
 *
 * REVISION HISTORY:
 * 10/16/2013 - RK - new proc
 *

*/	



SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @sql			NVARCHAR(MAX),  
        @idcolumn		VARCHAR(255),  
        @datatype		INTEGER,  
        @audit_database VARCHAR(100),
        @table			VARCHAR(100) ,
        @id				INT     

SET @enddate = DATEADD(d,1,@enddate)

CREATE TABLE #tmpaudit (
	tablename varchar(100),
	KeyCol varchar (100),
	usr_userid varchar(100),
	audit_action varchar(1),
	created_date datetime,
	ColumnNm varchar(256),
	Value varchar(8000))
	
CREATE TABLE #tablelist (
	idty int identity (1,1),
	tablename varchar(100),
	idcolname varchar(255)) 	
  
SELECT @audit_database = gi_string2  
  FROM generalinfo   
 WHERE gi_name = 'UserDefinedAuditing'  
 
INSERT INTO #tablelist
SELECT value, NULL FROM dbo.CSVStringsToTable_fn (@tablelist)

UPDATE #tablelist
SET idcolname = CONVERT(varchar(100), u.uda_columnname)
FROM userdefinedauditing u
 JOIN #tablelist t ON u.uda_tablename = t.tablename AND u.uda_index = 'P'   
 
SELECT @id = MIN(idty) FROM #tablelist 
WHILE @id IS NOT NULL
BEGIN

	SELECT @table = tablename, @idcolumn = idcolname FROM #tablelist WHERE idty = @id
 
	SET @sql = 'INSERT INTO #tmpaudit SELECT ''' + @table + ''' AS [tablename], ' + @idcolumn + ' AS [KeyCol], usr_userid, audit_action, created_date, ColumnNm, Value FROM ' 
					+ @audit_database + '.dbo.' + @table + '_audit_view'
					+ ' WHERE created_date >= ''' + CONVERT(varchar(20), @startdate, 20) + ''' and created_date < ''' + CONVERT(varchar(20), @enddate, 20) + ''''		
					
	EXEC sp_executesql @sql

	SELECT @id = MIN(idty) FROM #tablelist WHERE idty > @id
END  

SELECT * FROM #tmpaudit ORDER BY tablename, ColumnNm, created_date DESC 


  
 
  

GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_retrieve_audit_data] TO [public]
GO
