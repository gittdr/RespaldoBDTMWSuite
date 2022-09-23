SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--WatchDogProcessing 'TractorExpirationNotice' ,1

CREATE PROC [dbo].[WatchDog_ExtremeTractorExpirationNotice] 
	(
		@MinThreshold FLOAT = 14, -- Days
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalExtremeTractorExpirationNotice',
		@WatchName VARCHAR(255)='WatchExtremeTractorExpirationNotice',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@ExpirationCode VARCHAR(255)='',
		--@AssetType VARCHAR(255) = '',
		@TrcType1 VARCHAR(255) = '',
        @TrcType2 VARCHAR(255) = '',
        @TrcType3 VARCHAR(255) = '',
        @TrcType4 VARCHAR(255) = '',
        @TrcFleet VARCHAR(255)='',
        @TrcDivision VARCHAR(255)='',
        @TrcCompany VARCHAR(255)='',
        @TrcTerminal VARCHAR(255)='',
		@TeamLeaderList VARCHAR(255)=''
	)
						

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_ExtremeTractorExpirationNotice
Author/CreateDate: Lori Brickley / 5-17-2005
Purpose: 	   Select Tractor and Expiration data where the expiration is not completed and it is
	greater than the minimum threshold days.
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @ExpirationCode= ',' + ISNULL(@ExpirationCode,'') + ','

SET @TrcType1= ',' + ISNULL(@TrcType1,'') + ','
SET @TrcType2= ',' + ISNULL(@TrcType2,'') + ','
SET @TrcType3= ',' + ISNULL(@TrcType3,'') + ','
SET @TrcType4= ',' + ISNULL(@TrcType4,'') + ','

SET @TrcTerminal = ',' + ISNULL(@TrcTerminal,'') + ','
SET @TrcCompany = ',' + ISNULL(@TrcCompany,'') + ','
SET @TrcFleet = ',' + ISNULL(@TrcFleet,'') + ','
SET @TrcDivision = ',' + ISNULL(@TrcDivision,'') + ','

SET @TeamLeaderList = ',' + ISNULL(@TeamLeaderList,'') + ','


/*******************************************************************************************
	Select Driver and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
*******************************************************************************************/
SELECT 	trc_number AS [Tractor ID],
       	exp_code AS [Expiration Code],
       	[Expiration] = 	(
							SELECT labelfile.name 
							FROM labelfile (NOLOCK) 
							WHERE labelfile.abbr = exp_code 
								AND labeldefinition = exp_idtype + 'Exp'
						),
       	DATEDIFF(DAY,exp_expirationdate,GETDATE()) AS [Days Out],
       	exp_expirationdate AS [Expiration Date],
		trc_driver as [Driver ID],
		exp_description as [Description]
INTO   	#TempResults 
FROM   	Expiration (NOLOCK) 
		INNER JOIN tractorprofile (NOLOCK) ON trc_number = exp_id AND exp_idtype = 'TRC'
		LEFT JOIN manpowerprofile (NOLOCK) ON trc_driver = mpp_id
WHERE  	(@ExpirationCode =',,' OR CHARINDEX(',' + exp_code + ',', @ExpirationCode) >0)
      	AND ((exp_completed = 'N' AND DateDiff(day,exp_expirationdate,GetDate()) >= @MinThreshold))
      	AND (@TrcType1 =',,' OR CHARINDEX(',' + trc_type1 + ',', @TrcType1) >0)
      	AND (@TrcType2 =',,' OR CHARINDEX(',' + trc_type2 + ',', @TrcType2) >0)
      	AND (@TrcType3 =',,' OR CHARINDEX(',' + trc_type3 + ',', @TrcType3) >0)
      	AND (@TrcType4 =',,' OR CHARINDEX(',' + trc_type4 + ',', @TrcType4) >0)
      	AND (@TrcTerminal =',,' OR CHARINDEX(',' + trc_terminal + ',', @TrcTerminal) >0)
      	AND (@TrcFleet =',,' OR CHARINDEX(',' + trc_fleet + ',', @TrcFleet) >0)
      	AND (@TrcCompany =',,' OR CHARINDEX(',' + trc_company + ',', @TrcCompany) >0)
      	AND (@TrcDivision =',,' OR CHARINDEX(',' + trc_division + ',', @TrcDivision) >0)
		AND (@TeamLeaderList =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @TeamLeaderList) >0)
      	AND (trc_retiredate > GetDate() OR trc_retiredate IS NULL)
ORDER BY exp_expirationdate ASC

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
