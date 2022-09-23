SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_AssetContinuity]
(
--Reserved/Mandatory WatchDog Variables
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalAssetContinuity',
	@WatchName varchar(255) = 'AssetContinuity',
	@ThresholdFieldName varchar(255) = 'Miles Tolerance',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
-- Watchdog specific parameters
	@AssetTypes varchar (50)='',
	@AssetList varchar (255)='',
	@Mode varchar(50) = 'All', -- 'Planned'
	@ParameterToUseForDynamicEmail varchar(50) = '' 
)

As

/*
	-- for debugging queries
	drop table #TempTrl
	drop table #tempresults
	drop table ##WatchDogGlobalAssetContinuity
	DECLARE @MinThreshold float 
	SET @MinThreshold = 0
	DECLARE @MinsBack int
	SET @MinsBack = -999999
	DECLARE @TempTableName varchar(255) 
	SET @TempTableName = '##WatchDogGlobalAssetContinuity'
	DECLARE @WatchName varchar(255) 
	SET @WatchName = 'AssetContinuity'
	DECLARE @ThresholdFieldName varchar(255) 
	SET @ThresholdFieldName = ''
	DECLARE @ColumnNamesOnly bit 
	SET @ColumnNamesOnly = 0
	DECLARE @ExecuteDirectly bit 
	SET @ExecuteDirectly = 0
	DECLARE @ColumnMode varchar (50) 
	SET @ColumnMode ='Selected'
*/

	set nocount on
	
	/*
	Procedure Name:    WatchDog_AssetContinuity
	Author/CreateDate: David Wilks / 05/04/05
	Purpose: 	   Warn if asset is planned
	Revision History:
	*/
	
	
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	
		

	Exec WatchDogPopulateSessionIDParamaters 'AssetContinuity',@WatchName 

/*********************************************************************************************
	Step 1:
	
	Select current trailers from Active_LegHeader 
	where the trailer available company location <> planned company start
*********************************************************************************************/
Declare @AssetAssignements Table
(
	rownum int IDENTITY (1, 1) Primary key NOT NULL , 
	ord_hdrnumber int,
	lgh_mov_number int,
	asgn_type varchar(6),
	asgn_id varchar(13),
	start_cmp_id varchar(8),
	start_city int,
	end_cmp_id varchar(8),
	end_city int,
	asgn_date datetime,
	asgn_status varchar(6), 
	Company varchar(6),
	Division varchar(6),
	Domicile varchar(6),
	DrvType1 varchar(6),
	DrvType2 varchar(6),
	DrvType3 varchar(6),
	DrvType4 varchar(6),
	RevType1 varchar(6),
	RevType2 varchar(6),
	RevType3 varchar(6),
	RevType4 varchar(6),
	TeamLeader varchar(6),
	Terminal varchar(6),
	TrcType1 varchar(6),
	TrcType2 varchar(6),
	TrcType3 varchar(6),
	TrcType4 varchar(6),
	TrlType1 varchar(6),
	TrlType2 varchar(6),
	TrlType3 varchar(6),
	TrlType4 varchar(6)
)
declare @RowCnt int 
declare @MaxRows int 

