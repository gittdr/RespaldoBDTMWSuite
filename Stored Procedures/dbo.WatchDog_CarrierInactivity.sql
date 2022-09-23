SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_CarrierInactivity]
	(
		@MinThreshold float = 14, --Days
		@MinsBack int=-20,
		@TempTableName varchar(255) = '##WatchDogGlobalInactiveCarriers',
		@WatchName varchar(255)='WatchInactiveCarriers',
		@ThresholdFieldName varchar(255) = 'Inactive Carriers',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode varchar(50) = 'Selected',
		@CarType1 varchar(255)='',
		@CarType2 varchar(255)='',
		@CarType3 varchar(255)='',
		@CarType4 varchar(255)='',
		@OnlyTeamLeaderList varchar(255)=''
	)
						
AS

SET NoCount On

/*
Procedure Name:    WatchDog_InactiveTractors
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Returns the last legheader for carriers
				where the last assignment end date is
				greater than x days old.
Revision History:	Lori Brickley / 12-3-2004 / Add Comments, Add NOLOCK
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

SET @CarType1= ',' + ISNULL(@CarType1,'') + ','
SET @CarType2= ',' + ISNULL(@CarType2,'') + ','
SET @CarType3= ',' + ISNULL(@CarType3,'') + ','
SET @CarType4= ',' + ISNULL(@CarType4,'') + ','
SET @OnlyTeamLeaderList= ',' + ISNULL(rtrim(ltrim(@OnlyTeamLeaderList)),'') + ','

/*********************************************************************************
	Finds the last assignment type 'CAR', where the carrier is not unknown, and
	the carrier status is active.  Returns only carriers where the last assignment 
	end date is greater than MinThreshold days old.
	
*********************************************************************************/
SELECT 	LegHeader.mov_number AS Movement,
       	car_id AS 'Carrier ID',
		[Carrier Name],
		ISNULL(MaxAsgnNumber,-1) AS MaxAsgnNumber,
        lgh_tractor AS Tractor,
        lgh_primary_trailer AS Trailer,
        'Origin Company' = (SELECT TOP 1 Company.cmp_name FROM Company (NOLOCK) WHERE legheader.cmp_id_start = Company.cmp_id), 
		'Origin City State' = (SELECT City.cty_name + ', '+ City.cty_state FROM City (NOLOCK) WHERE legheader.lgh_startcity = City.cty_code),
        lgh_startdate AS FROMDate,
		lgh_enddate AS ToDate,
        'Destination Company' = (SELECT TOP 1 Company.cmp_name FROM Company (NOLOCK) WHERE legheader.cmp_id_end = Company.cmp_id),
        'Destination City State' = (SELECT City.cty_name + ', '+ City.cty_state FROM City (NOLOCK) WHERE legheader.lgh_endcity = City.cty_code),
        Asgn_enddate AS [Assignment End Date],
		ISNULL(DATEDIFF(DAY,Asgn_enddate,GETDATE()),0)  AS DaysInactive,
		lgh_class1 AS 'RevType1',
        lgh_class2 AS 'RevType2',
		lgh_class3 AS 'RevType3',
		lgh_class4 AS 'RevType4',
		LegHeader.mpp_teamleader AS TeamLeader
INTO    #TempResults
FROM (
		SELECT 	car_id,
				ISNULL(car_name,'') AS 'Carrier Name',
				'MaxAsgnNumber'= (
									SELECT MAX(asgn_number) 
									FROM assetassignment a (NOLOCK)
									WHERE car_id=asgn_id
										AND asgn_type = 'CAR'
										AND asgn_enddate = (
																SELECT MAX(b.asgn_enddate) 
																FROM assetassignment b (NOLOCK)
																WHERE (b.asgn_type = 'CAR'
																	AND a.asgn_id = b.asgn_id)
															)

								)
		FROM Carrier (NOLOCK)
		WHERE car_id<>'UNKNOWN'	
			AND car_status = 'Act' 
			AND (@CarType1 =',,' OR CHARINDEX(',' + car_type1 + ',', @CarType1) >0)
        	AND (@CarType2 =',,' OR CHARINDEX(',' + car_type2 + ',', @CarType2) >0)
        	AND (@CarType3 =',,' OR CHARINDEX(',' + car_type3 + ',', @CarType3) >0)
        	AND (@CarType4 =',,' OR CHARINDEX(',' + car_type4 + ',', @CarType4) >0)
	) AS TempInactivity 
	LEFT JOIN Assetassignment ON TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
	LEFT JOIN LegHeader ON Assetassignment.lgh_number = LegHeader.lgh_number 
WHERE 
	(DATEDIFF(DAY,Asgn_enddate,GETDATE()) > @MinThreshold  OR Asgn_enddate IS NULL)
	And 
	(@OnlyTeamLeaderList =',,' or CHARINDEX(',' + legheader.mpp_teamleader + ',', @OnlyTeamLeaderList) >0)

order by DATEDIFF(DAY,Asgn_enddate,GETDATE()) desc

DELETE from #TempResults where MaxAsgnNumber = -1


--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(int,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF

GO
