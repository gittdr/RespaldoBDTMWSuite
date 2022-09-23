SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[experfuel_historical_extract_sp](@stardate datetime, @endate datetime)
as

/*
	PTS 47414 - DJM - Historical expertfuel extract
*/

Declare	@trip_min	int,
	@currleg		int,
	@cty_name		varchar(20),
	@cty_zip		varchar(10),
	@cty_nmstct		varchar(20),
	@cty_state		varchar(6),
	@stp_city		int,
	@stp_zip		 varchar(10),
	@stp_state		varchar(6),
	@min_seq		int,
	@citylist		varchar(3000),
	@cmp_citylist	varchar(3000),
	@cmpid			varchar(20),
	@cmpzip			varchar(8)

Declare @triplist TABLE(
	sequence		int		identity,
	lgh_number		int		not null,
	tractor			varchar(12)	null,
	start_date		datetime	null,
	tank_capacity	int			null,
	mpg				decimal(6,2) null,
	stplist			varchar(2000) null
	)

Declare @routepoint TABLE(
	stp_seq			int		identity,
	stp_number		int		not null,
	lgh_number		int		not null,
	stp_sequence	int		not null,
	cmp_id			varchar(20)	null,
	city_code		int		null,
	stp_zip			varchar(10)	null,
	stp_state		varchar(6)	null)


insert into @triplist (lgh_number, tractor, start_date)
select lgh_number,
	lgh_tractor,
	lgh_startdate
from legheader
where lgh_startdate between @stardate and @endate
	and lgh_tractor is not null
	and lgh_outstatus ='CMP'
order by lgh_startdate


Update @triplist
set tank_capacity = isNull(trc_tank_capacity,200),
	mpg = isNull(trc_mpg,4.0)
from @triplist trip, tractorprofile 
where tractorprofile.trc_number = trip.tractor


select @trip_min = isNull(min(sequence),0) from @triplist
while @trip_min > 0
	Begin	

		select @currleg = lgh_number from @triplist where sequence = @trip_min

		Insert into @routepoint (stp_number, lgh_number, stp_sequence, cmp_id, city_code, stp_zip, stp_state)
		select stp_number,
			stops.lgh_number,
			stp_mfh_sequence,
			cmp_id,
			stp_city,
			stp_zipcode,
			stp_state
		from stops, @triplist trips
		where stops.lgh_number = trips.lgh_number
			and trips.sequence = @trip_min
		Order By stp_mfh_sequence


		/* Loop through all the stops and create the string		*/
		select @min_seq = min(stp_seq) from @routepoint where lgh_number = @currleg
		select @citylist = ''

		while @min_seq > 0
			Begin

				select @stp_city = city_code,
					@stp_zip = stp_zip,
					@stp_state = stp_state,
					@cmpid = cmp_id
				from @routepoint r --inner join (select cty_code, cty_name, cty_state, cty_nmstct, cty_zip from city) cty
					--on cty.cty_code = r.city_code
				where r.stp_seq = @min_seq


				select @cty_name = cty_name,
					@cty_state = cty_state, 
					@cty_nmstct = cty_nmstct,
					@cty_zip = cty_zip,
					@cmpzip= '       '
				from city
				where cty_code = @stp_city

				-- Default the ZIP to 000000 if one cannot be found on the stop/city/company
				if @cmpid <> ''
					Begin
						select @cmpzip = isNull(cmp_zip,'000000') from company where cmp_id = @cmpid
						--Print 'Company ' +  @cmpid + '  Zip: ' + @cmpzip
					end
				else
					select @cmpzip = '000000'

				if @stp_zip = '' 
					select @stp_zip = null

				if @cty_zip = ''
					select @cty_zip = null

				--Create the city list format.
				--Print 'Zip: ' + 'z' + Right(space(6) + ltrim(isNull(@stp_zip,isNull(@cty_zip,@cmpzip))),6) + 'z'

				select @citylist = isNull(@citylist,'') + Right(space(6) + ltrim(isNull(@stp_zip,isNull(@cty_zip,@cmpzip))),6)
				select @citylist = @citylist + left(ltrim(rtrim(isNull(@stp_state, @cty_state))) + space(2),2)

				select @min_seq = min(stp_seq) 
				from @routepoint
				where stp_seq > @min_seq
					and lgh_number = @currleg

			end

		Update @triplist
		set stplist = @citylist
		where lgh_number = @currleg


		-- Get the next sequence
		select @trip_min = isNull(min(sequence),0) from @triplist where sequence > @trip_min
	End


--select * from @triplist

-- Format the result as necessary.
Select Right('0'+ datename(yyyy,start_date),4) +						-- 1-4
	Right('0'+ Cast(Datepart(mm,start_date) as varchar(2)),2)+			-- 5-6
	Right('0' + Cast(Datepart(dd,start_date) as varchar(2)),2)+			-- 7-8	
	Right('0' + Cast(Datepart(hh,start_date) as varchar(2)),2)+			-- 9-10
	Right('0' + Cast(Datepart(mi,start_date) as varchar(2)),2) +		-- 11-12
	Left( LTrim(isNull(tractor,'')) + Space(10), 10) +					-- 13 - 22  Power ID
	Right( Space(4) + RTrim(str(isNull(tank_capacity,0),4,0)) ,4) +		-- 23 - 26 Tractor Fuel capacity
	Space(4) +															-- 27 - 30 Current fuel level
	Right( Space(6) + RTrim(str(isNUll(mpg,0),6,3)) ,6) +				-- 31 - 36 MPG
	Replicate(' ',13)+													-- 37 - Haz-Mat, Clien Type, HM Type, Route Type, Truck Type, Opt/Can, Ret Route. fields not supported in this extract.
	stplist																-- 49 - ??  List of Stop Zip/St codes.

from @triplist


GO
GRANT EXECUTE ON  [dbo].[experfuel_historical_extract_sp] TO [public]
GO
