SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

	
Create Proc [dbo].[update_gf_trltype_sp] @lgh_number int, @requestid int As

/**
 * 
 * NAME:
 * update_gf_trltype_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Set the Trailer Type on the ExpertFuel request record.
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * zippo
 *
 * PARAMETERS:
 * 001 - @lgh_number, int;
 *       Legheader number for the Trip Segment of the Fuel request

 * 002 - @requestid, int;
 *       Unique transaction ID passed on to ExpertFuel server.
 *
 * REFERENCES:
 * 001 - Called from Trigger it_geofuelrequest if the 'SetExpFuelTrlType' generalinfo
 *	 setting is set.
 * 
 * REVISION HISTORY:
 * (unknown) - PTS 27857 - Update the column on the GeoFuelRequest table with the ExpertFuel code required by
	the Trailer for the passed Leg. This will probably have to be customized for each customer
	since customers track different information on Trailers.
 * 07/05/2005 - DJM - PTS 29276 - Modify the stored proc to allow setting of a default value in the
 *	gf_trltype column on the geofuelrequest record. The default should
 *	be user-defined to support IDSC requirements.
 *
 **/

Declare	@trlid		VarChar(13),
	@Division	VarChar(6),
	@default	varchar(6),
	@v_default_trlcode	varchar(6)


-- Get the Defalut value from the INI setting, if one exists
Select @default = isnull(gi_string2,'UNK'),
	@v_default_trlcode = isNull(gi_string3,'') 
from generalinfo where gi_name = 'SetExpFuelTrlType'


-- Get the Trailer ID from the Legheader.
select @trlid = lgh_primary_trailer from legheader where lgh_number = @lgh_number


/* DJM - Folling Logic is custom for Arrow. Other clients may have other requirements
	for determining the proper code value to pass to ExpertFuel. Code is only
	valid in ExpertFuel if using Intelliroute for routing soulutions
*/
-- Get the code from the Division on the Trailerprofile record.
select @Division = isNull(trl_division, @default) from trailerprofile where trl_id = @trlid
if @division = 'UNK' and @default <> 'UNK'
	select @division = @default

if @division <> 'UNK' 
	Begin
		/*
		if @division = 'F'
			update geofuelrequest 	
			set gf_trltype = '2'
			where gf_lgh_number = @lgh_number
				and gf_requestid = @requestid
		if @division = 'V'
			update geofuelrequest 	
			set gf_trltype = '4'
			where gf_lgh_number = @lgh_number
				and gf_requestid = @requestid
		*/
		-- 'F' for Flatbed
		-- 'V' for Van
		-- Defalut the trailer code if no match is found
		Update GeoFuelRequest
		set gf_trltype = Case @division
					when 'F' then '2'
					when 'V' then '4'
					else @v_default_trlcode
				End
		where gf_lgh_number = @lgh_number
			and gf_requestid = @requestid

	End

GO
GRANT EXECUTE ON  [dbo].[update_gf_trltype_sp] TO [public]
GO
