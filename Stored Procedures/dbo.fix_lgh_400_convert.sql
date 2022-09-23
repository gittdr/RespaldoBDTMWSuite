SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[fix_lgh_400_convert] (@mov int)
AS 

DECLARE @minlgh 		int,
	@minseq 		smallint,
	@maxseq 		smallint,
	@ordnum 		int,
	@cmd 			char(8),
	@desc 			varchar(30),
	@pri 			char(6),
	@stat 			char(6),
	@instat 		char(6),
	@startdate 		datetime,
	@startcity 		int,
	@startcomp 		char(8),
	@startstop 		int,
	@enddate 		datetime,
	@oldenddate     	datetime,
	@endcity 		int,
	@endcomp 		char(8),
	@endstop 		int,
	@early 			datetime,
	@late 			datetime,
	@opn 			smallint,
	@cls 			smallint,
	@type 			char(6),
	@id 			char(13),
	@type1 			char(6),
	@type2 			char(6),
	@type3 			char(6),
	@type4 			char(6),
	@asgns 			tinyint,
	@trailer 		char(13),
	@trailer2 		char(13),
	@tractor 		char(8),
	@lghtractor 		char(8),
	@carrier 		char(8),
	@drvtrc 		char(8),
	@driver1 		char(8),
	@driver2 		char(8),
	@trcdriver1 		char(8),
	@trcdriver2 		char(8),
	@lgh 			int,
	@avlstat 		char(6),
	@avldate 		datetime,
	@avlcmp 		char(8),
	@avlcity 		int,
	@idx 			smallint,
	@minasgn 		int,
	@lghstring 		char(8),
	@trace 			varchar(64),
	@ret			int,
	@lgh_startregion1       varchar(6),
	@lgh_startregion2       varchar(6),
	@lgh_startregion3       varchar(6),
	@lgh_startregion4       varchar(6),
	@lgh_startstate		char(2),		
	@lgh_startcty_nmstct	varchar(25),
	@lgh_endregion1		varchar(6),
	@lgh_endregion2		varchar(6),
	@lgh_endregion3		varchar(6),
	@lgh_endregion4		varchar(6),
	@lgh_endstate		char(2),	
	@lgh_endcty_nmstct	varchar(25),
	@mpp_teamleader       	varchar(6),
	@mpp_fleet       	varchar(6),
	@mpp_division       	varchar(6),
	@mpp_domicile       	varchar(6),
	@mpp_company       	varchar(6),
	@mpp_terminal       	varchar(6),
	@mpp_type1       	varchar(6),
	@mpp_type2       	varchar(6),
	@mpp_type3       	varchar(6),
	@mpp_type4       	varchar(6),
	@trc_company       	varchar(6),
	@trc_division       	varchar(6),
	@trc_fleet       	varchar(6),
	@trc_terminal       	varchar(6),
	@trc_type1       	varchar(6),
	@trc_type2       	varchar(6),
	@trc_type3       	varchar(6),
	@trc_type4       	varchar(6),
	@trl_company       	varchar(6),
	@trl_fleet       	varchar(6),
	@trl_division       	varchar(6),
	@trl_terminal       	varchar(6),
	@trl_type1       	varchar(6),
	@trl_type2       	varchar(6),
	@trl_type3       	varchar(6),
	@trl_type4       	varchar(6),
	@lgh_active	        char(1),
	@check_active 		char(1),
	@check_instatus 	char(6),
	@check_outstatus 	char(6)


/* make sure legheaders exists for actual stops */

SELECT @minlgh = 0

SELECT @idx = 0

/* get the max order hdr on the move */
SELECT @ordnum = (	SELECT 	MAX(ord_hdrnumber) 
			FROM 	stops
			WHERE 	mov_number = @mov)



