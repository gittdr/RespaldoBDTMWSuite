SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Procedure [dbo].[create_fueloptrequest_sp] (@trip_list varchar(256))
AS

/*******************************************************************************************************************  
	Object Description:

	Given a list of trips, adds a geofuelrequest entry when needed.

	Revision History:

	Date        Name            Label/PTS   Description
	-----------	---------------	----------  ----------------------------------------
	02/07/2007	DJM				PTS 36150	Add Driver Manager and Driver2 to the request record.
	09/26/2007	DJM				PTS 39607	Modify to accept multiple Trip Segments
	08/13/2008	DJM				PTS 44109	Modify to include the trc_networks value in the solution request.
	09/05/2008	DJM				PTS 44339	When the requests already exist, do NOT update the status of the record is it's already complete.
	09/12/2008	DJM				PTS 44460	Add a setting to allow the proc to strip out spaces in the Zip column so that 7 character Zips with a space will fit in the 6 character column.	
	11/17/2008	DJM				PTS 44336	Modify to verify the legheader still exists in case the Trip was cancelled.
	04/29/2009	DJM				PTS 47305	Modify the process building route points to look at the Stop status.  If new settings is on, only include last completed
											stop on the trip and subsequent open stops - or all stops if none are complete.
	08/12/2010	DJM				PTS 53577	Modify to allow for multiple rows in the geofuelrequest table for the same lgh_number
	04/24/2012	DJM				PTS 62688	Fixed cases where the 'EFIncludeOpenStopsOnly' GI setting was not working correctly.
	02/27/2013	MIZ				PTS 67738	Add defaults to act the same as the UI (mpg & tank capacity)
	09/21/2012	DJM				PTS 62503	Added tractor DEF level to the request
	03/05/2014	MDH				PTS 75904	Added support for route sync options
	03/04/2016	JJF				PTS 89961	Send only one occurence of stops at the same location, add waypoint
********************************************************************************************************************/

SET NOCOUNT ON

Declare @tractor	varchar(12),
	@tank_gal		int,
	@tank_capacity	int,
	@trip_status	varchar(6),
	@mpg			float,
	@req_status		char(4),
	@citylist		varchar(3000),
	@ProcessFuelReqOnStart	char(1),
	@mov_number		int,
	@route_network	char(1),	
	@min_purchase	int,	
	@driver			varchar(12),
	@use_hazmat		char(1),
	@opt_solution	char(1),
	@cmp_citylist		varchar(3000),
	@min_seq		int,
	@cty_name		varchar(20),
	@cty_zip		varchar(10),
	@cty_nmstct		varchar(20),
	@cty_state		varchar(6),
	@stp_city		int,
	@stp_zip		 varchar(10),
	@stp_state		varchar(6),
	@stdate			datetime,
	@mov			int,
	@cmpid			varchar(8),
	@return_route	char(1),
	@generate_route	char(1),
	@min_tank		int,
	@display		char(1),
	@driver2		varchar(12),
	@drv_mgr		varchar(10),
	@current_trip	int,
	@trip_seg		int,
	@network		varchar(5),
	@maxstop	integer,
	@deflevel		integer,				-- PTS 62503 - DJM
	@rs_enabled char(1),
	@rs_managed char(1),
	@rs_generate char(1),
	@rs_oor_distance decimal (4,1), 
	@rs_compliance integer

DECLARE @last_stp_city int 
DECLARE	@last_cmpid varchar(8) 
DECLARE @isWaypoint char(1)
DECLARE @wayPoint_latitude char(11)
DECLARE @wayPoint_longitude char(11)

Declare @routepoint TABLE(
	stp_seq			int		identity,
	stp_number		int		not null,
	lgh_number		int		not null,
	stp_sequence	int		not null,
	cmp_id			varchar(10)	null,
	city_code		int		null,
	stp_zip			varchar(10)	null,
	stp_state		varchar(6)	null,
	isWayPoint		char(1),
	wayPoint_latitude char(11) null,
	wayPoint_longitude char(11) null
)

--PTS 39607 - DJM
DECLARE @trips table(
    value	int,
	seq		int identity)

