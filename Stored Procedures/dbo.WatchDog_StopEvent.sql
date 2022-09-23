SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'StopEvent' ,1

CREATE PROC [dbo].[WatchDog_StopEvent]           
	(
		@MinThreshold FLOAT = 14, --Days Inactive
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalStopEvent',
		@WatchName VARCHAR(255)='WatchStopEvent',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@StopEventList VARCHAR(255) = '',
		@TrcType1 VARCHAR(255)='',
		@TrcType2 VARCHAR(255)='',
		@TrcType3 VARCHAR(255)='',
		@TrcType4 VARCHAR(255)='',
		@TrcFleet VARCHAR(255)='',
		@TrcDivision VARCHAR(255)='',
		@TrcCompany VARCHAR(255)='',
		@TrcTerminal VARCHAR(255)='',
		@TeamLeader VARCHAR(255)='',
		@ParameterToUseForDynamicEmail VARCHAR(255)='',  -- @TrcType1-4, @TrcDivision, @TrcCompany, @TrcTermainal, @Teamleader
		@RefType VARCHAR(255)=''
 	)
						
AS

SET NOCOUNT ON

/***************************************************************
Procedure Name:    WatchDog_StopEvent
Author/CreateDate: Lori Brickley / 1-13-2005
Purpose: 	   	Provides a list of user defined stop events 
				which occured within the last x minutes		
Revision History:	
****************************************************************/

--Reserved/Mandatory WatchDog Variables
Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
SET @TrcType1= ',' + ISNULL(@TrcType1,'') + ','
SET @TrcType2= ',' + ISNULL(@TrcType2,'') + ','
SET @TrcType3= ',' + ISNULL(@TrcType3,'') + ','
SET @TrcType4= ',' + ISNULL(@TrcType4,'') + ','

SET @TrcTerminal = ',' + ISNULL(@TrcTerminal,'') + ','
SET @TrcCompany = ',' + ISNULL(@TrcCompany,'') + ','
SET @TrcFleet = ',' + ISNULL(@TrcFleet,'') + ','
SET @TrcDivision = ',' + ISNULL(@TrcDivision,'') + ','
SET @TeamLeader = ',' + ISNULL(@TeamLeader,'') + ','

SET @StopEventList = ',' + ISNULL(@StopEventList,'') + ','
SET @RefType = ',' + ISNULL(@RefType,'') + ','

/****************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	Select the Tractor, Created by, Updated by, and event date for the
	user selected events.

*****************************************************************************/
SELECT  
	stp_schdtearliest as [Event Start Date],
	LegHeader.mov_number AS Movement,
	lgh_tractor AS [Tractor],
    lgh_driver1 AS [Driver],
	stp_lgh_mileage AS [Miles],
	mpp_teamleader as [Team Leader],
	lgh_createdby as [Create User],
	lgh_updatedby as [Update User],
	EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, trc_company,trc_division,default,default,default,default,default,default,default,default,default,default,default,mpp_teamleader,trc_terminal,default,trc_type1,trc_type2,trc_type3,trc_type4,default,default,default,default,default,default),'')
INTO #TempResults
FROM stops (NOLOCK) JOIN legheader (NOLOCK) ON stops.lgh_number = legheader.lgh_number
WHERE stp_schdtearliest >= DATEADD(mi,@MinsBack,GETDATE())
	AND (@TrcType1 =',,' OR CHARINDEX(',' + trc_type1 + ',', @TrcType1) >0)
    AND (@TrcType2 =',,' OR CHARINDEX(',' + trc_type2 + ',', @TrcType2) >0)
    AND (@TrcType3 =',,' OR CHARINDEX(',' + trc_type3 + ',', @TrcType3) >0)
    AND (@TrcType4 =',,' OR CHARINDEX(',' + trc_type4 + ',', @TrcType4) >0)
	AND (@TrcTerminal =',,' OR CHARINDEX(',' + trc_terminal + ',', @TrcTerminal) >0)
    AND (@TrcFleet =',,' OR CHARINDEX(',' + trc_fleet + ',', @TrcFleet) >0)
    AND (@TrcCompany =',,' OR CHARINDEX(',' + trc_company + ',', @TrcCompany) >0)
    AND (@TrcDivision =',,' OR CHARINDEX(',' + trc_division + ',', @TrcDivision) >0) 
	AND (@TeamLeader =',,' OR CHARINDEX(',' + mpp_teamleader + ',', @TeamLeader) >0)
	AND (@StopEventList =',,' OR CHARINDEX(',' + stp_event + ',', @StopEventList) >0)
	AND (@RefType =',,' OR CHARINDEX(',' + (SELECT ord_reftype FROM OrderHeader O (NOLOCK) Where Legheader.ord_hdrnumber = O.ord_hdrnumber) + ',', @RefType) >0)
ORDER BY stp_schdtearliest DESC


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
GRANT EXECUTE ON  [dbo].[WatchDog_StopEvent] TO [public]
GO
