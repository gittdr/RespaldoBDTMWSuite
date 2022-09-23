SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OverWeight]
(
	@MinThreshold float = 78000,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalOverWeight',
	@WatchName varchar(255) = 'OverWeight',
	@ThresholdFieldName varchar(255) = 'Pounds',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)

As

	set nocount on
	
	/*
	Procedure Name:    WatchDog_OverWeight
	Author/CreateDate: David Wilks / 05/04/05
	Purpose: 	   Warn if tractor + trailer + shipment > threshold
	Revision History:
	*/
	
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Exec WatchDogPopulateSessionIDParamaters 'OverWeight',@WatchName 

	/*********************************************************************************************
		Step 1:
		
		Select Active_LegHeader where update time is within the minutes back 
			and join values from other tables needed in the calculation.
	*********************************************************************************************/
	SELECT  ord_hdrnumber,
			CONVERT(decimal(14,2), ISNULL(ord_totalvolume,'')) AS ord_totalvolume,
			cmd_code,
			CONVERT(decimal(14,2), ISNULL((SELECT cmd_specificgravity FROM commodity (NOLOCK) WHERE commodity.cmd_code = Legheader_Active.cmd_code),'')) AS cmd_specificgravity,
			lgh_tractor,
			ISNULL((SELECT trc_tareweight FROM tractorprofile (NOLOCK) WHERE trc_number = lgh_tractor),'') AS trc_tareweight,
			lgh_primary_trailer,
			ISNULL((SELECT trl_mtwgt FROM trailerprofile (NOLOCK) WHERE trl_number = lgh_primary_trailer),'') AS trl_mtwgt,
       		mov_number,
			npup_ctyname,
			ndrp_ctyname
	INTO   #TempLegs
	FROM   Legheader_Active (NOLOCK)
	WHERE  Legheader_Active.lgh_updatedon >= DATEADD(mi,@MinsBack,GETDATE())

	/*********************************************************************************************
		Step 2:
		
		Select Orders where the weight is above threshold.
	*********************************************************************************************/

	SELECT 	ord_hdrnumber AS [Order Number],
			ord_totalvolume AS [Total Volume],
			cmd_code AS [Comm Code],
  			cmd_specificgravity AS [Specific Gravity],
  			CONVERT(decimal(14,2), ISNULL((CASE WHEN ord_totalvolume > 8000 THEN ord_totalvolume ELSE ord_totalvolume * cmd_specificgravity END + trc_tareweight + trl_mtwgt),'')) As [Total Weight],
			lgh_tractor AS [Tractor ID],
			CONVERT(decimal(14,2), trc_tareweight) AS [Tractor Weight],
			lgh_primary_trailer AS [Trailer ID],
			CONVERT(decimal(14,2), trl_mtwgt) AS [Trailer Weight],
       		mov_number AS [Move #],
			npup_ctyname [Pickup City],
			ndrp_ctyname [Drop City]
	INTO   	#TempResults
	FROM   	#TempLegs
	WHERE  	cmd_specificgravity * ord_totalvolume + trc_tareweight + trl_mtwgt > @MinThreshold

	ORDER BY [Total Weight] DESC


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
GRANT EXECUTE ON  [dbo].[WatchDog_OverWeight] TO [public]
GO
