SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Drivers]
@KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT, @VIEWNAME VARCHAR(250),
		@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search and an advanced search

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  03/07/2017   Chip Ciminero    WE-?????   Created
*******************************************************************************************************************/

--SP PARAMS / TEST DATA
--IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
--ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
--DECLARE @KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT, @VIEWNAME VARCHAR(250),
--		@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX)
--SELECT @KEYWORDSEARCH = ''
--, @ADVANCEDSEARCH='{     
--     "DriverId": "",
--     "Name": "",
--     "DriverType1": "",
--     "DriverType1Name": "",
--     "DriverType2": "",
--     "DriverType2Name": "",
--     "DriverType3": "",
--     "DriverType3Name": "",
--     "DriverType4": "",
--     "DriverType4Name": "",
--     "Status": ""
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileDriversView', @FILTER = ' WHERE Name LIKE ''FIN%'' ' , @SORT = ' ORDER BY Name '

DECLARE @ADV_SRCH_PARAMS TABLE(PropertyName VARCHAR(250), PropertyValue VARCHAR(250))

--CHECK IF CUSTOM SORTING WAS APPLIED, IF NOT, DEFAULT SORTING
IF LEN(@SORT) = 0
	SET @SORT = ' ORDER BY Name '

IF LEN(@FILTER) = 0
	SET @FILTER = ' WHERE 1=1 '

IF LEN(@ADVANCEDSEARCH) > 0
	BEGIN
		INSERT @ADV_SRCH_PARAMS	
		SELECT	NAME, STRINGVALUE
		FROM	parseJSON(@ADVANCEDSEARCH)
	END

DECLARE @QUERY NVARCHAR(MAX)
SET		@QUERY = 'WITH Data AS (' +
		
		--APPLY THE BOARD SQL FOR SORTING, VIEWNAME, AND WHERE CLAUSE
		' SELECT *, ROW_NUMBER() OVER (' + @SORT + ') AS RowNum ' +		
		' FROM ' + @VIEWNAME + ' ' + @FILTER  
		
--APPLY KEYWORD SEARCH
IF LEN(@KEYWORDSEARCH) > 0 
	BEGIN
			SET @QUERY = @QUERY + ' AND ( 1=2 ' 
			SET @QUERY = @QUERY + ' OR ID LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR Name LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [DrvType1 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [DrvType2 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [DrvType3 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [DrvType4 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' ) ' 				
	END

--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'AltId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND AltId LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'AltId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Name LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Name') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'FirstName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND FirstName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'FirstName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LastName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND LastName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LastName') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType1' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType1] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType1') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType1Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType1 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType1Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType2' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType2] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType2') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType2Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType2 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType2Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType3' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType3] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType3') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType3Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType3 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType3Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType4' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType4] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType4') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType4Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [DrvType4 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverType4Name') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Status' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [Driver Status] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Status') + '%'''
	END

--APPLY PAGING	
SET	@QUERY = @QUERY + ') ' +
	' SELECT * FROM ( ' +
	' SELECT *, TotalRows=Count(*) OVER() FROM Data ' +  
	' ) A ' +
	' WHERE	RowNum > ' + CAST(@PAGESIZE AS VARCHAR) + ' * (' + CAST(@PAGEINDEX AS VARCHAR) + ' - 1) ' +
	' AND RowNum <= ' + CAST(@PAGESIZE AS VARCHAR) + ' * ' + CAST(@PAGEINDEX AS VARCHAR) + 
	' ORDER BY RowNum '

EXEC sp_executesql @QUERY
GO
GRANT EXECUTE ON  [dbo].[SearchAPI_Drivers] TO [public]
GO