-- Initialization
SET @tank_capacity = 0
SET @mpg = 0

-- PTS 39607 - DJM - Parse the string into a temp table
INSERT INTO @trips 
SELECT convert(int, value) FROM CSVStringsToTable_fn(@trip_list)

select @trip_seg = value from @trips where seq = 1
if @trip_seg > 0 
	delete from @trips where value = @trip_seg
else
	Return

-- PTS 44336
if not exists (select 1 from legheader where lgh_number = @trip_seg)
	Return


/* PTS 39607 - Limit the number of future trips to include in the solution	*/
Declare	@limit int
select @limit = isNull(gi_integer1,1) from generalinfo where gi_name = 'ExpertFuelAdvanceTripLimit'
if @limit < (select count(*) from @trips)
	Begin
		delete from @trips where seq > (@limit)
	End

/* Check the Trip Status							*/
select @trip_status = lgh_outstatus,
	@tractor = isNull(lgh_tractor,'XXXXXX'),
	@driver = isnull(lgh_driver1,'UNKNOWN'),
	@driver2 = isnull(lgh_driver2,'UNKNOWN')	-- PTS 36150 - DJM
from legheader where lgh_number = @trip_seg

if @trip_status in ('PLN','DSP','AVL')
	Begin
		Select @ProcessFuelReqOnStart = Left(isnull(gi_string1,'N'),1) from generalinfo where gi_name = 'ProcessFuelReqOnStart'
		if @ProcessFuelReqOnStart = 'Y'
			select @req_status = 'HOLD'		
		else
			select @req_status = 'RUN'		
	end
else
	select @req_status = 'RUN'		


/* Get Generalinfo Default values										*/
select @route_network = isNull(gi_string1,'S') from generalinfo where gi_name = 'fa_route_network'
select @min_purchase = isNull(gi_integer1,0) from generalinfo where gi_name = 'fa_min_purchase'
select @opt_solution = isNull(gi_string1,'O') from generalinfo where gi_name = 'fa_optimal_solution'
select @return_route = isNull(gi_string1,'Y') from generalinfo where gi_name = 'fa_return_route'
select @generate_route = isNull(gi_string1,'Y') from generalinfo where gi_name = 'fa_generate_route'
select @display = isNull(gi_string1,'N') from generalinfo where gi_name = 'fa_batch_process'
select @min_tank = isNull(gi_integer1,0) from generalinfo where gi_name = 'fa_min_tank'

select @rs_enabled = ISNull(LEFT (gi_string1, 1), 'N') from generalinfo where gi_name = 'fa_routesyncenabled'

/* Get the Tractor Information				*/
select @tank_gal = isNull(trc_gal_in_tank,0),
	@tank_capacity = isNull(trc_tank_capacity,0),
	@mpg = isNull(trc_mpg,0),
	@deflevel = ISNULL(trc_DEFLevel,0)
from tractorprofile
where trc_number = @tractor

Exec dbo.ef_get_routesync_options @lgh_number = @trip_seg, @trc_number = @tractor, 
	@managed = @rs_managed OUTPUT, @generate = @rs_generate OUTPUT, 
	@oor_distance = @rs_oor_distance OUTPUT, @compliance = @rs_compliance OUTPUT
-- Set default values if mpg/tank_capacity were not populated.
IF (@tank_capacity = 0)
	SELECT @tank_capacity = ISNULL(CONVERT(int, gi_string1), 0)
	FROM generalinfo 
	WHERE gi_name = 'fa_Tank_Capacity'

IF (@mpg = 0)
	SELECT @mpg = ISNULL(CONVERT(float, gi_string1), 0)
	FROM generalinfo 
	WHERE gi_name = 'fa_mpg'

/* Get Trip information						*/
select @stdate = lgh_startdate,
	@mov = mov_number
from legheader
where lgh_number = @trip_seg

