SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_timeline_scroll_conf_det_sp] 
@name varchar(32),
@Expires datetime,
@Effective datetime,
@supplier varchar(8),
@Pickup datetime,
@plant varchar(8),
@plant_arrival datetime,
@routes_in varchar(128),
@branch varchar(12),
@dock varchar(8),
@stopsat varchar(8)
AS

/**
 * 
 * NAME:
 * dbo.d_timeline_scroll_conf_det_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieval proc for the scroll timeline data window
 *
 * RETURNS:
 *  Matching Timelines
 * RESULT SETS: 
 *  Matching Timelines
 *
 * PARAMETERS:
 *	@name varchar(32),	Optional - NULL, '', Name of the timeline to retrive
 *	@Expires datetime,	Required
 * 	@Effective datetime,	Required
 * 	@supplier varchar(8),	Optional - NULL, ''
 * 	@Pickup datetime,	Optional - NULL, ''
 * 	@plant varchar(8),	Optional - NULL, ''
 * 	@plant_arrival datetime,Optional - NULL, ''
 * 	@routes_in varchar(128),Optional - NULL, ''
 * 	@branch varchar(12),	Optional - NULL, ''
 * 	@dock varchar(8),	Optional - NULL, ''
 *	@stopsat varchar(8)	Optional - NULL, ''
 * 
 * REVISION HISTORY:
 * 06/19/2006.01 - MRH ? Created
 **/


declare @PickupTime datetime
declare @Arrival datetime
declare @Routes_out varchar(128)
declare @newroute varchar(15)
declare @mintimelinedet int
declare @tlh_number int

select @routes_out = '' select @PickupTime = '1/1/2001 00:01' select @Arrival = '1/1/2001 00:01'

-- 30999
IF @plant = 'UNKNOWN' SET @plant = NULL
IF @stopsat = 'UNKNOWN' SET @stopsat = NULL
IF @supplier = 'UNKNOWN' SET @supplier = NULL

-- Put all of the matching headers in a temp table
select tlh_number, tlh_name, tlh_effective, 
	tlh_expires, tlh_supplier, tlh_plant, 
	tlh_dock, tlh_jittime, tlh_leaddays, 
	tlh_leadbasis, tlh_sequence, tlh_direction, 
	tlh_sunday, tlh_saturday, tlh_branch, 
	tlh_timezone, tlh_SubrouteDomicle, tlh_DOW, 
	tlh_specialist, tlh_updatedby, tlh_updatedon, 
	(select min(tld_route) 
		from timeline_detail 
		where timeline_detail.tlh_number = timeline_header.tlh_number) route,
--	@Routes_out routes, 
	@PickupTime PickupTime, @Arrival Arrival
into #Temp
from timeline_header 
where 	@Effective <= tlh_effective and
	@Expires >= tlh_expires and
	(@name = '' OR CHARINDEX(tlh_name, @name) > 0 OR @name IS NULL) AND 
	(@supplier = '' OR CHARINDEX(tlh_supplier, @supplier) > 0 OR @supplier IS NULL) AND 
	(@plant = '' OR CHARINDEX(tlh_plant, @plant) > 0 OR @plant IS NULL) AND
--	(@branch = '' OR CHARINDEX(tlh_branch, @branch) > 0 OR @branch IS NULL) AND
	@branch in (tlh_branch, 'UNK') and
	(@dock = '' or charindex(tlh_dock, @dock) > 0 or @dock IS NULL) AND
	(@routes_in = '' or (select count(0) from timeline_detail where tld_route = @routes_in and timeline_detail.tlh_number = timeline_header.tlh_number) > 0 or @routes_in IS NULL)
	AND ((@stopsat = '' OR (select count(0) from timeline_detail where tld_origin = @stopsat and timeline_detail.tlh_number = timeline_header.tlh_number) > 0 OR @stopsat IS NULL)
	OR (@stopsat = '' OR (select count(0) from timeline_detail where tld_dest = @stopsat and timeline_detail.tlh_number = timeline_header.tlh_number) > 0 OR @stopsat IS NULL))

--	OR tlh_number in (select tlh_number from timeline_detail where tld_route in (@routes_in))

-- Update the routes field for each timeline
select @tlh_number = (select min(tlh_number) from #temp)
while @tlh_number is not null
begin
	-- Get the route string for each timeline detail.
	select @mintimelinedet = (select min(tld_number) from timeline_detail where tlh_number = @tlh_number)
-- 	while @mintimelinedet is not null
-- 	begin
-- 		select @newroute = isnull(tld_route, '') from timeline_detail where tld_number = @mintimelinedet
-- 		if (len(@Routes_out) + len(@newroute)) <= 128
-- 			if isnull(@Routes_out, '') = ''
-- 				select @Routes_out = @newroute
-- 			else
-- 				select @Routes_out = @Routes_out + ',' + @newroute
-- 		select @mintimelinedet = (select min(tld_number) from timeline_detail where tlh_number = @tlh_number and tld_number > @mintimelinedet)
-- 	end

	-- Get the pickup and arrival time for each route
	select @PickupTime = tld_arrive_orig from timeline_detail where tlh_number = @tlh_number and tld_sequence = (select min(tld_sequence) from timeline_detail where tlh_number = @tlh_number)
	select @Arrival = tld_arrive_dest from timeline_detail where tlh_number = @tlh_number and tld_sequence = (select max(tld_sequence) from timeline_detail where tlh_number = @tlh_number)

	-- Update the #temp table
--	update #temp set routes = @Routes_out, PickupTime = @PickupTime, Arrival = @Arrival where tlh_number = @tlh_number
-- 30999
--	update #temp set PickupTime = @PickupTime, Arrival = @Arrival where tlh_number = @tlh_number
	update #temp 
	set  PickupTime = CAST('1900-01-01' + ' ' + substring(convert(char, @PickupTime, 108), 1, 8) AS DATETIME)
		, Arrival = CAST('1900-01-01' + ' ' + substring(convert(char, @Arrival, 108), 1, 8) AS DATETIME)
	where tlh_number = @tlh_number

	-- Move to next timeline header
	select @tlh_number = (select min(tlh_number) from #temp where tlh_number > @tlh_number)

end -- tlh_loop

-- Return the results
select * from #temp
-- 30999
WHERE (pickuptime = @pickup OR @pickup = '1900-01-01 00:00' OR @pickup IS NULL)
AND (arrival = @plant_arrival OR @plant_arrival = '1900-01-01 00:00' OR @plant_arrival IS NULL)

drop table #temp
GO
GRANT EXECUTE ON  [dbo].[d_timeline_scroll_conf_det_sp] TO [public]
GO
