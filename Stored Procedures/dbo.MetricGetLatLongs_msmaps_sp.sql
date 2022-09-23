SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetLatLongs_msmaps_sp] 
			(	
				@truck varchar(15),
				@ordnumb varchar(20)

			)
AS

set nocount on 

create table #latlongs
	(	_id int identity
		, gps_latitude float
		, gps_longitude float
		, centerlat float
		, centerlong float
	)

	if @ordnumb = '24hrs' 
	begin
			insert into #latlongs (gps_latitude, gps_longitude)
			select 	(ckc_latseconds / 3600.0) AS gps_latitude, -1*(ckc_longseconds / 3600.0) AS gps_longitude
			  from	checkcall 
			 where	ckc_tractor = @truck
					and ckc_date between dateadd(hh,-24,getdate()) and getdate()
					and ckc_latseconds is not null
			order by ckc_date
	end
	if @ordnumb = '3Days' 
	begin
			insert into #latlongs (gps_latitude, gps_longitude)
			select 	(ckc_latseconds / 3600.0) AS gps_latitude, -1*(ckc_longseconds / 3600.0) AS gps_longitude
			  from	checkcall 
			 where	ckc_tractor = @truck
					and ckc_date between dateadd(dd,-3,getdate()) and getdate()
					and ckc_latseconds is not null
			order by ckc_date
	end
	if @ordnumb = '7Days' 
	begin
			insert into #latlongs (gps_latitude, gps_longitude)
			select 	(ckc_latseconds / 3600.0) AS gps_latitude, -1*(ckc_longseconds / 3600.0) AS gps_longitude
			  from	checkcall 
			 where	ckc_tractor = @truck
					and ckc_date between dateadd(dd,-7,getdate()) and getdate()
					and ckc_latseconds is not null
			order by ckc_date	
	end
	if isNumeric(@ordnumb) = 1
	begin
			insert into #latlongs (gps_latitude, gps_longitude)
			select 	(ckc_latseconds / 3600.0) AS gps_latitude, -1*(ckc_longseconds / 3600.0) AS gps_longitude
			  from	checkcall 
			 where	ckc_tractor = @truck
					and ckc_lghnumber in (select lgh_number from legheader where lgh_tractor = @truck and ord_hdrnumber = @ordnumb)
					and ckc_latseconds is not null
			order by ckc_date
	end

	declare @cenlat float
	declare @cenlong float

	select	@cenlat = (min(gps_latitude) + max(gps_latitude)) / 2 from #latlongs
	select	@cenlong = (min(gps_longitude) + max(gps_longitude)) / 2 from #latlongs

	update	#latlongs
	   set	centerlat = @cenlat
			,centerlong = @cenlong


	select 	gps_latitude,gps_longitude, centerlat, centerlong
	  from 	#latlongs
	order by _id

	drop table #latlongs

set nocount off 
		
GO
GRANT EXECUTE ON  [dbo].[MetricGetLatLongs_msmaps_sp] TO [public]
GO
