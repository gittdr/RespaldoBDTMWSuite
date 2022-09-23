SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_OrdersRefNum]
@KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT, @VIEWNAME VARCHAR(250),
		@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search and an advanced search

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  04/26/2017   Chip Ciminero    WE-207339   Created
*******************************************************************************************************************/

--SP PARAMS / TEST DATA
--IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
--ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
--DECLARE @KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT, @VIEWNAME VARCHAR(250),
--		@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX)
--SELECT @KEYWORDSEARCH = '741665'
--     , @ADVANCEDSEARCH='{    
--     "OrderNumber": 0,
--     "BillTo": "",
--     "BillToName": "",
--     "Shipper": "",
--     "ShipperName": "",
--     "ShipperCity": "",
--     "ShipperState": "",
--     "Consignee": "",
--     "ConsigneeName": "",    
--     "ConsigneeCity": "",    
--     "ConsigneeState": "",    
--     "Status": "",    
--     "Remark": "",
--	 "StartDate": "",
--	 "CompletionDate": "", 
--	 "OnTimeStatus": "", 
--	 "LegNumber": 0, 
--	 "ReferenceNumber": "741665"
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileOrdersView', @FILTER = '' , @SORT = ' ORDER BY ord_number DESC '

DECLARE @ADV_SRCH_PARAMS TABLE(PropertyName VARCHAR(250), PropertyValue VARCHAR(250))

--CHECK IF CUSTOM SORTING WAS APPLIED, IF NOT, DEFAULT SORTING
IF LEN(@SORT) = 0
	SET @SORT = ' ORDER BY ord_hdrnumber DESC '

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
			SET @QUERY = @QUERY + ' OR ord_hdrnumber IN (SELECT DISTINCT ord_hdrnumber FROM referencenumber  WHERE ref_number LIKE ''' + @KEYWORDSEARCH + '%''' + ')'
			SET @QUERY = @QUERY + ' ) ' 				
	END

--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber' AND CAST(PropertyValue AS INT) > 0)
			SET @QUERY = @QUERY + ' AND ord_hdrnumber LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'BillTo' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND BillToID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'BillTo') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'BillToName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND BillTo LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'BillToName') + '%'''
						
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Shipper' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ShipperID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Shipper') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ShipperName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ShipperName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ShipperName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ShipperCity' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ShipperCity LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ShipperCity') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ShipperState' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ShipperState LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ShipperState') + '%'''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Consignee' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Consignee') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeCity' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeCity LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeCity') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeState' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeState LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeState') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'StartDate' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND StartDate > ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'StartDate') + ''''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompletionDate' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND EndDate < ''' + DATEADD(day,1,CAST((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompletionDate') AS smalldatetime)) + ''''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Status' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Status LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Status') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OnTimeStatus' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND OnTimeStatus LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OnTimeStatus') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber' AND CAST(PropertyValue AS INT) > 0)
			SET @QUERY = @QUERY + ' AND LegNumber LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ReferenceNumber' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ord_hdrnumber IN (SELECT DISTINCT ord_hdrnumber FROM referencenumber  WHERE ref_number LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ReferenceNumber') + '%''' + ')'	

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
GRANT EXECUTE ON  [dbo].[SearchAPI_OrdersRefNum] TO [public]
GO
