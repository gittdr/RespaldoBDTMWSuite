SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Tractors]
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
--     "TractorId": "",
--     "TractorName": "",
--     "TractorType1": "",
--     "TractorType1Name": "",
--     "TractorType2": "",
--     "TractorType2Name": "",
--     "TractorType3": "",
--     "TractorType3Name": "",
--     "TractorType4": "",
--     "TractorType4Name": "",
--     "TractorMctId": ""
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileTractorsView', @FILTER = ' WHERE NAME LIKE ''B%''' , @SORT = ' ORDER BY Name '

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
			SET @QUERY = @QUERY + ' OR [TrcType1 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [TrcType2 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [TrcType3 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [TrcType4 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' ) ' 				
	END

--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Name LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorName') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType1' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType1] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType1') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType1Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType1 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType1Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType2' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType2] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType2') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType2Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType2 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType2Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType3' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType3] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType3') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType3Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType3 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType3Name') + '%'''
									
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType4' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType4] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType4') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType4Name' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [TrcType4 Name] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorType4Name') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'MctId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [MctId] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'MctId') + '%'''
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
GRANT EXECUTE ON  [dbo].[SearchAPI_Tractors] TO [public]
GO
