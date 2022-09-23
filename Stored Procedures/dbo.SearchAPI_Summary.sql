SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Summary]
@VIEWNAME VARCHAR(250),@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX),@GROUPBY_COLUMNNAME VARCHAR(250)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides quick grouped totals against the mobile boards

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  03/16/2017   Chip Ciminero    WE-206134   Created
*******************************************************************************************************************/

--SP PARAMS / TEST DATA
--IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
--ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
--DECLARE @VIEWNAME VARCHAR(250), @FILTER VARCHAR(MAX), @GROUPBY_COLUMNNAME VARCHAR(250)
--SELECT	@VIEWNAME ='MobileOrdersView', @FILTER = ' WHERE ShipperID LIKE ''ABLE%'' ' , @GROUPBY_COLUMNNAME = 'DeliveryStatus'

IF LEN(@FILTER) = 0
	SET @FILTER = ' WHERE 1=1 '

DECLARE @QUERY NVARCHAR(MAX)
SET		@QUERY = 'WITH Data AS (' +
		
		--APPLY THE BOARD SQL FOR SORTING, VIEWNAME, AND WHERE CLAUSE
		' SELECT * ' +		
		' FROM ' + @VIEWNAME + ' ' + @FILTER  
								
--APPLY GROUP BY
SET	@QUERY = @QUERY + ') ' +
	' SELECT [' + @GROUPBY_COLUMNNAME + '] [Category], COUNT(*) [Total]' +
	' FROM Data ' +  
	' GROUP BY [' + @GROUPBY_COLUMNNAME + '] ' +
	' ORDER BY [' + @GROUPBY_COLUMNNAME + '] '

EXEC sp_executesql @QUERY
GO
GRANT EXECUTE ON  [dbo].[SearchAPI_Summary] TO [public]
GO