/* Loop for all legheaders which have all 'NON' stops, on the passed move */
WHILE 1=1
BEGIN
	SELECT @idx = @idx + 1

	SELECT 	@minlgh = MIN(lgh_number)
	FROM 	stops 
	WHERE 	lgh_number > @minlgh
		AND stp_status <> 'NON'
		AND mov_number = @mov

	IF @minlgh IS NULL
		BREAK

	/* get the max & min stop mfh_sequence for the current leghdr */
	SELECT 	@maxseq = MAX(stp_mfh_sequence), @minseq = MIN(stp_mfh_sequence)
	FROM 	stops
	WHERE 	mov_number = @mov
		AND lgh_number = @minlgh


	/* Get the known tractor, driver1, driver2, carrier for the current leg and 
	   primary events */
	SET ROWCOUNT 1
		
	SELECT 	@tractor = null

	SELECT 	@tractor = e.evt_tractor
	FROM 	event e, stops s
	WHERE 	s.lgh_number = @minlgh
		AND e.evt_tractor <> 'UNKNOWN'
		AND s.stp_number = e.stp_number
		AND e.evt_sequence = 1

	IF @tractor IS null
		SELECT @lghtractor = 'UNKNOWN'
	ELSE
		SELECT @lghtractor = @tractor

	SELECT @driver1 = null

	SELECT 	@driver1 = evt_driver1
	FROM 	event e, stops s
	WHERE 	s.lgh_number = @minlgh
		AND e.evt_driver1 <> 'UNKNOWN'
		AND s.stp_number = e.stp_number
		AND e.evt_sequence = 1

	SELECT @driver2 = null

	SELECT 	@driver2 = e.evt_driver2
	FROM 	event e, stops s
	WHERE 	s.lgh_number = @minlgh
		AND e.evt_driver2 <> 'UNKNOWN'
		AND s.stp_number = e.stp_number
		AND e.evt_sequence = 1

	SELECT 	@carrier = null

	SELECT 	@carrier = evt_carrier
	FROM 	event e, stops s
	WHERE 	s.lgh_number = @minlgh
		AND e.evt_carrier <> 'UNKNOWN'
		AND s.stp_number = e.stp_number
		AND e.evt_sequence = 1

	SET ROWCOUNT 0

	sELECT 	@trailer = lgh_primary_trailer,
		@trailer2 = lgh_primary_pup,
		@check_instatus = lgh_instatus,
		@check_outstatus = lgh_outstatus,
		@check_active = lgh_active
	from legheader
	where lgh_number = @minlgh

	if @check_instatus = 'HST' and @check_outstatus = 'CMP'
		select @lgh_active = 'N'

	else
		select @lgh_active = 'Y'
	

	/* get the startdate, enddate, startcity, endcity, startstop, endstop, startcompany, 
	    endcompany, early & late dates from the min and max stops. */
	SELECT 	@startdate = s1.stp_arrivaldate,
		@enddate = s2.stp_arrivaldate,  
		@startcity = s1.stp_city,
		@endcity = s2.stp_city,
		@startstop = s1.stp_number,
		@endstop = s2.stp_number,
		@startcomp = s1.cmp_id,
		@endcomp = s2.cmp_id,
		@early = s1.stp_schdtearliest,
		@late = s1.stp_schdtlatest
	FROM 	stops s1, stops s2
	WHERE 	s1.lgh_number = @minlgh
		AND s1.stp_mfh_sequence = @minseq
		AND s2.lgh_number = @minlgh
		AND s2.stp_mfh_sequence = @maxseq


	/* 11/5/97 MF Load denormalized columns for legheader table */
	select 	@lgh_startregion1 = cty_region1,
		@lgh_startregion2 = cty_region2, 
		@lgh_startregion3 = cty_region3, 
		@lgh_startregion4 = cty_region4, 
		@lgh_startstate = cty_state,
		@lgh_startcty_nmstct = cty_nmstct
	from city
	where cty_code = @startcity

	select 	@lgh_endregion1 = cty_region1, 
		@lgh_endregion2 = cty_region2, 
		@lgh_endregion3 = cty_region3, 
		@lgh_endregion4 = cty_region4, 
		@lgh_endstate = cty_state,
		@lgh_endcty_nmstct = cty_nmstct	
	from city
	where cty_code = @endcity

	/* Now lets get the driver information */
	select 	@mpp_teamleader = mpp_teamleader,
		@mpp_fleet = mpp_fleet,
		@mpp_division = mpp_division,
		@mpp_domicile = mpp_domicile,
		@mpp_company = mpp_company,
		@mpp_terminal = mpp_terminal,
		@mpp_type1 = mpp_type1,
		@mpp_type2 = mpp_type2,
		@mpp_type3 = mpp_type3,
		@mpp_type4 = mpp_type4
	from manpowerprofile
	where mpp_id = isnull(@driver1,'UNKNOWN')

	/* Now lets get tractor information */
	select	@trc_company = trc_company,
		@trc_division = trc_division,
		@trc_fleet = trc_fleet,
		@trc_terminal = trc_terminal,
		@trc_type1 = trc_type1,
		@trc_type2 = trc_type2,
		@trc_type3 = trc_type3,
		@trc_type4 = trc_type4
	from tractorprofile
	where trc_number = @lghtractor

	/* Now lets get trailer information*/
	select 	@trl_company = trl_company,
		@trl_fleet = trl_fleet,
		@trl_division = trl_division,
		@trl_terminal = trl_terminal,
		@trl_type1 = trl_type1,
		@trl_type2 = trl_type2,
		@trl_type3 = trl_type3,
		@trl_type4 = trl_type4
	from trailerprofile
	where trl_id = isnull(@trailer,'UNKNOWN')


		UPDATE 	legheader 
		SET 	
			lgh_startregion1 = @lgh_startregion1,
			lgh_startregion2 = @lgh_startregion2,
			lgh_startregion3 = @lgh_startregion3,
			lgh_startregion4 = @lgh_startregion4,
			lgh_startstate = @lgh_startstate,		
			lgh_startcty_nmstct = @lgh_startcty_nmstct,
			lgh_endregion1 = @lgh_endregion1,
			lgh_endregion2 = @lgh_endregion2,
			lgh_endregion3 = @lgh_endregion3,
			lgh_endregion4 = @lgh_endregion4,
			lgh_endstate = @lgh_endstate,	
			lgh_endcty_nmstct = @lgh_endcty_nmstct,
			lgh_driver1 = isnull(@driver1,'UNKNOWN'),	
			lgh_driver2 = isnull(@driver2,'UNKNOWN'),
			mpp_teamleader = @mpp_teamleader,
			mpp_fleet = @mpp_fleet,
			mpp_division = @mpp_division,
			mpp_domicile = @mpp_domicile,
			mpp_company = @mpp_company,
			mpp_terminal = @mpp_terminal,
			mpp_type1 = @mpp_type1,
			mpp_type2 = @mpp_type2,
			mpp_type3 = @mpp_type3,
			mpp_type4 = @mpp_type4,
			trc_company = @trc_company,
			trc_division = @trc_division,
			trc_fleet = @trc_fleet,
			trc_terminal = @trc_terminal,
			trc_type1 = @trc_type1,
			trc_type2 = @trc_type2,
			trc_type3 = @trc_type3,
			trc_type4 = @trc_type4,
			trl_company = @trl_company,
			trl_fleet = @trl_fleet,
			trl_division = @trl_division,
			trl_terminal = @trl_terminal,
			trl_type1 = @trl_type1,
			trl_type2 = @trl_type2,
			trl_type3 = @trl_type3,
			trl_type4 = @trl_type4,
			lgh_carrier = isnull(@carrier,'UNKNOWN'), 
			lgh_active = @lgh_active
						
		WHERE 	lgh_number = @minlgh
end

GO
GRANT EXECUTE ON  [dbo].[fix_lgh_400_convert] TO [public]
GO
