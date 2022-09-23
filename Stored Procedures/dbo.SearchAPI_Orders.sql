SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Orders]
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
--SELECT @KEYWORDSEARCH = 'WHILIS'
--,  @ADVANCEDSEARCH='{     
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
--	 "LegNumber": 79894,
--     "DriverId": "",
--     "DriverFirstName": "",
--     "DriverLastName": "",
--     "CarrierId": "",
--     "CarrierName": "",
--     "TrailerId": "",
--     "TractorId": ""
--	  }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileOrdersView', @FILTER = ' ' , @SORT = ' ORDER BY ord_number DESC '

DECLARE @ADV_SRCH_PARAMS TABLE(PropertyName VARCHAR(250), PropertyValue VARCHAR(250))

--CHECK IF CUSTOM SORTING WAS APPLIED, IF NOT, DEFAULT SORTING
IF LEN(@SORT) = 0
	SET @SORT = ' ORDER BY F.ord_hdrnumber DESC '

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
		' FROM ' + @VIEWNAME + ' F '
SET		 @QUERY = @QUERY +  @FILTER 
				
--APPLY KEYWORD SEARCH
IF LEN(@KEYWORDSEARCH) > 0 
	BEGIN
			SET @QUERY = @QUERY + ' AND ( 1=2 ' 
			SET @QUERY = @QUERY + ' OR ord_number LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR BillToID LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR BillTo LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR ShipperID LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR ShipperName LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR ConsigneeID LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR ConsigneeName LIKE ''' + @KEYWORDSEARCH + '%'''		
			SET @QUERY = @QUERY + ' OR CarrierId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR DriverId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR TractorId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR TrailerId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' ) ' 				
	END

	
--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber' AND CAST(PropertyValue AS INT) > 0)
			SET @QUERY = @QUERY + ' AND ord_number LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber') + '%'''
			
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
			SET @QUERY = @QUERY + ' AND EndDate < ''' + CAST(DATEADD(day,1,CAST((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CompletionDate') AS smalldatetime)) AS VARCHAR(50)) + ''''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Status' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Status LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Status') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OnTimeStatus' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND OnTimeStatus LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OnTimeStatus') + '%'''
				
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber' AND CAST(PropertyValue AS INT) > 0)
			BEGIN
				DECLARE @lghNumber VARCHAR(25) = (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber') 
				SET @QUERY = @QUERY + ' AND F.ord_hdrnumber IN (' 
			
				SET @QUERY = @QUERY + ' SELECT DISTINCT ord_hdrnumber FROM stops WHERE lgh_number = ' + @lghNumber + ' and ord_hdrnumber <> 0 '
				SET @QUERY = @QUERY + ' UNION '
				SET @QUERY = @QUERY + ' SELECT DISTINCT sLower.ord_hdrnumber '
				SET @QUERY = @QUERY + ' FROM	stops sLower WITH(NOLOCK) INNER JOIN '
				SET @QUERY = @QUERY + ' 		stops sHigher WITH(NOLOCK) on sLower.ord_hdrnumber = sHigher.ord_hdrnumber  and sLower.mov_number = sHigher.mov_number  and sLower.ord_hdrnumber <> 0 '
				SET @QUERY = @QUERY + ' WHERE	sLower.mov_number IN (SELECT mov_number FROM legheader WITH(NOLOCK) WHERE lgh_number = ' + @lghNumber + ') AND '
				SET @QUERY = @QUERY + ' 		sLower.stp_mfh_sequence < (SELECT MIN(stp_mfh_sequence) FROM stops WITH(NOLOCK) WHERE lgh_number = ' + @lghNumber + ') AND '
				SET @QUERY = @QUERY + ' 		sHigher.stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WITH(NOLOCK) WHERE lgh_number = ' + @lghNumber + ') '
				SET @QUERY = @QUERY + ' ) '			
			END

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DriverId LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverId') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverFirstName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DriverFirstName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverFirstName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverLastName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DriverLastName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverLastName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND CarrierId LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierId') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND CarrierName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'CarrierName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TrailerId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND TrailerId LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TrailerId') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND TractorId LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'TractorId') + '%'''
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
GRANT EXECUTE ON  [dbo].[SearchAPI_Orders] TO [public]
GO