CREATE TABLE #TempAssets
(   
	ord_hdrnumber int,
	lgh_mov_number int,
	asgn_type varchar(6),
	asgn_id varchar(13),
	previous_cmp_id varchar(8),
	previous_city int,
	asgn_date datetime,
	start_cmp_id varchar(8),
	start_city int,
	end_cmp_id varchar(8),
	end_city int,
	asgn_status varchar(6), 
	distance int,
    mpp_company varchar(6), 
	mpp_division varchar(6), 
	mpp_domicile varchar(6), 
    mpp_type1 varchar(6), 
    mpp_type2 varchar(6), 
    mpp_type3 varchar(6), 
    mpp_type4 varchar(6), 
    lgh_type1 varchar(6), 
    lgh_type2 varchar(6), 
    lgh_type3 varchar(6), 
    lgh_type4 varchar(6), 
    mpp_teamleader varchar(6), 
    mpp_terminal varchar(6), 
    trc_type1 varchar(6), 
    trc_type2 varchar(6), 
    trc_type3 varchar(6), 
    trc_type4 varchar(6), 
    trl_type1 varchar(6), 
    trl_type2 varchar(6), 
    trl_type3 varchar(6), 
    trl_type4 varchar(6) 
) 

	DECLARE	@ord_hdrnumber int,
			@lgh_mov_number int,
			@asgn_type varchar(6),
			@asgn_id varchar(13),
			@start_cmp_id varchar(8),
			@start_city int,
			@end_cmp_id varchar(8),
			@end_city int,
			@asgn_date datetime,
			@asgn_status varchar(6), 
			@distance int,
			@Company varchar(6),
			@Division varchar(6),
			@Domicile varchar(6),
			@DrvType1 varchar(6),
			@DrvType2 varchar(6),
			@DrvType3 varchar(6),
			@DrvType4 varchar(6),
			@RevType1 varchar(6),
			@RevType2 varchar(6),
			@RevType3 varchar(6),
			@RevType4 varchar(6),
			@TeamLeader varchar(6),
			@Terminal varchar(6),
			@TrcType1 varchar(6),
			@TrcType2 varchar(6),
			@TrcType3 varchar(6),
			@TrcType4 varchar(6),
			@TrlType1 varchar(6),
			@TrlType2 varchar(6),
			@TrlType3 varchar(6),
			@TrlType4 varchar(6)

	DECLARE	@Save_asgn_type varchar(6),
			@Save_asgn_id varchar(13),
			@Save_asgn_status varchar(6),
			@Save_end_cmp_id varchar(8),
			@Save_end_city Int,
			@Save_lgh_mov_number int

	SET @AssetTypes = ',' + ISNULL(@AssetTypes,'') + ','
	SET @AssetList = ',' + ISNULL(@AssetList,'') + ','


	insert into @AssetAssignements 
	select lgh.ord_hdrnumber, 
		lgh.mov_number,
		asgn_type,
		asgn_id, 
		sstops.cmp_id start_cmp_id, 
		Start_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = sstops.cmp_id),
		estops.cmp_id end_cmp_id,
		End_City = (select cmp_city FROM company c (NOLOCK) WHERE c.cmp_id = estops.cmp_id),
		asgn_date, 
		asgn_status,
	    mpp_company,
		mpp_division,
		mpp_domicile,
	    mpp_type1,
	    mpp_type2,
	    mpp_type3,
	    mpp_type4,
	    lgh_type1,
	    lgh_type2,
	    lgh_type3,
	    lgh_type4,
	    mpp_teamleader,
	    mpp_terminal,
	    trc_type1,
	    trc_type2,
	    trc_type3,
	    trc_type4,
	    trl_type1,
	    trl_type2,
	    trl_type3,
	    trl_type4

	FROM assetassignment (NOLOCK), legheader lgh (NOLOCK), 
		event sevent (NOLOCK), stops sstops (NOLOCK), event eevent (NOLOCK), stops estops (NOLOCK)
 	WHERE asgn_date >= DateAdd(mi,@MinsBack,GetDate()) 
		AND (@AssetTypes =',,' or CHARINDEX(',' + asgn_type + ',', @AssetTypes) >0)
		AND (@AssetList =',,' or CHARINDEX(',' + asgn_ID + ',', @AssetList) >0)
		AND assetassignment.lgh_number = lgh.lgh_number
		AND assetassignment.evt_number = sevent.evt_number
		AND sevent.stp_number = sstops.stp_number
		AND assetassignment.last_evt_number = eevent.evt_number
		AND eevent.stp_number = estops.stp_number
	order by asgn_type, asgn_id, asgn_date



select @MaxRows=count(*) from @AssetAssignements 

select @RowCnt = 1 

select 	@ord_hdrnumber=ord_hdrnumber, 
	@lgh_mov_number=lgh_mov_number, 
	@asgn_type=asgn_type,
	@asgn_id=asgn_id,
	@start_cmp_id=start_cmp_id,
	@start_city=start_city,
	@end_cmp_id=end_cmp_id,
	@end_city=end_city,
	@asgn_date=asgn_date,
	@asgn_status=asgn_status,
	@Company=Company,
	@Division=Division,
	@Domicile=Domicile,
	@DrvType1=DrvType1, 
	@DrvType2=DrvType2,
	@DrvType3=DrvType3,
	@DrvType4=DrvType4,
	@RevType1=RevType1,
	@RevType2=RevType2,
	@RevType3=RevType3,
	@RevType4=RevType4,
	@TeamLeader=TeamLeader,
	@Terminal=Terminal,
	@TrcType1=TrcType1,
	@TrcType2=TrcType2,
	@TrcType3=TrcType3,
	@TrcType4=TrcType4,
	@TrlType1=TrlType1,
	@TrlType2=TrlType2,
	@TrlType3=TrlType3,
	@TrlType4=TrlType4

from @AssetAssignements
where rownum = @RowCnt 

Select @RowCnt = @RowCnt + 1 

	SET @Save_asgn_type = @asgn_type 
	SET @Save_asgn_id = @asgn_id 
	SET @Save_asgn_status = @asgn_status 
	SET @Save_end_cmp_id = @end_cmp_id 
	SET @Save_lgh_mov_number = @lgh_mov_number
	SET @Save_end_city = @end_city 