/* Build the string containing the list of Cities for all the stops on the legheader	*/
-- PTS 47305 - DJM - Check GI setting 
-- PTS 62688 - DJM - Removed check for an Open trio on the Leg. It did not work when the first trip was completed.
if exists (select 1 from generalinfo where gi_name = 'EFIncludeOpenStopsOnly' and gi_string1 = 'Y')
	Begin
		select @maxstop = isNull(max(stp_mfh_sequence),0) from stops where lgh_number = @trip_seg and stp_status = 'DNE'

		--PTS89961 JJF 20160328 - Designate this stop as a 'waypoint', since it's already completed.
		INSERT	@routepoint (stp_number, lgh_number, stp_sequence, cmp_id, city_code, stp_zip, isWayPoint)
		SELECT	stp_number,
				lgh_number,
				stp_mfh_sequence,
				cmp_id,
				stp_city,
				stp_zipcode,
				'Y'
		FROM	stops
		WHERE	lgh_number = @trip_seg
				and stp_mfh_sequence = @maxstop

		--PTS89961 JJF 20160328 - Designate this stop as a 'waypoint', since it's already completed.
		IF (@maxstop > 0) BEGIN
			--Set inserted routepoint with most recent check call for tractor
			UPDATE	@routepoint
			SET		wayPoint_latitude = RIGHT(SPACE(11) + CONVERT(varchar(11), CONVERT(DECIMAL(9, 6), ckc_latseconds / 3600.000000)), 11),
					wayPoint_longitude = RIGHT(SPACE(11) + CONVERT(varchar(11), CONVERT(DECIMAL(9, 6), ckc_longseconds / 3600.000000)), 11)
			FROM	checkcall
			WHERE	ckc_number =	(	SELECT TOP 1 ckc_number
										FROM	checkcall ckc,
												stops stp
										WHERE	ckc.ckc_tractor = @tractor
												AND stp.lgh_number = @trip_seg
												AND stp.stp_mfh_sequence = @maxstop
												AND ckc.ckc_date > stp.stp_arrivaldate
										ORDER BY ckc.ckc_date DESC
									)
		END 	


		Insert into @routepoint (stp_number, lgh_number, stp_sequence, cmp_id, city_code, stp_zip, isWayPoint)
		select stp_number,
			lgh_number,
			stp_mfh_sequence,
			cmp_id,
			stp_city,
			stp_zipcode,
			'N'
		from stops
		where lgh_number = @trip_seg
			and stp_mfh_sequence > @maxstop
			and stp_status = 'OPN'
		Order By stp_mfh_sequence
	

	End
else
	-- Standard functionality.
	Insert into @routepoint (stp_number, lgh_number, stp_sequence, cmp_id, city_code, stp_zip, isWayPoint)
	select stp_number,
		lgh_number,
		stp_mfh_sequence,
		cmp_id,
		stp_city,
		stp_zipcode,
		'N'
	from stops
	where lgh_number = @trip_seg
	Order By stp_mfh_sequence



/*
	PTS 39607 - DJM - Add location information for any other trip segments provided
*/
if exists (select 1 from @trips)
	Begin
		select @current_trip = (select top 1 isNull(value,0) from @trips Order By seq)
		While  @current_trip > 0
			Begin
				Insert into @routepoint (stp_number, lgh_number, stp_sequence, cmp_id, city_code, stp_zip, isWayPoint)
				select stp_number,
					lgh_number,
					stp_mfh_sequence,
					cmp_id,
					stp_city,
					stp_zipcode,
					'N'
				from stops 
				where stops.lgh_number = @current_trip
				Order By stp_mfh_sequence

				Delete from @trips where value = @current_trip

				select @current_trip = (select top 1 isNull(value,0) from @trips Order by seq) 
			End	
	End

/* 
*	PTS 44460 - DJM - IF the setting requires, strip out any spaces in the Zip field
*/
if exists (select 1 from generalinfo where gi_name = 'EFRequestCompressZip' and gi_string1 = 'Y')
	Update @routepoint
	set stp_zip = Replace(stp_zip,' ','')

SET @last_cmpid = ''
SET @last_stp_city = 0

/* Loop through all the stops and create the string		*/
select @min_seq = min(stp_seq) from @routepoint

