SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[WatchDog_TM_SystemDown]
	(
		@MinThreshold FLOAT = 0, --Days Inactive
		@MinsBack INT=-20, -- Overrides the TimeOut fields
		@TempTableName VARCHAR(255) = '##WatchDogGlobalTotalMailSystemDown',
		@WatchName VARCHAR(255)='WatchTotalMailSystemDown',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@TotalMailSystem VARCHAR(255) = 'Delivery', --Or QualComm, MobileComm,Transaction, PeopleNet, MCWeb, D2Link, FleetAdvisor
													-- QualComm, HighwayMaster, AMSC, RockWell, Terion, TTIS, TACS, Intouch, QMASS, FleetAdvisor, Cadec, SummarySystemsM, MCWeb, GeoCom, ICS, FlatFileC, D2Link-I58, AtRoad
		@AlertMessage VARCHAR(255)='', -- Overrides the Total Mail alert message
		@AmbientDeviceID VARCHAR(25)='',
		@AmbientAnimation int=0,
		@AmbientColor int=0,
		@AmbientComment VARCHAR(255)=''
 	)
						
AS

SET NOCOUNT ON

/***************************************************************
Procedure Name:    WatchDog_TM_SystemDown
Author/CreateDate: Lori Brickley / 3-22-2005
Purpose: 	   	Provides an alert for possible system down
				which occured within the last x minutes		
Revision History:	
4/17/2008:	Added IsNull evaluation of @MinThreshold to assure valid comparison value
4/21/2008:	Corrected @MinThreshold identification Where clause

****************************************************************/



--Reserved/Mandatory WatchDog Variables
Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Initialize Variables

	If @MinThreshold = 0
		Begin
			SELECT @MinThreshold =	
				CASE @TotalMailSystem
					WHEN 'DELIVERY' THEN (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'timeoutdlv')
					WHEN 'QUALCOMM' THEN 
						CASE WHEN EXISTS(SELECT sn FROM tblrs WHERE keycode = 'TimeoutG01') THEN  
								(SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'TimeoutG01') -- TotalMail changed how they did this.
							ELSE (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'timeoutQC')
						END
					WHEN 'MOBILECOMM' THEN (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'timeoutGen')
					WHEN 'TRANSACTION' THEN (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'timeoutTMX')
				ELSE 
					(SELECT TOP 1 [text] 
						FROM tblRS (NOLOCK) 
--						WHERE KeyCode = 'timeoutGen' 
-- 4/21/2008: corrected per communication with Dave Gudat
						WHERE KeyCode = 'timeoutG' 
							+ RIGHT('0'+ISNULL((SELECT CONVERT(varchar(3), sn) 
												FROM tblMobileCommType (NOLOCK) 
												WHERE MobileCommType = @TotalMailSystem ), 'X')
								, 2)
						)
				END
		End
-- 4/17/2008: added to force valid Threshold value if necessary
	Set @MinThreshold = IsNull(@MinThreshold,5)

	IF @AlertMessage = ''
		SET @AlertMessage = (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'vWarnText')
						   	  
/****************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	Select the System, Current Date/Time, Last Date/Time Stamp, Message
	where the time between the last datetime stamp and current is greater than
	x minutes back

	NOTE!!  Timestamp value in tblRS is in Greenwich Mean Time.  Conversion to
			local time is done in the code below.

*****************************************************************************/
SELECT TOP 1 @TotalMailSystem [Total Mail Agent], 
		GETDATE() [Current Date/Time], 
		DATEADD(Hour, DATEDIFF(Hour, GETUTCDATE(), GETDATE()), -- PTS 45360 ==>> Result of DATEDIFF should be negative.
			CASE @TotalMailSystem
				WHEN 'DELIVERY' THEN (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'TStmpDlv')
				WHEN 'QUALCOMM' THEN 
						CASE WHEN EXISTS(SELECT sn FROM tblrs WHERE keycode = 'TStmpGen01') THEN  
								(SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'TStmpGen01') -- TotalMail changed how they did this.
							ELSE (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'TStmpQCom')
						END
				WHEN 'MOBILECOMM' THEN (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'TStmpGen')
				WHEN 'TRANSACTION' THEN (SELECT TOP 1 [text] FROM tblRS (NOLOCK) WHERE KeyCode = 'TStmpXact')
			ELSE
					(SELECT TOP 1 [text] FROM tblRS (NOLOCK) 
						WHERE KeyCode = 'TStmpGen' 
							+ RIGHT('0'+ISNULL((SELECT CONVERT(varchar(3), sn) 
												FROM tblMobileCommType (NOLOCK) 
												WHERE MobileCommType = @TotalMailSystem ), 'X')
								, 2)
					)
			END) AS [Last Time Stamp],
		@AlertMessage [Alert Message],
		@AmbientDeviceID AmbientDeviceID,
		@AmbientAnimation AmbientAnimation,
		@AmbientColor AmbientColor,
		@AmbientComment AmbientComment
INTO #TempResults
FROM tblRS (NOLOCK) 

-- UPDATE #TempResults SET [Last Time Stamp] = DATEADD(minute, -3, [Last Time Stamp]) -- for testing

DELETE FROM #TempResults WHERE DateDiff(mi,[Last Time Stamp],[Current Date/Time]) < @MinThreshold

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'IF (SELECT COUNT(*) FROM #TempResults) > 0 SELECT * FROM #TempResults'
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
GRANT EXECUTE ON  [dbo].[WatchDog_TM_SystemDown] TO [public]
GO
