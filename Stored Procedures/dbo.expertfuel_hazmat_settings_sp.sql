SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[expertfuel_hazmat_settings_sp] (@leg int, @requestid int)
AS


/* 
	PTS 45570 - DJM - Enable HazMat support in the ExpertFuel Request. 
	
	PTS 47795 - DJM - Modifiy to allow user to override the Hazmat code for the Commodity.  Used for 
		customer that does not currently have support for the Hazmat codes on the Commodity (i.e. old build)
*/


Declare @EFHazMatInterface	char(1),
	@maxcode	int,
	@EFHazmatClassValueOverride	char(1),
	@overridevalue	char(1),
	@hazclass char(1)


Select @EFHazMatInterface = Left(isnull(gi_string1,''),1) from generalinfo where gi_name = 'EFHazMatInterface'
select @hazclass = isnull(hazmat_class,'') from geofuelrequest where gf_requestid = @requestid

-- PTS 47795 - Check the existing value
if @hazclass = ''
	Begin
		update geofuelrequest
		set hazmat_route = 'Y'
		where gf_requestid = @requestid
			and hazmat_route <> 'Y'

	End
Else
	-- The value is already set - don't overwrite it.
	Return

-- PTS 47795 - Check the GI setting
Select @EFHazmatClassValueOverride = Left(isnull(gi_string1,''),1) from generalinfo where gi_name = 'EFHazmatClassValueOverride'
if @EFHazmatClassValueOverride = 'Y'
	Begin
		select @overridevalue = Left(isnull(gi_string2,''),1) from generalinfo where gi_name = 'EFHazmatClassValueOverride'

		update geofuelrequest
		set hazmat_class = @overridevalue
		where gf_requestid = @requestid
			and gf_lgh_number = @leg
			and hazmat_route  = 'Y'
			and isnull(hazmat_class,'') <> @overridevalue
	
		Return -- do not continue

	End

-- Logic for the ALK (PCMiler) interface
if @EFHazMatInterface = 'A'
	Begin
		select @maxcode = max(isNull(l.code,0))
		from freightdetail f join stops s on f.stp_number = s.stp_number
			join commodity c on f.cmd_code = c.cmd_code
			join commodityclass cc on c.cmd_class = cc.ccl_code
			join labelfile l on cc.alk_hazlevel = l.abbr
				and l.labeldefinition = 'ALKHazLevel'
				and l.code > 0
		where s.lgh_number = @leg
			and f.cmd_code is not null
			and f.cmd_code <> 'UNKNOWN'
			and cmd_active = 'Y'
			and cmd_hazardous > 0

		if @maxcode > 0 
			update geofuelrequest
			set hazmat_route = 'Y',
				hazmat_class = cast(@maxcode as char(1))
			where gf_lgh_number = @leg
				and gf_requestid = @requestid
				and gf_requestid = @requestid
				and gf_status = 'RUN'
		else
			-- This is here in case the customer does not have the Commodity Class relationship set up correctly.
			update geofuelrequest
			set hazmat_route = 'Y',
				hazmat_class = '1'
			where gf_status = 'RUN'
				and gf_lgh_number = @leg
				and gf_requestid = @requestid
	End

-- Rand Interface
if @EFHazMatInterface = 'R'
	Begin
		select @maxcode = max(isNull(l.code,0))
		from freightdetail f join stops s on f.stp_number = s.stp_number
			join commodity c on f.cmd_code = c.cmd_code
			join commodityclass cc on c.cmd_class = cc.ccl_code
			join labelfile l on cc.alk_hazlevel = l.abbr
				and l.labeldefinition = 'RANDHazLevel'
				and l.code > 0
		where s.lgh_number = @leg
			and f.cmd_code is not null
			and f.cmd_code <> 'UNKNOWN'
			and cmd_active = 'Y'
			and cmd_hazardous > 0

		-- Must reduce the code by 1 since ExpertFuel only supports one character. ExpertFuel uses the code 'D' 
		--	to indicate 'All hazmat classes' where the Labelfile table uses zero to indicate 'Disabled'.
		if @maxcode > 0 
			update geofuelrequest
			set hazmat_route = 'Y',
				hazmat_class = cast(@maxcode-1 as char(1))
			where gf_lgh_number = @leg
				and gf_requestid = @requestid
				and gf_status = 'RUN'
		else
			-- This is here in case the customer does not have the Commodity Class relationship set up correctly.
			update geofuelrequest
			set hazmat_route = 'Y',
				hazmat_class = 'D'
			where gf_status = 'RUN'
				and gf_lgh_number = @leg
				and gf_requestid = @requestid
			

	end 
GO
GRANT EXECUTE ON  [dbo].[expertfuel_hazmat_settings_sp] TO [public]
GO
