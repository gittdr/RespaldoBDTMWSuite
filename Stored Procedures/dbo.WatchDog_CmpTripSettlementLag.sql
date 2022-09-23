SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'CmpTripSettlementLag',1

CREATE Proc [dbo].[WatchDog_CmpTripSettlementLag]
	(
		@MinThreshold float = 5, -- Days
		@MinsBack int=Null,
		@TempTableName varchar(255) = '##WatchDogGlobalCmpTripSettlementLag',
		@WatchName varchar(255)='WatchCmpTripSettlementLag',
		@ThresholdFieldName varchar(255) = 'Days',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode varchar(50) = 'Selected',
		@DrvType1 varchar(255) = '',
		@DrvType2 varchar(255) = '',
		@DrvType3 varchar(255) = '',
		@DrvType4 varchar(255) = '',
		@DrvDivision varchar(255) = '',
		@DrvTerminal varchar(255) = '',
		@DrvFleet varchar(255) = '',
		@DrvCompany varchar(255) = ''
	)
						
AS

	SET NOCOUNT ON
	
	/*
	Procedure Name:    WatchDog_CmpTripSettlementLag
	Author/CreateDate: Brent Keeton / 9-22-2004
	Purpose: 	   	Select completed legheaders where the paydetail settlement status is not amount the
		@SettlementStatus and the legheader end date is x days old. 
	Revision History:	Lori Brickley / 12-5-2004 / Comments
						Lori Brickley / 5-6-2005 / Major Revision to change from paydetail/payheader to 
												   assetassignment to check for payment
													Since we will be checking if the Legheader has been paid
													it is not necessary to distinguish what asset is being paid
													which is why the AssetToBePaid has been eliminated
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	--Major Revision Mode
		--This WatchDog was rewritten based on conversations with MFielder and BHorsfall
		--The logic utilizing the paydetail and payheader was incorrect for determining
		--the paid status.
	
	--Standard Parameter Initialization
	SET @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
	SET @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
	SET @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
	SET @DrvType4= ',' + ISNULL(@DrvType4,'') + ','
	SET @DrvTerminal= ',' + ISNULL(@DrvTerminal,'') + ','
	SET @DrvCompany= ',' + ISNULL(@DrvCompany,'') + ','
	SET @DrvDivision= ',' + ISNULL(@DrvDivision,'') + ','
	SET @DrvFleet= ',' + ISNULL(@DrvFleet,'') + ','


		/**************************************************************************************
			Select completed legheaders where the paydetail settlement status is not amount the
			@SettlementStatus and the legheader end date is x days old. 
		**************************************************************************************/
		SELECT	[Order Number] =	(
										SELECT ord_number 
										FROM orderheader (NOLOCK) 
										WHERE orderheader.ord_hdrnumber = legheader.ord_hdrnumber
									),
				mov_number AS [Move Number],
				lgh_driver1 AS [Driver ID],
				lgh_carrier as [Carrier ID],
				lgh_tractor as [Tractor ID],
				lgh_startcty_nmstct AS [Start City State],
				lgh_startdate AS [Start Date],
				lgh_endcty_nmstct AS [End City State],
				lgh_enddate AS [End Date],
				DATEDIFF(DAY,lgh_enddate,GETDATE()) AS [Lag Days]
		INTO    #TempResults
		FROM    LegHeader (NOLOCK)
		WHERE   lgh_outstatus = 'CMP'
				AND NOT (lgh_driver1='Unknown' AND lgh_carrier='Unknown' AND lgh_tractor='UNKNOWN')
				AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
		      	AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2  + ',', @DrvType2) >0)
		        AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
		        AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4  + ',', @DrvType4) >0)
		        AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
		        AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
		        AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
		        AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
				/*AND NOT EXISTS 	(
									SELECT paydetail.lgh_number 
									FROM paydetail (NOLOCK),payheader (NOLOCK) 
									WHERE PayHeader.pyh_pyhnumber = PayDetail.pyh_number 
										AND legheader.lgh_number = paydetail.lgh_number 
										AND (@SettlementStatus =',,' OR CHARINDEX(',' + pyh_paystatus + ',', @SettlementStatus) >0)
								)
				*/
				/*NEW*/
				AND NOT EXISTS (
									SELECT lgh_number
									FROM assetassignment (NOLOCK)
									WHERE assetassignment.lgh_number = legheader.lgh_number
										AND assetassignment.pyd_status = 'PPD'
								)
				
				AND DATEDIFF(DAY,lgh_enddate,GETDATE()) >= @MinThreshold
		ORDER BY DATEDIFF(DAY,lgh_enddate,GETDATE()) ASC
	
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
