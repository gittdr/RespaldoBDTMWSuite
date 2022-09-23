SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'DriverExpirationNotice' ,1

CREATE PROC [dbo].[WatchDog_DriverExpirationNotice] 
	(
		@MinThreshold FLOAT = 14, -- Days
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalDriverExpirationNotice',
		@WatchName VARCHAR(255)='WatchDriverExpirationNotice',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@ExpirationCode VARCHAR(255)='',
		@AssetType VARCHAR(255) = '',
		@DrvType1 VARCHAR(255) = '',
       	@DrvType2 VARCHAR(255) = '',
       	@DrvType3 VARCHAR(255) = '',
       	@DrvType4 VARCHAR(255) = '',
       	@DrvFleet VARCHAR(255)='',
       	@DrvDivision VARCHAR(255)='',
       	@DrvCompany VARCHAR(255)='',
       	@DrvTerminal VARCHAR(255)='',
		@DrvTeamLeader VARCHAR(255)='',
		@Excludecode VARCHAR(255)= '',
		@ExcludeDriverStatus VARCHAR(255)='OUT',
		@ParameterToUseForDynamicEmail varchar(140)='',
		@SendToTotalMail_Tractor_or_Driver varchar(10) = ''
	)
						

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_ExpirationsNotice
Author/CreateDate: Brent Keeton / 6-15-2004
Purpose: 	   Select Driver and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
Revision History:	Lori Brickley / 12-6-2004 / Add Comments
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @ExpirationCode= ',' + ISNULL(@ExpirationCode,'') + ','

SET @DrvType1= ',' + ISNULL(@DrvType1,'') + ','
SET @DrvType2= ',' + ISNULL(@DrvType2,'') + ','
SET @DrvType3= ',' + ISNULL(@DrvType3,'') + ','
SET @DrvType4= ',' + ISNULL(@DrvType4,'') + ','

SET @DrvTerminal = ',' + ISNULL(@DrvTerminal,'') + ','
SET @DrvCompany = ',' + ISNULL(@DrvCompany,'') + ','
SET @DrvFleet = ',' + ISNULL(@DrvFleet,'') + ','
SET @DrvDivision = ',' + ISNULL(@DrvDivision,'') + ','
SET @DrvTeamLeader = ',' + ISNULL(@DrvTeamLeader,'') + ','
SET @Excludecode = ',' + ISNULL(@Excludecode,'') + ','
SET @ExcludeDriverStatus = ',' + ISNULL(@ExcludeDriverStatus,'') + ','

/*******************************************************************************************
	Select Driver and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
*******************************************************************************************/
SELECT 	exp_id AS [Driver ID],
       	CASE WHEN exp_idtype = 'DRV' THEN
			(SELECT mpp_lastfirst FROM manpowerprofile (NOLOCK) WHERE mpp_id = exp_id)
       		END 
		AS [Asset Name],
       	exp_code AS [Expiration Code],
       	[Expiration] = 	(
							SELECT labelfile.name 
							FROM labelfile (NOLOCK) 
							WHERE labelfile.abbr = exp_code 
								AND labeldefinition = exp_idtype + 'Exp'
						),
       	DATEDIFF(DAY,GETDATE(),exp_expirationdate) AS [Days Out],
       	exp_expirationdate AS [Expiration Date],
       	exp_compldate as [Expiration Completion Date],
       	ISNULL(mpp_tractornumber,'') AS [Tractor],
		exp_description as [Description],
		exp_routeto as [Location Needed],
		city.cty_nmstct	as [Location City, State], 	
		mpp_type1 as [DrvType1],
		mpp_type2 as [DrvType2],
		mpp_type3 as [DrvType3],
		mpp_type4 as [DrvType4],
		mpp_fleet as [DrvFleet],
		mpp_domicile as [DrvDomicile],
		mpp_terminal as [DrvTerminal],
		mpp_division as [DrvDivision],
		mpp_teamleader as [Teamleader],
		EmailSend = dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, mpp_company,mpp_division, mpp_domicile,exp_code,mpp_type1,mpp_type2,mpp_type3, mpp_type4,default,default,default,default,default, mpp_teamleader, mpp_terminal
					,default, default, default,default,default, default,default,default,default,default,default) --TeamLeaderEmail
		,TotalMailDriver = ISNULL('D:' + NULLIF(mpp_id, 'UNKNOWN'), '') 
		,TotalMailTractor = ISNULL('T:' + NULLIF(mpp_tractornumber, 'UNKNOWN'), '')
INTO   	#TempResults 
FROM   	Expiration (NOLOCK) 
	INNER JOIN manpowerprofile (NOLOCK) ON mpp_id = exp_id AND exp_idtype = 'DRV'
	LEFT OUTER JOIN City (NOLOCK) ON exp_city = cty_Code 
WHERE  	(@ExpirationCode =',,' OR CHARINDEX(',' + exp_code + ',', @ExpirationCode) >0)
      	AND ((exp_completed = 'N' AND DateDiff(minute,GetDate(),exp_expirationdate) <= @MinThreshold * 24 * 60))
      	AND (@DrvType1 =',,' OR CHARINDEX(',' + mpp_type1 + ',', @DrvType1) >0)
      	AND (@DrvType2 =',,' OR CHARINDEX(',' + mpp_type2 + ',', @DrvType2) >0)
      	AND (@DrvType3 =',,' OR CHARINDEX(',' + mpp_type3 + ',', @DrvType3) >0)
      	AND (@DrvType4 =',,' OR CHARINDEX(',' + mpp_type4 + ',', @DrvType4) >0)
      	AND (@DrvTerminal =',,' OR CHARINDEX(',' + mpp_terminal + ',', @DrvTerminal) >0)
      	AND (@DrvFleet =',,' OR CHARINDEX(',' + mpp_fleet + ',', @DrvFleet) >0)
      	AND (@DrvCompany =',,' OR CHARINDEX(',' + mpp_company + ',', @DrvCompany) >0)
      	AND (@DrvDivision =',,' OR CHARINDEX(',' + mpp_division + ',', @DrvDivision) >0)
      	AND (mpp_terminationdt > GetDate() OR mpp_terminationdt IS NULL)
		AND (@DrvTeamLeader =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @DrvTeamLeader) >0)
		AND (@Excludecode  =',,' OR CHARINDEX(',' + exp_code + ',', @Excludecode ) =0)
		AND (@ExcludeDriverStatus =',,' OR CHARINDEX(',' + mpp_status + ',', @ExcludeDriverStatus) =0)
ORDER BY exp_expirationdate ASC

IF @SendToTotalMail_Tractor_or_Driver = 'TRACTOR'
BEGIN
	UPDATE #TempResults SET EmailSend = CASE WHEN LTRIM(EmailSend) <> '' THEN EmailSend + ',' ELSE '' END + TotalMailTractor 
END
ELSE IF @SendToTotalMail_Tractor_or_Driver = 'DRIVER'
BEGIN
	UPDATE #TempResults SET EmailSend = CASE WHEN LTRIM(EmailSend) <> '' THEN EmailSend + ',' ELSE '' END + TotalMailDriver
END

	
--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[WatchDog_DriverExpirationNotice] TO [public]
GO
