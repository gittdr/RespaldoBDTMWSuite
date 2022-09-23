SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--watchdogprocessing 'PostDatedPay',1

CREATE Proc [dbo].[WatchDog_PostDatedPay]
	(
		@MinThreshold float = 0, -- Days
		@MinsBack int=Null,
		@TempTableName varchar(255) = '##WatchDogGlobalPostDatedPay',
		@WatchName varchar(255)='WatchPostDatedPay',
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
		@DrvCompany varchar(255) = '',
		@ParameterToUseForDynamicEmail varchar(140)=''
	)
						
AS

	SET NOCOUNT ON
	
	/*
	Procedure Name:    WatchDog_PostDatedPay
	Author/CreateDate: David Wilks / 6/-17-2005
	Purpose: 	   	Select completed legheaders where the paydetail settlement paydate is beyond the current 
	                bimonthly pay period.
	Revision History:
	*/
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
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
			Select completed legheaders where the enddate of the trip is not within the 
			PayPeriod indicated on the paydetail
		**************************************************************************************/
		SELECT	l.ord_hdrnumber AS [Order Number],
				l.mov_number AS [Move Number],
				lgh_driver1 AS [Driver ID],
				CONVERT(Decimal(9,2), pyd_amount) AS [Pay Detail Amount],
				lgh_enddate AS [End Date],
				pyh_payperiod AS [Pay Date],
				DATEDIFF(DAY,lgh_enddate,pyh_payperiod) AS [Pay Delay Days],
				lgh_carrier as [Carrier ID],
				lgh_tractor as [Tractor ID],
				lgh_startcty_nmstct AS [Start City State],
				lgh_startdate AS [Start Date],
				lgh_endcty_nmstct AS [End City State],
				EmailSend = dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, mpp_company,mpp_division, mpp_domicile,default,mpp_type1,mpp_type2,mpp_type3, mpp_type4,default,default,default,default,default, mpp_teamleader, mpp_terminal,default, default, default,default,default, default,default,default,default,default,default) 
		INTO    #TempResults
		FROM    LegHeader L (NOLOCK) JOIN PayDetail pd (NOLOCK) ON L.lgh_number = pd.lgh_number
		WHERE   lgh_outstatus = 'CMP'
				AND NOT (lgh_driver1='Unknown' AND lgh_carrier='Unknown' AND lgh_tractor='UNKNOWN')
		        AND NOT (DATEPART(m, lgh_enddate) = DATEPART(m, pyh_payperiod)
						AND (DATEPART(d, lgh_enddate) < 16 AND DATEPART(d, pyh_payperiod) = 15
							OR DATEPART(d, lgh_enddate) > 15 AND DATEPART(d, DateAdd(d, 1, pyh_payperiod)) = 1))
				AND pyh_payperiod <= GetDate()
				AND pyh_payperiod > DateAdd(d, @MinThreshold, lgh_enddate)
				AND pyd_updatedon >= DateAdd(mi, @MinsBack, GetDate())
				AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
		      	AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2  + ',', @DrvType2) >0)
		        AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
		        AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4  + ',', @DrvType4) >0)
		        AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
		        AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
		        AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
		        AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)

		ORDER BY DATEDIFF(DAY,lgh_enddate,pyh_payperiod) DESC
	
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
