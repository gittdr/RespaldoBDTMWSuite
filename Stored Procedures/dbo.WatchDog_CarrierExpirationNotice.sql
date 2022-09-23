SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'DriverExpirationNotice' ,1

CREATE PROC [dbo].[WatchDog_CarrierExpirationNotice] 
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
		@CarType1 VARCHAR(255) = '',
       	@CarType2 VARCHAR(255) = '',
       	@CarType3 VARCHAR(255) = '',
       	@CarType4 VARCHAR(255) = '',
		@Excludecode VARCHAR(255)= '',
		@ExcludeCarrierStatus VARCHAR(255)='N'
		
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


/*

if not exists (select WatchName from WatchDogItem where WatchName = 'CarrierExpirationNotice')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('CarrierExpirationNotice','12/30/1899','12/30/1899','WatchDog_CarrierExpirationNotice','','',0,0,'','','','','',1,0,'','','')

*/
--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @ExpirationCode= ',' + ISNULL(@ExpirationCode,'') + ','

SET @CarType1= ',' + ISNULL(@CarType1,'') + ','
SET @CarType2= ',' + ISNULL(@CarType2,'') + ','
SET @CarType3= ',' + ISNULL(@CarType3,'') + ','
SET @CarType4= ',' + ISNULL(@CarType4,'') + ','


SET @Excludecode = ',' + ISNULL(@Excludecode,'') + ','
SET @ExcludeCarrierStatus = ',' + ISNULL(@ExcludeCarrierStatus,'') + ','


/*******************************************************************************************
	Select Driver and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
*******************************************************************************************/
SELECT 	exp_id AS [Carrier ID],
       	CASE WHEN exp_idtype = 'CAR' THEN
			(SELECT car_name FROM carrier (NOLOCK) WHERE car_id = exp_id)
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
       	exp_description as [Description],
		car_type1 as [CarType1],
		car_type2 as [CarType2],
		car_type3 as [CarType3],
		car_type4 as [CarType4]
INTO   	#TempResults 
FROM   	Expiration (NOLOCK) INNER JOIN carrier (NOLOCK) ON car_id = exp_id AND exp_idtype = 'CAR'
WHERE  	(@ExpirationCode =',,' OR CHARINDEX(',' + exp_code + ',', @ExpirationCode) >0)
      	AND ((exp_completed = 'N' AND DateDiff(minute,GetDate(),exp_expirationdate) <= @MinThreshold * 24 * 60))
      	AND (@CarType1 =',,' OR CHARINDEX(',' + car_type1 + ',', @CarType1) >0)
      	AND (@CarType2 =',,' OR CHARINDEX(',' + car_type2 + ',', @CarType2) >0)
      	AND (@CarType3 =',,' OR CHARINDEX(',' + car_type3 + ',', @CarType3) >0)
      	AND (@CarType4 =',,' OR CHARINDEX(',' + car_type4 + ',', @CarType4) >0)
		AND (@Excludecode  =',,' OR CHARINDEX(',' + exp_code + ',', @Excludecode ) =0)
		AND (@ExcludeCarrierStatus =',,' OR CHARINDEX(',' + car_status + ',', @ExcludeCarrierStatus) =0)
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