while @min_seq > 0
	Begin
		select @stp_city = city_code,
			@stp_zip = stp_zip,
			@stp_state = stp_state,
			@cmpid = cmp_id,
			@isWaypoint = isWayPoint,
			@wayPoint_latitude = wayPoint_latitude,
			@wayPoint_longitude = wayPoint_longitude
		from @routepoint r inner join (select cty_code, cty_name, cty_state, cty_nmstct, cty_zip from city) cty
			on cty.cty_code = r.city_code
		where r.stp_seq = @min_seq

		select @cty_name = cty_name,
			@cty_state =cty_state, 
			@cty_nmstct = cty_nmstct,
			@cty_zip = cty_zip
		from city
		where cty_code = @stp_city

		IF isnull(@stp_city, 0) <> @last_stp_city AND isnull(@cmpid, '') <> @last_cmpid BEGIN --PTS89961 send only one occurence of stops at the same location
			/* Create the original city list format			*/
			select @citylist = isNull(@citylist,'') + left(ltrim(isNull(@stp_zip,isnull(@cty_zip, ' '))) + space(6),6) --PTS89961 additional null check in case cty_zip is null
			select @citylist = @citylist + left(ltrim(rtrim(IsNull(@cty_name,' '))) + space(14),14)
			select @citylist = @citylist + left(ltrim(rtrim(isNull(@stp_state, @cty_state))) + space(2),2)

			/* Create the newer CityCMP format				*/
			select @cmp_citylist = isNull(@cmp_citylist,'') + left(ltrim(isNull(@stp_zip,isnull(@cty_zip, ' '))) + space(6),6)  --PTS89961 additional null check in case cty_zip is null
			select @cmp_citylist = @cmp_citylist + left(ltrim(rtrim(IsNull(@cty_name,' '))) + space(14),14)
			select @cmp_citylist = @cmp_citylist + left(ltrim(rtrim(isNull(@stp_state, @cty_state))) + space(2),2)
			select @cmp_citylist = @cmp_citylist + left(ltrim(rtrim(isNull(@cmpid, 'UNKNOWN'))) + space(9),9)
			select @cmp_citylist = @cmp_citylist + left(ltrim(rtrim(isNull(@cty_nmstct, 'UNKNOWN'))) + space(31),31)
			select @cmp_citylist = @cmp_citylist + left(ltrim(rtrim(isNull(cast(@stp_city as varchar(8)), '0'))) + space(8),8)
			--PTS89961 JJF 20160328 add waypoint
			select @cmp_citylist = @cmp_citylist + @isWaypoint
			select @cmp_citylist = @cmp_citylist + isnull(@wayPoint_latitude, space(11)) 
			select @cmp_citylist = @cmp_citylist + isnull(@wayPoint_longitude, space(11)) 
		END

		SET @last_stp_city = isnull(@stp_city, 0)
		SET @last_cmpid = isnull(@cmpid, '')

		select @min_seq = min(stp_seq) 
		from @routepoint
		where stp_seq > @min_seq

	end

/* PTS 36150 - DJM - Find the Driver Manager											*/
if isNull(@driver,'UNKNOWN') <> 'UNKNOWN'
	select @drv_mgr = mpp_teamleader from manpowerprofile where mpp_id = @driver
else
	select @drv_mgr = 'UNKNOWN'

/* PTS 44109 - DJM - Get the Tractor Network value		*/
select @network = isNull(trc_networks,'') from tractorprofile where trc_number = @tractor

/*
	PTS 47305 - DJM - Allow the user to create another solution for the Trip even if one already exists. 
		Need to delete the previous request ONLY IF the previous request is complete.
*/ 
if exists (select 1 from generalinfo where gi_name = 'EFIncludeOpenStopsOnly' and gi_string1 = 'Y')
	Delete from geofuelrequest where gf_lgh_number = @trip_seg AND gf_status in ('CMP','HOLD','NON')



