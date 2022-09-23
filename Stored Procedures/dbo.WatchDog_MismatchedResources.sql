SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_MismatchedResources]
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalMismatchedResources',
	@WatchName varchar(255) = 'MismatchedResources',
	@ThresholdFieldName varchar(255) = 'tractor', -- ????
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)
/*	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)=''						     )
*/

As

	set nocount on
	
	/*
	Procedure Name:    WatchDog_MismatchedResources
	Author/CreateDate: Don George / 4/12/05
	Purpose: 	   
	Revision History:
	*/
	
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	

	Exec WatchDogPopulateSessionIDParamaters 'MismatchedResources',@WatchName 

--	SELECT 'test' AS Field1, '123' AS FIeld2 INTO #TempResults
	
	--Create SQL and return results into #TempResults
--	select * from tractorprofile -- trc_number / trc_driver
--	select * from legheader -- lgh_tractor / lgh_driver1
-- check on this date:	 legheader_active.lgh_updatedon

	SELECT lgh_outstatus AS Status, lgh_number AS TripSegment, ord_hdrnumber AS [Order number], lgh_tractor AS LegTractor, lgh_driver1 AS LegDriver1, lgh_driver2 AS LegDriver2,
		FileMaintDriver1 = (SELECT trc_driver FROM tractorprofile (NOLOCK) WHERE trc_number = t1.lgh_tractor ),
		FileMaintDriver2 = (SELECT trc_driver2 FROM tractorprofile (NOLOCK) WHERE trc_number = t1.lgh_tractor ),
		lgh_updatedon AS UpdatedOn, lgh_updatedby As UpdatedBy,
		lgh_startdate, lgh_enddate
	INTO #tempresults
	FROM legheader t1 (NOLOCK) 
	WHERE lgh_updatedon >= DateAdd(mi, @MinsBack, GetDate())
		AND NOT EXISTS(SELECT trc_number FROM tractorprofile (NOLOCK) 
					WHERE trc_number = t1.lgh_tractor AND trc_driver = t1.lgh_driver1 
						AND trc_number = t1.lgh_tractor AND trc_driver2 = t1.lgh_driver2
					)
	ORDER BY lgh_outstatus, lgh_number 



	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1, @SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End
	
	Exec (@SQL)
	
	set nocount off
GO
GRANT EXECUTE ON  [dbo].[WatchDog_MismatchedResources] TO [public]
GO
