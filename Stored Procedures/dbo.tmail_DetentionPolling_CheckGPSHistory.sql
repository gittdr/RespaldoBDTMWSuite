SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_DetentionPolling_CheckGPSHistory]
		(@stp_number int, 
		@cmp_id varchar(10), 
		@ShowDetail int -- set to 1 if you want to get a diagnostic report

		)

/**************************************************************************
* 01/27/04 DM: Created
*  This Stored proc is called from tmail_DetentionPolling to determine if 
*  a GPS sighting indicates truck has already left the stop
*  If not, it will optionally ping the truck to get a new GPS
*  This proc returns an INT 
*  	-1 = No Lat/long for stop, 
*	-2=No checkcalls, 
*	-3= Found arrival checkcall, but no confirmed depart. Doing a PING
*	>0 = Found GPS N airmiles past stop
***************************************************************************/

AS

-- Stores check calls for this legheader
Create table #CheckCallsThisLegheader
	(ckc_number int,
	Ckc_date Datetime,
	AirMilesToStop float
	)

Declare @return_number_checkGPS int -- This is returned

Declare @Lgh_number int

Declare @AirMiles float
Declare @lat1 Float,
	@lat2 float,
	@long1 float,
	@long2 Float
Declare @ClosestCheckCallToStop int
Declare @MinCkcDate dateTime
Declare @ArrivedRadiusMiles float
Declare @MinCkc_numberFoundWithinRadius int
Declare @MaxCkc_numberFoundOutsideRadiusAfterMinDate int
Declare @MaxCkcDate datetime
Declare @PingTrucktoGetNewGPSYN char(1)
Declare @TrcID varchar(10)
Declare @countCheckcalls int

Set @return_number_checkGPS =0
Set @ArrivedRadiusMiles =10


-- Step 1: Get Lat/long for Stop.
-- First try to get it from the company table. If present, this will be the most accurate.
Select 	@Lat1 =cmp_latseconds,
	@Long1=cmp_longseconds
From 	Company
where 	cmp_id=@cmp_id	and cmp_id<>'UNKNOWN' and cmp_latseconds is not null

-- Found on company, so convert seconds to decimal degrees
if (isNull(@Lat1,0)> 0)
BEGIN
	Set @Lat1 =@Lat1 /3600 -- convert from seconds to Decimal decrees
	Set @Long1 =@Long1 /3600 -- convert from seconds to Decimal decrees	
END

-- Didn't find on company, so find it on the city table
if (isNull(@Lat1,0)= 0)
BEGIN
	Select 	@Lat1 = cty_latitude,
		@Long1= cty_longitude
	From 	city,Stops
	where 	Stops.stp_number=@stp_number
		And 
		cty_code=stp_city
END
--If no find on city, Just exit. Nothing can be done.
if (isNull(@Lat1,0)= 0) Return -1	 -- Get out of here -- not lat/long for stop location


-- Get the Legheader number. This will be used to filter checkcalls to this dispatch
Set @Lgh_number= (Select lgh_number from stops where stp_number=@stp_number)
-- Find Min Date. Use 2 hours before scheduled earliest date (if scheduled earliest is valid), else 2 hours before arrival
Set @MinCkcDate =(Select 
			Case 	when stp_schdtearliest>'1/1/01' 
				Then dateAdd(hh,-2,stp_schdtearliest)
			ELSE	dateAdd(hh,-2,stp_arrivaldate)
			END
		from stops 
		where stp_number=@Stp_number)


-- Load up the check-calls into our temp table while calculating airmiles from the stop
Insert into #CheckCallsThisLegheader
Select 
	ckc_number,
	ckc_date,
	AirMilesToStop =		
		(Select 
		
			(
				Acos(
		
					cos(	(@lat1 * 3.14159265358979 / 180.0)  )  *
					cos(	( (ckc_latseconds/3600.0) * 3.14159265358979 / 180.0)  )  *
		
        			        cos (  
						(@long1 * 3.14159265358979 / 180.0) - 
						( (ckc_longseconds/3600.0) * 3.14159265358979 / 180.0)
					    )	+
					Sin (	(@lat1 * 3.14159265358979 / 180.0) ) *
					Sin (	( (ckc_latseconds/3600.0) * 3.14159265358979 / 180.0) ) 	
				    ) * 3956.5
			)
		)
From 	Checkcall
where
	ckc_lghnumber= @Lgh_number
	And ckc_latseconds>0
	and Ckc_date> @MinCkcDate

