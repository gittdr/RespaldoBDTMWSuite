SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Companies]
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
--     "CompanyId": "",
--     "CompanyName": "",
--     "Address": "",    
--     "ZipCode": "",
--     "IsBillTo": false,
--     "IsShipper": false,
--     "IsConsignee": false
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileCustomersView', @FILTER = ' WHERE Name LIKE ''ABLE%'' ' , @SORT = ' ORDER BY Name '

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
			SET @QUERY = @QUERY + ' OR [RevType1 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [RevType2 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [RevType3 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR [RevType4 Name] LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' ) ' 				
	END

--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompanyId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompanyId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompanyName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Name LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompanyName') + '%'''
						
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Address' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Address1 LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Address') + '%'''
			
		--IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'City' AND LEN(PropertyValue) > 0)
		--	SET @QUERY = @QUERY + ' AND City LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'City') + '%'''

		--IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State' AND LEN(PropertyValue) > 0)
		--	SET @QUERY = @QUERY + ' AND State LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'State') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ZipCode' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND [Zip Code] LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ZipCode') + '%'''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'IsBillTo' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND COALESCE([Bill To],''N'') = ''' + CASE WHEN (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'IsBillTo') = 'true' THEN 'Y' ELSE 'N' END  + ''''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'IsShipper' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND COALESCE([Shipper],''N'') = ''' + CASE WHEN (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'IsShipper') = 'true' THEN 'Y' ELSE 'N' END  + ''''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'IsConsignee' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND COALESCE([Consignee],''N'') = ''' + CASE WHEN (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'IsConsignee') = 'true' THEN 'Y' ELSE 'N' END + ''''
			
		--REMARK DOES NOT EXIST ON EXISTING BASE VIEW.		
		--IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Remark' AND LEN(PropertyValue) > 0)
		--	SET @QUERY = @QUERY + ' AND Remark LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Remark') + '%'''
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
GRANT EXECUTE ON  [dbo].[SearchAPI_Companies] TO [public]
GO