/* Check for an existing solution.  Update appropriate fields if it does.				*/
/* 
	PTS 53577 - DJM - Since the App can now handle multiple records for the same trip segment, only
	update records that are not complete.  We can assume those solutions have NOT been setn to the Fuel server.
*/
if exists (select 1 from geofuelrequest where gf_lgh_number = @trip_seg and gf_status in ('RUN','HOLD')) 
	Begin
		/* PTS 35574 - DJM - Add option to prevent updating the gf_cities fields in case users
			have entered custom Route Points.
		*/
		Declare @GeoOverWriteTripRoute	char(1)

		select @GeoOverWriteTripRoute = IsNull((select isNull(gi_string1,'Y') from Generalinfo where gi_name = 'GeoOverWriteTripRoute'),'Y')

		-- PTS 44339 - DJM - Add a check to the status of the request so that previously CMP request are not reprocessed.

		Begin
			if @GeoOverWriteTripRoute = 'Y'
				Update geofuelrequest
				set gf_tractor = @tractor,
					gf_tank_gals = @tank_gal,
					gf_status = @req_status,
					gf_cities = @citylist,
					gf_city_cmp = @cmp_citylist,
					gf_networks = @network, 
					gf_rs_generate_message = @rs_generate,  
					gf_rs_managed = @rs_managed, 
					gf_rs_oor = @rs_oor_distance, 
					gf_rs_compliance = @rs_compliance
				where gf_lgh_number = @trip_seg
					and gf_process_override = 0	
					and gf_status not in ('CMP','NON')
			else
				Update geofuelrequest
				set gf_tractor = @tractor,
					gf_tank_gals = @tank_gal,
					gf_status = @req_status,
					gf_networks = @network
				where gf_lgh_number = @trip_seg
					and gf_process_override = 0	
					and gf_status not in ('CMP','NON')
		end
	End

else

	/* Create the Fuel Optimization Request record			*/
	INSERT INTO geofuelrequest (gf_lgh_number, 
		gf_mov_number, 
		gf_trans_id,	
		gf_req_type, 
		gf_tractor, 
		gf_tank_gals, 
		gf_mpg, 
		gf_min_purchase,
		gf_tank_cap, 
		gf_tank_min, 
		gf_strategy, 
		gf_facilities, 
		gf_networks, 
		gf_network_action, 
		gf_cities, 
		gf_status, 
		hazmat_route, 
		hazmat_class,
		route_network, 
		generate_route, 
		return_optimum, 
		return_route_solution , 
		display, 
		driver1,   
		driver2, 
		driver_mgr,		
		gf_city_cmp,
		gf_start_date,
		gf_tank_gal_override,
		gf_request_source,
		gf_process_override,
		ef_sendsolution,		-- PTS 59659 - DJM
		gf_deflevel, 				-- PTS 62503 - DJM
		gf_rs_generate_message, 
		gf_rs_managed,
		gf_rs_oor,
		gf_rs_compliance)
	VALUES (@trip_seg, 
		@mov, 
		'None', 
		'NEWRT', 
		@tractor, 
		@tank_gal, 
		@mpg, 
		isNull(@min_purchase,0), 
		@tank_capacity,	
		isNull(@min_tank,0),	--min_tank
		'', -- ls_strategy
		'', --:ls_facilities, 
		@network, -- PTS 44109 - DJM, 
		'', --:ls_net_action, 
		@citylist, 
		isNull(@req_status,'RUN'), --:ls_status, 
		'N', --:ls_use_hazmat, 
		'', --:ls_hazmat_class,
		@route_network,
		isNull(@generate_route,'Y'), --:ls_genroute, 
		isNull(@opt_solution,'O'), --:ls_optroute, 
		isNull(@return_route,'Y'), --:ls_returnroute, 
		isNull(@display,'N'), --:ls_display, 
		@driver, 
		@driver2, --:ls_drv2, 
		@drv_mgr, --:ls_drvmgr, 
		@cmp_citylist,
		@stdate,
		0,
		'create_fueloptrequest_sp',
		0,
		'Y',
		@deflevel, 
		@rs_generate, @rs_managed, @rs_oor_distance, @rs_compliance)

GO
GRANT EXECUTE ON  [dbo].[create_fueloptrequest_sp] TO [public]
GO
