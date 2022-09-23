SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--WatchDogProcessing 'StopEvent' ,1

CREATE PROC [dbo].[WatchDog_StopEventTrailer]           
	(
		@MinThreshold FLOAT = 14, --Days Inactive
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalStopEventTrailer',
		@WatchName VARCHAR(255)='WatchStopEventTrailer',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@StopEventList VARCHAR(255) = '',
		@TrlType1 VARCHAR(255)='',
		@TrlType2 VARCHAR(255)='',
		@TrlType3 VARCHAR(255)='',
		@TrlType4 VARCHAR(255)='',
		@TrlFleet VARCHAR(255)='',
		@TrlDivision VARCHAR(255)='',
		@TrlCompany VARCHAR(255)='',
		@TrlTerminal VARCHAR(255)='',
		@TeamLeader VARCHAR(255)='',
		@BillTo VARCHAR(255)='',
		@NonDestinationStopsOnlyYN VARCHAR(1) = 'Y',
		@ParameterToUseForDynamicEmail VARCHAR(255)=''  -- @TrlType1-4, @TrlDivision, @TrlCompany, @TrlTermainal, @Teamleader
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
SET @TrlType1= ',' + ISNULL(@TrlType1,'') + ','
SET @TrlType2= ',' + ISNULL(@TrlType2,'') + ','
SET @TrlType3= ',' + ISNULL(@TrlType3,'') + ','
SET @TrlType4= ',' + ISNULL(@TrlType4,'') + ','

SET @TrlTerminal = ',' + ISNULL(@TrlTerminal,'') + ','
SET @TrlCompany = ',' + ISNULL(@TrlCompany,'') + ','
SET @TrlFleet = ',' + ISNULL(@TrlFleet,'') + ','
SET @TrlDivision = ',' + ISNULL(@TrlDivision,'') + ','
SET @TeamLeader = ',' + ISNULL(@TeamLeader,'') + ','

SET @StopEventList = ',' + ISNULL(@StopEventList,'') + ','
SET @BillTo = ',' + ISNULL(@BillTo,'') + ','

/****************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	Select the Tractor, Created by, Updated by, and event date for the
	user selected events.

*****************************************************************************/
SELECT 
	--stops.lgh_number, 
	stops.cmp_id,
	stops.trl_id,
	stp_schdtearliest,
	stp_schdtlatest,
	stp_arrivaldate,
	mov_number,
	(select min(stp_mfh_sequence) from stops s2 	(NOLOCK)
	where stops.mov_number = s2.mov_number and
		s2.stp_event = 'HLT') as NextStopMfh
into #TempPre
	FROM stops WITH (NOLOCK index = sk_stp_arrvdt)
	WHERE stp_arrivaldate between dateadd(d, -60, GETDATE()) and dateadd(d, 1, GETDATE())
		AND stp_status = 'DNE'
		AND stp_event = 'DLT'

select  #temppre.trl_id as [Trailer ID],
	#temppre.cmp_id as [Current Company Location],
	#temppre.stp_arrivaldate as [Arrival DateTime],
	stops.stp_schdtearliest [Hook Scheduled Earliest],
	stops.stp_schdtlatest [Hook Scheduled Latest],
	stops.lgh_number
into #Temp 
from stops (NOLOCK), #tempPre
where stops.mov_number = #tempPre.mov_number 
	and stops.stp_mfh_sequence = #tempPre.nextstopmfh
	and stops.stp_status <> 'DNE'

select #Temp.*, legheader.ord_hdrnumber 
into #Temp2
from #Temp join legheader (NOLOCK) on #Temp.lgh_number = legheader.lgh_number

select #Temp2.*, ord_billto, '           ' as NewPending
into #TempResultsStep1
from #temp2 join orderheader (NOLOCK) on #temp2.ord_hdrnumber = orderheader.ord_hdrnumber 
where (@BillTo =',,' or CHARINDEX(',' + ord_billto + ',', @BillTo) >0)

Update #TempResultsStep1
set NewPending = 'New'
where DATEDIFF(minute,[Arrival DateTime],GETDATE()) <= @minsback

Update #TempResultsStep1
set NewPending = 'Pending'
where DATEDIFF(minute,[Arrival DateTime],GETDATE()) > @minsback

select * into #TempResults 
from #TempresultsStep1
order by newpending,ord_billto,[current company location],[arrival datetime]



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
GRANT EXECUTE ON  [dbo].[WatchDog_StopEventTrailer] TO [public]
GO
