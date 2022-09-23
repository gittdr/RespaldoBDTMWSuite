SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SearchAPI_Trips]
@KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT, @VIEWNAME VARCHAR(250),
		@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX)
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides search capabilities for a keyword search and an advanced search

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  03/15/2017   Chip Ciminero    WE-?????    Created
  06/28/2017   Chase Plante     WE-208658   Fixed ability to search on status
  03/23/2018   Brad Biehl                   All three items (MobileTripsView, MobileHistoricalTripsView, and SearchAPI_Trips) need to use the same
												names.  Rename all three to use Carrier instead of CarrierId.
*******************************************************************************************************************/

--SP PARAMS / TEST DATA
--IF YOU SEARCH FOR A KEYWORD, IT WILL IGNORE ADVANCED SEARCH
--ADDING MULTIPLE CRITERIA IN ADVANCED SEARCH WILL REQUIRE ALL FIELDS ENTERED TO BE SATISFIED
--DECLARE @KEYWORDSEARCH VARCHAR(250), @ADVANCEDSEARCH VARCHAR(MAX), @PAGESIZE INT, @PAGEINDEX INT, @VIEWNAME VARCHAR(250),
--		@FILTER VARCHAR(MAX), @SORT VARCHAR(MAX)
--SELECT @KEYWORDSEARCH = 'ED'
--, @ADVANCEDSEARCH='{     
--     "LegNumber": 0,
--     "PickupName": "",
--     "PickupCity": "",
--     "PickupState": "",
--     "ConsigneeId": "",
--     "ConsigneeName": "",    
--     "ConsigneeCity": "",    
--     "ConsigneeState": "",    
--     "DispStatus": "",    
--     "Remark": "",
--	   "StartDate": "",
--	   "CompletionDate": "", 
--	   "OnTimeStatus": "",
--     "OrderNumber": 3031174,
--     "DriverId": "",
--     "DriverFirstName": "",
--     "DriverLastName": "",
--     "CarrierId": "",
--     "CarrierName": "",
--     "TrailerId": "",
--     "TractorId": ""
--    }'
--, @PAGESIZE = 20, @PAGEINDEX = 1
--, @VIEWNAME ='MobileTripsView'
--, @FILTER = ' ' 
--, @SORT = ' ORDER BY LegNumber DESC '

DECLARE @ADV_SRCH_PARAMS TABLE(PropertyName VARCHAR(250), PropertyValue VARCHAR(250))

--CHECK IF CUSTOM SORTING WAS APPLIED, IF NOT, DEFAULT SORTING
IF LEN(@SORT) = 0
	SET @SORT = ' ORDER BY LegNumber DESC '

IF LEN(@FILTER) = 0
	SET @FILTER = ' WHERE 1=1 '

IF LEN(@ADVANCEDSEARCH) > 0
	BEGIN
		INSERT @ADV_SRCH_PARAMS	
		SELECT	NAME, STRINGVALUE
		FROM	parseJSON(@ADVANCEDSEARCH)
	END

DECLARE @QUERY NVARCHAR(MAX)
DECLARE @ORDER VARCHAR(25)

--IF LEG NUMBER SEARCH, SEARCH HISTORY TO PULL DETAILS OVER FOR COMPLETED LEGS
IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber' AND CAST(PropertyValue AS INT) > 0)
	BEGIN
		SET @VIEWNAME ='MobileHistoricalTripsView'
	END

IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber' AND CAST(PropertyValue AS INT) > 0)
	BEGIN
		--SEARCHING FOR ORDER NUMBER NEEDS TO RETURN ANY LEG COMPLETED, ACTIVE, ETC.  OVERRIDE THE VIEW TO PULL HISTORICAL LEGS
		SET @VIEWNAME ='MobileHistoricalTripsView'
		SET @ORDER = (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber')

		SET @QUERY = ' WITH MOVE_MAXSEQ AS '
		SET @QUERY = @QUERY + ' ( '
		SET @QUERY = @QUERY + ' SELECT	MoveNumber = mov_number, MaxSeq = MAX(stp_mfh_sequence)  '
		SET @QUERY = @QUERY + ' FROM	stops '
		SET @QUERY = @QUERY + ' WHERE	ord_hdrnumber = ' + @ORDER 
		SET @QUERY = @QUERY + ' GROUP BY mov_number '
		SET @QUERY = @QUERY + ' ), '
	END
ELSE 
	BEGIN
		SET	@QUERY = ' WITH ' 
	END
	
SET		@QUERY = @QUERY + ' Data AS ( ' +
		
		--APPLY THE BOARD SQL FOR SORTING, VIEWNAME, AND WHERE CLAUSE
		' SELECT *, ROW_NUMBER() OVER (' + @SORT + ') AS RowNum ' +		
		' FROM ' + @VIEWNAME + ' ' + @FILTER  
		
--APPLY KEYWORD SEARCH
IF LEN(@KEYWORDSEARCH) > 0 
	BEGIN
			SET @QUERY = @QUERY + ' AND ( 1=2 ' 
			SET @QUERY = @QUERY + ' OR LegNumber LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR PickupID LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR PickupName LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR ConsigneeID LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR ConsigneeName LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR Carrier LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR DriverId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR TractorId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' OR TrailerId LIKE ''' + @KEYWORDSEARCH + '%'''
			SET @QUERY = @QUERY + ' ) ' 				
	END

--APPLY ADVANCED SEARCH
IF LEN(@ADVANCEDSEARCH) > 0 
	BEGIN
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber' AND CAST(PropertyValue AS INT) > 0)
			SET @QUERY = @QUERY + ' AND LegNumber LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'LegNumber') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND PickupID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND PickupName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupCity' AND LEN(PropertyValue)> 0)
			SET @QUERY = @QUERY + ' AND PickupCity LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupCity') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupState' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND PickupState LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'PickupState') + '%'''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeID LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeId') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeCity' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeCity LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeCity') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeState' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND ConsigneeState LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'ConsigneeState') + '%'''
			
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'StartDate' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND StartDate > ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'StartDate') + ''''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'EndDate' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND EndDate < ''' + CAST(DATEADD(day,1,CAST((SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'EndDate') AS smalldatetime)) AS VARCHAR(50)) + ''''		
				
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OnTimeStatus' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND OnTimeStatus LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OnTimeStatus') + '%'''
		
		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DispStatus' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DispStatus LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DispStatus') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'OrderNumber' AND CAST(PropertyValue AS INT) > 0)
			BEGIN
				SET @QUERY = @QUERY + ' AND LegNumber IN '
				SET @QUERY = @QUERY + ' (SELECT	DISTINCT lgh_number '
				SET @QUERY = @QUERY + ' FROM	stops S INNER JOIN '
				SET @QUERY = @QUERY + ' MOVE_MAXSEQ M ON S.mov_number = M.MoveNumber '
				SET @QUERY = @QUERY + ' WHERE	S.stp_mfh_sequence <= M.MaxSeq) ' 
			END

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverId' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DriverId LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverId') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverFirstName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DriverFirstName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverFirstName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverLastName' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND DriverLastName LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'DriverLastName') + '%'''

		IF EXISTS (SELECT * FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Carrier' AND LEN(PropertyValue) > 0)
			SET @QUERY = @QUERY + ' AND Carrier LIKE ''' + (SELECT PropertyValue FROM @ADV_SRCH_PARAMS WHERE PropertyName = 'Carrier') + '%'''

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
GRANT EXECUTE ON  [dbo].[SearchAPI_Trips] TO [public]
GO
