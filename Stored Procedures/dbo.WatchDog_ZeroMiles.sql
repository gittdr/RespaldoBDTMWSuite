SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[WatchDog_ZeroMiles]           
	(
		@MinThreshold FLOAT = 14, --Days Inactive
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalStopEvent',
		@WatchName VARCHAR(255)='WatchStopEvent',
		@ThresholdFieldName VARCHAR(255) = null,
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected'
 	)
						
AS

SET NOCOUNT ON

/***************************************************************
Procedure Name:    WatchDog_ZeroMiles
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


/****************************************************************************
	Create temp table #TempResults where the following conditions are met:
	
	Select the Tractor, Created by, Updated by, and event date for the
	user selected events.

*****************************************************************************/
select legheader.ord_hdrnumber, legheader.mov_number ,cmp_id
into #TempResults
from stops  (nolock) join legheader (nolock)on legheader.lgh_number = stops.lgh_number

where  IsNull(dbo.fnc_TMWRN_StopMiles(stp_number,default,default,default),0)		=0
and stp_city <> (select s.stp_city from stops s (nolock) 
		 where s.stp_mfh_sequence=stp_mfh_sequence+1 
			and s.mov_number = mov_number)
and stp_arrivaldate >= dateadd(mi,@MinsBack,getdate()) 
and stp_arrivaldate < '01/01/2049' 
and stp_lgh_status<>'CMP' 
and stp_lgh_mileage is not null


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