while @RowCnt <= @MaxRows 
begin 

		IF @start_cmp_id <> @Save_end_cmp_id AND (@Mode = 'ALL' OR (@Mode = 'Planned' AND @asgn_status = 'PLN')) AND @Save_asgn_type = @asgn_type AND @Save_asgn_id = @asgn_id AND @Save_lgh_mov_number <> @lgh_mov_number
			BEGIN
			SET @distance = dbo.fnc_MilesBetweenCityCodes(@start_city, @Save_end_city)
			IF @distance = 0 SET @distance = null
			INSERT INTO #TempAssets([ord_hdrnumber], [lgh_mov_number], [asgn_type], [asgn_id], [previous_cmp_id], [previous_city], [start_cmp_id], [start_city], [end_cmp_id], [end_city], [asgn_date], [asgn_status], [distance],
									 [mpp_company], [mpp_division], [mpp_domicile], [mpp_type1], [mpp_type2], [mpp_type3], [mpp_type4], [lgh_type1], [lgh_type2], [lgh_type3], [lgh_type4], [mpp_teamleader], [mpp_terminal], [trc_type1], [trc_type2], [trc_type3], [trc_type4], [trl_type1], [trl_type2], [trl_type3], [trl_type4])
			VALUES(@ord_hdrnumber, @lgh_mov_number, @asgn_type, @asgn_id, @Save_end_cmp_id, @Save_End_City, @start_cmp_id, @start_city, @end_cmp_id, @end_city, @asgn_date, @asgn_status, @distance,
			@Company, @Division, @Domicile, @DrvType1, @DrvType2, @DrvType3, @DrvType4, @RevType1, @RevType2, @RevType3, @RevType4, @TeamLeader, @Terminal, @TrcType1, @TrcType2, @TrcType3, @TrcType4, @TrlType1, @TrlType2, @TrlType3, @TrlType4)
			END

		SET @Save_asgn_type = @asgn_type 
		SET @Save_asgn_id = @asgn_id 
		SET @Save_asgn_status = @asgn_status 
		SET @Save_end_cmp_id = @end_cmp_id 
		SET @Save_lgh_mov_number = @lgh_mov_number
		SET @Save_end_city = @end_city 
select 	@ord_hdrnumber=ord_hdrnumber, 
	@lgh_mov_number=lgh_mov_number, 
	@asgn_type=asgn_type,
	@asgn_id=asgn_id,
	@start_cmp_id=start_cmp_id,
	@start_city=start_city,
	@end_cmp_id=end_cmp_id,
	@end_city=end_city,
	@asgn_date=asgn_date,
	@asgn_status=asgn_status,
	@Company=Company,
	@Division=Division,
	@Domicile=Domicile,
	@DrvType1=DrvType1, 
	@DrvType2=DrvType2,
	@DrvType3=DrvType3,
	@DrvType4=DrvType4,
	@RevType1=RevType1,
	@RevType2=RevType2,
	@RevType3=RevType3,
	@RevType4=RevType4,
	@TeamLeader=TeamLeader,
	@Terminal=Terminal,
	@TrcType1=TrcType1,
	@TrcType2=TrcType2,
	@TrcType3=TrcType3,
	@TrcType4=TrcType4,
	@TrlType1=TrlType1,
	@TrlType2=TrlType2,
	@TrlType3=TrlType3,
	@TrlType4=TrlType4

from @AssetAssignements
where rownum = @RowCnt 

Select @RowCnt = @RowCnt + 1 
	END

	SELECT
	ord_hdrnumber AS [Order #],
	lgh_mov_number AS [Move #],
	asgn_type AS [Asset Type],
	asgn_id [Asset ID],
	previous_cmp_id AS [Previous Company],
	(select cty_nmstct from city (NOLOCK) where cty_code = previous_city) AS [Previous City],
	asgn_date AS [Assign Date],
	start_cmp_id AS [Start Company],
	(select cty_nmstct from city (NOLOCK) where cty_code = start_city) AS [Start City],
	end_cmp_id AS [End Company],
	(select cty_nmstct from city (NOLOCK) where cty_code =end_city) AS [End City],
	asgn_status AS [Assignment Status], 
	IsNull(Convert(varchar(30), distance),'Unknown') AS [Discrepancy Miles], 
	ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, mpp_company, mpp_division, mpp_domicile, default, mpp_type1, mpp_type2, mpp_type3, mpp_type4, default, lgh_type1, lgh_type2, lgh_type3, lgh_type4, mpp_teamleader, mpp_terminal, default, trc_type1, trc_type2, trc_type3, trc_type4, default, trl_type1, trl_type2, trl_type3, trl_type4, default),'') AS EmailSend 
   
	INTO #TempResults
	FROM #TempAssets


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
GRANT EXECUTE ON  [dbo].[WatchDog_AssetContinuity] TO [public]
GO