-- No check calls. Just exit. GPS likely doesn't exist for this unit
Set @countCheckcalls= (Select count(*) From #CheckCallsThisLegheader )
if (@countCheckcalls=0) Return -2	 -- Get out of here -- No check calls


-- Find the checkall number closest to stop. 
-- This will confirm we have check call that indicates we have arrived.
Set @MinCkc_numberFoundWithinRadius = 
ISNULL(
	(select min(ckc_number)
	 from 	#CheckCallsThisLegheader c
	 where 	c.AirMilesToStop= (select Min(c2.AirMilesToStop) from #CheckCallsThisLegheader c2)
		And c.AirMilesToStop<= @ArrivedRadiusMiles -- MUST BE REASONABLE CLOSE TO STOP LOCATION
	)
	,0)

-- If Have found it we have arrived, let's see if we departed.
If @MinCkc_numberFoundWithinRadius>0 
BEGIN
	Set @MaxCkc_numberFoundOutsideRadiusAfterMinDate=
	ISNULL(
		(select min(ckc_number)
		 from 	#CheckCallsThisLegheader c
		 where 	c.AirMilesToStop= (select max(AirMilesToStop) from #CheckCallsThisLegheader)
			And c.AirMilesToStop> @ArrivedRadiusMiles
			And c.ckc_number>@MinCkc_numberFoundWithinRadius -- MUST HAVE LEFT THE SAME RADIUS
		)
	,0)
	
END

-- Diagnostic report if debugging
If (@ShowDetail=1)
BEGIN
	Select  stopCity=(Select cty_nmstct from city,stops where stp_number=@stp_number and cty_code=stp_City),
		IsMinCheckCall=(Case when c.ckc_number=@MinCkc_numberFoundWithinRadius THEN 'YES' ELSE 'NO' END),
		IsMaxCheckCall=(Case when c.ckc_number=@MaxCkc_numberFoundOutsideRadiusAfterMinDate THEN 'YES' ELSE 'NO' END),	
		c.*,
		c1.* 
	from 	#CheckCallsThisLegheader c,
		Checkcall c1
	where c.ckc_number=c1.ckc_number
	Order by c.ckc_date
END

-- Now set the return flag-- stored in variable '@return_number_checkGPS'
Set @return_number_checkGPS= 
	ISNULL(
		(select convert(int,AirMilesToStop) from #CheckCallsThisLegheader 
		where ckc_number=@MaxCkc_numberFoundOutsideRadiusAfterMinDate)
	,0)

-- If we haven't found GPS indicating past the stop, see if we should do a ping
If @return_number_checkGPS = 0 -- Haven't found GPS indicating past the stop
BEGIN
	IF (@MinCkc_numberFoundWithinRadius>0) -- Only ping if we can confirm arrived. And have found it arrived
	BEGIN
		SELECT @PingTrucktoGetNewGPSYN = UPPER(ISNULL(gi_string1, 'N'))
		FROM generalinfo
		WHERE gi_name = 'TMail_Det_PingTrcGetNewGPSYN'

		if (@PingTrucktoGetNewGPSYN ='Y') -- Only Ping if they have the General info setting on
		BEGIN
			Set @MaxCkcDate = ISNULL( (Select max(ckc_date) from #CheckCallsThisLegheader), GetDate() )


			-- Finally only ping if the last GPS is more than 10 minutes old.			
			if ( DateDiff(mi,@MaxCkcDate, GetDate())>10 )	-- If last GPS is more than 10 minues old
			BEGIN
				
				-- Set flag so you can see the ping was done
				Set @return_number_checkGPS =-3				

				Set @TrcID =(	select lgh_tractor from legheader where lgh_number=@Lgh_number)

				-- inserting record into this table causes the "Ping truck"
				Insert into tmsqlmessage
				(
				msg_date,
				msg_FormId,
				msg_to,
				msg_totype,
				msg_from,
				msg_subject,
				msg_filterdatadupwaitseconds,
				msg_filterdata,
				msg_fromtype -- JD 30028 added this since insert is failing
				)
				VALUES
				(
				GetDate(),
				-2,
				@TrcID,
				4,
				'Admin',
				'',
				5,
				@TrcID +'-2PING',
				0 -- JD 30028 added this since insert is failing
				)
			END
		END
	END
END

RETURN @return_number_checkGPS  -- Return FLAG variable
GO
GRANT EXECUTE ON  [dbo].[tmail_DetentionPolling_CheckGPSHistory] TO [public]
GO
