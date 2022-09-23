SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Carriers]
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
--     "CarrierId": "",
--     "CarrierName": "",
--     "CarrierType1": "",
--     "CarrierType1Name": "",
--     "CarrierType2": "",
--     "CarrierType2Name": "",
--     "CarrierType3": "",
--     "CarrierType3Name": "",
--     "CarrierType4": "",
--     "CarrierType4Name": ""
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileCarriersView', @FILTER = ' WHERE NAME LIKE ''B%''' , @SORT = ' ORDER BY Name '

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
			SET @QUERY = @QUERY + ' OR [CarType1 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [CarType2 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [CarType3 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [CarType4 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' ) ' 				
	END

--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Name LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierName') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType1' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType1] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType1') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType1Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType1 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType1Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType2' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType2] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType2') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType2Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType2 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType2Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType3' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType3] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType3') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType3Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType3 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType3Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType4' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType4] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType4') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType4Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [CarType4 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierType4Name') + '%'''
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
GRANT EXECUTE ON  [dbo].[SearchAPI_Carriers] TO [public]
GO
