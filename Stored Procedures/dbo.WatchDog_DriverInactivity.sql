SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'DriverInactivity' ,1

CREATE Proc [dbo].[WatchDog_DriverInactivity]
	(
		--Standard Parameters
		@MinThreshold float = 14,
		@MinsBack int=-20,
		@TempTableName varchar(255)='##WatchDogGlobalInactiveDrivers',
		@WatchName varchar(255) = 'WatchInactiveDrivers',
		@ThresholdFieldName varchar(255) = 'Days Inactive',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode varchar (50) ='Selected',
		--Additional/Optional Parameters
		@DrvType1 VARCHAR(255)='',
		@DrvType2 VARCHAR(255)='',
		@DrvType3 VARCHAR(255)='',
		@DrvType4 VARCHAR(255)='',
		@DrvFleet VARCHAR(255)='',
		@DrvDivision VARCHAR(255)='',
		@DrvCompany VARCHAR(255)='',
		@DrvTerminal VARCHAR(255)='',
		@ExcludeDrvDomicileList VARCHAR(255)='',
		@DriverStatus Varchar(150)='',
		@ExcludeDriverStatus Varchar(150)='',
		@ExcludeDrvCompanyList Varchar(255)=''
	)
						
AS

SET NoCount On

/*
Procedure Name:    WatchDog_InactiveDrivers
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   	Returns active drivers whose last assignment
				was greater than x days ago.
Revision History:	Lori Brickley / 12-3-2004 / Add Comments
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
SET @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
SET @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
SET @DrvType4= ',' + ISNULL(@DrvType4,'') + ','

SET @DrvTerminal = ',' + ISNULL(@DrvTerminal,'') + ','
SET @DrvCompany = ',' + ISNULL(@DrvCompany,'') + ','
SET @DrvFleet = ',' + ISNULL(@DrvFleet,'') + ','
SET @DrvDivision = ',' + ISNULL(@DrvDivision,'') + ','

SET @ExcludeDrvDomicileList = ',' + ISNULL(@ExcludeDrvDomicileList,'') + ','


SET @ExcludeDriverStatus = ',' + ISNULL(@ExcludeDriverStatus,'') + ','
SET @DriverStatus = ',' + ISNULL(@DriverStatus,'') + ','


SET @ExcludeDrvCompanyList = ',' + ISNULL(@ExcludeDrvCompanyList,'') + ','

/*************************************************************************************
	Select the driver and legheaders where the driver's last assignment (type 'DRV')
	end date is greater than x days ago (minThreshold), the driver is active, with no
	termination date, and id is not unknown.
*************************************************************************************/
SELECT	mpp_id AS [Driver ID],
		DriverName,
		LegHeader.mov_number AS Movement,
        lgh_tractor AS [Tractor ID],
        lgh_primary_trailer AS [Trailer ID],
        'Origin Company' = (
								SELECT TOP 1 Company.cmp_name 
								FROM Company (NOLOCK) 
								WHERE legheader.cmp_id_start = Company.cmp_id
							), 
		'Origin City State' = 	(
									SELECT City.cty_name + ', '+ City.cty_state 
									FROM City (NOLOCK)
									WHERE legheader.lgh_startcity = City.cty_code
								),
        lgh_startdate AS 'Segment Start Date',
		lgh_enddate AS 'Segment End Date',
        'Destination Company' = 	(
										SELECT TOP 1 Company.cmp_name 
										FROM Company (NOLOCK)
										WHERE legheader.cmp_id_end = Company.cmp_id
									),
        'Destination City State' = 	(
										SELECT City.cty_name + ', '+ City.cty_state 
										FROM City (NOLOCK)
										WHERE legheader.lgh_endcity = City.cty_code
									),
        asgn_enddate AS 'Assignment End Date',
		IsNull(DateDIFf(day,Asgn_enddate,GETDATE()),0)  AS DaysInactive,
		mpp_terminal AS [Terminal]
INTO    #TempResults
FROM 	(
			SELECT 	mpp_id,
					IsNull(mpp_firstname,'') + ' ' + IsNull(mpp_lastname,'') AS DriverName,
					'MaxAsgnNumber'= 	(
											SELECT Max(asgn_number) 
											FROM assetassignment a (NOLOCK)
											WHERE mpp_id=asgn_id
												AND asgn_type = 'DRV'
												AND asgn_status <> 'PLN'
												AND asgn_enddate = 	(
																		SELECT max(b.asgn_enddate) 
																		FROM assetassignment b (NOLOCK)
																		WHERE (b.asgn_type = 'DRV'
																			AND a.asgn_id = b.asgn_id
																			AND asgn_status <> 'PLN')
																	)

										)
			FROM 	ManpowerProfile (NOLOCK)
			WHERE 	MPP_id<>'UNKNOWN'	
					AND mpp_terminationdt > GETDATE() 
					AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
        			AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
        			AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
        			AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
					AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
        			AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
        			AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
        			AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
				AND (@ExcludeDrvDomicileList = ',,' OR Not (CHARINDEX(',' + mpp_domicile + ',', @ExcludeDrvDomicileList) > 0)) 
				AND (@ExcludeDriverStatus = ',,' OR Not (CHARINDEX(',' + mpp_status + ',', @ExcludeDriverStatus) > 0)) 
				AND (@DriverStatus =',,' OR CHARINDEX(',' + mpp_status + ',', @DriverStatus) >0)
				AND (@ExcludeDrvCompanyList = ',,' OR Not (CHARINDEX(',' + mpp_company + ',', @ExcludeDrvCompanyList) > 0)) 

		) AS TempInactivity 
		Left Join Assetassignment On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
        Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 		    
WHERE 	DateDIFf(day,Asgn_enddate,GETDATE()) > @MinThreshold  OR Asgn_enddate IS NULL
ORDER BY DaysInactive DESC

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
Else
BEGIN
	SET @COLSQL = ''
	Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(int,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

Exec (@SQL)

SET NoCount Off

GO
