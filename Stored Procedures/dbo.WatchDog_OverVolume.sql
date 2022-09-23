SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[WatchDog_OverVolume]
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalOverVolume',
	@WatchName varchar(255) = 'OverVolume',
	@ThresholdFieldName varchar(255) = 'Gallons',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)

As

	set nocount on
	
	/*
	Procedure Name:    WatchDog_OverVolume
	Author/CreateDate: David Wilks / 05/04/05
	Purpose: 	   Warn if volume on trailer + shipment > threshold
	Revision History:
	*/
	
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Exec WatchDogPopulateSessionIDParamaters 'OverVolume',@WatchName 

/*********************************************************************************************
	Step 1:
	
	Select current FreightDetail from Active_LegHeader 
        to reduce overhead in remaining joins and filters
*********************************************************************************************/

	CREATE TABLE #TempFD
	(   
		fgt_volume DECIMAL(14,2),
		fgt_ordered_volume DECIMAL(14,2),
		stp_number int,
		fgt_reftype varchar(6),
		cmd_code varchar(8)
	)

	INSERT INTO  #TempFD 
	SELECT  CONVERT(decimal(14,2), ISNULL(fgt_volume,0)) AS fgt_volume,
		CONVERT(decimal(14,2), ISNULL(fgt_ordered_volume,0)) AS fgt_ordered_volume,
		stp_number,
		fgt_reftype,
		cmd_code
	FROM   FreightDetail (NOLOCK)
	WHERE stp_number IN (SELECT stp_number FROM stops (NOLOCK)
	WHERE lgh_number IN (SELECT lgh_number FROM LegHeader_Active (NOLOCK) WHERE lgh_updatedon >= DateAdd(mi,@MinsBack,GetDate())))

	--select * from #tempFd --where stp_number='2849177'
	--select * from stops where lgh_number='686046'


/*********************************************************************************************
	Step 2:
	
	Join FreightDetail to get primary trailer
*********************************************************************************************/

	CREATE TABLE #TempFD2
	(   
		ord_hdrnumber INT,
		lgh_primary_trailer varchar(13),
		fgt_volume DECIMAL(14,2),
		fgt_ordered_volume DECIMAL(14,2),
		stp_number int,
		fgt_reftype varchar(6),
		cmd_code varchar(8)
	)

	INSERT INTO  #TempFD2 

	SELECT  ISNULL((SELECT TOP 1 ord_hdrnumber FROM Stops (NOLOCK) WHERE #TempFD.stp_number = Stops.stp_number),0) AS ord_hdrnumber,
		ISNULL((SELECT TOP 1 lgh_primary_trailer FROM LegHeader_Active (NOLOCK) WHERE lgh_number = (SELECT TOP 1 lgh_number FROM Stops (NOLOCK) WHERE #TempFD.stp_number = Stops.stp_number)),'') AS lgh_primary_trailer,
		fgt_volume,
		fgt_ordered_volume,
		stp_number,
		fgt_reftype,
		cmd_code
	FROM   #TempFD (NOLOCK)

/*********************************************************************************************
	Step 3:
	
	Join TrailerDetail to compare trailer compartment volume to freightdetail volume
	and join other display fields that are needed.
*********************************************************************************************/

	CREATE TABLE #TempFD3
	(   
		ord_hdrnumber INT,
		ord_originpoint varchar(8),
		lgh_primary_trailer varchar(13),
		trl_det_vol DECIMAL(14,2),
		fgt_ordered_volume DECIMAL(14,2),
		fgt_volume FLOAT,
		stp_number int,
		fgt_reftype varchar(6),
		cmd_code varchar(8)
	)

	INSERT INTO   #TempFD3 
	SELECT  ord_hdrnumber,
		ISNULL((SELECT ord_originpoint FROM OrderHeader o (NOLOCK) WHERE o.ord_hdrnumber = #TempFD2.ord_hdrnumber),'') AS ord_originpoint,
		lgh_primary_trailer,
		CONVERT(decimal(14,2), (CASE WHEN SUBSTRING(#TempFD2.fgt_reftype,2,1) = 'C' THEN (SELECT trl_det_vol FROM trailer_detail td (NOLOCK) WHERE td.trl_id = #TempFD2.lgh_primary_trailer AND td.trl_det_compartment = convert(integer,SUBSTRING(#TempFD2.fgt_reftype,1,1))) ELSE (SELECT TOP 1 trl_det_vol FROM trailer_detail td (NOLOCK) WHERE td.trl_id = #TempFD2.lgh_primary_trailer) END)) AS trl_det_vol,
		CONVERT(decimal(14,2), ISNULL(fgt_ordered_volume,0)) AS fgt_ordered_volume,
		fgt_volume,
		stp_number,
		fgt_reftype,
		cmd_code
	FROM   #TempFD2 (NOLOCK) 

/*********************************************************************************************
	Step 5:
	
	Delete from results if freightdetail volume is not greater than compartment volume
	and format headings
*********************************************************************************************/

	SELECT  ord_hdrnumber AS [Order Number],
		ord_originpoint AS [Origin Point],
		lgh_primary_trailer AS [Trailer],
		fgt_ordered_volume AS [Ordered Volume],
		trl_det_vol AS [Compartment Volume],
		fgt_volume AS [Actual Volume],
		stp_number AS [Stop Number],
		fgt_reftype AS [Freight Compartment],
		cmd_code As [Comm Code]
	INTO   #TempResults
	FROM   #TempFD3 (NOLOCK)
	WHERE trl_det_vol < fgt_volume --or trl_det_vol > fgt_ordered_volume
	ORDER BY [Order Number]

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
GRANT EXECUTE ON  [dbo].[WatchDog_OverVolume] TO [public]
GO
