SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[alk_fc_populate_units] AS

DECLARE @GPSMethod CHAR (3)

SELECT @GPSMethod = gi_string1
FROM generalinfo
WHERE gi_name = 'FC_GPSMethod'

IF @GPSMethod IS NULL
	SELECT @GPSMethod = 'TRC'

TRUNCATE TABLE alk_fc_units

IF @GPSMethod = 'CKC'
	BEGIN
	INSERT INTO alk_fc_units
	SELECT 
		lgh_tractor un_unit
		, legheader.lgh_number un_tripid
		, lgh_driver1 un_driver
		, lgh_driver2 un_driver2
		, lgh_primary_trailer un_trailer
		, lgh_outstatus un_sts
		, mpp_teamleader un_teamldr
		, mpp_fleet un_fleet
		, mpp_division un_dridiv
		, mpp_domicile un_dridom
		, mpp_terminal un_driterm
		, mpp_type1 un_drityp1
		, mpp_type2 un_drityp2
		, mpp_type3 un_drityp3
		, mpp_type4 un_drityp4
		, legheader.mov_number un_move
		, tractorprofile.trc_type1 un_vtyp
		, tractorprofile.trc_type2 un_vtyp2
		, tractorprofile.trc_type3 un_vtyp3
		, tractorprofile.trc_type4 un_vtyp4
		, tractorprofile.trc_terminal un_trterm
		, tractorprofile.trc_fleet un_trfleet
		, tractorprofile.trc_company un_trcompany
		, tractorprofile.trc_division un_trdiv
		, tractorprofile.trc_gps_date un_gps_date
		, 0
		, 0
		, ''
		, legheader.trl_type1 un_trlrtyp
		, legheader.trl_type2 un_trlrtyp2
		, legheader.trl_type3 un_trlrtyp3
		, legheader.trl_type4 un_trlrtyp4
		, legheader.lgh_carrier un_carrier
		, cty_o.cty_name un_orig_city
		, cty_o.cty_state un_orig_st
		, cty_d.cty_name un_dest_city
		, cty_d.cty_state un_dest_st
	from 	legheader
		, tractorprofile
		, city cty_o
		, city cty_d
	where 	lgh_active = 'Y'
	  and	lgh_tractor <> 'UNKNOWN'
	  and	legheader.lgh_outstatus in ('STD', 'CMP')
	  and 	tractorprofile.trc_number = legheader.lgh_tractor
	  AND	tractorprofile.trc_status <> 'OUT'
	  AND	cty_o.cty_code = lgh_startcity
	  AND	cty_d.cty_code = lgh_endcity
	
	CREATE TABLE #ckc (
		ckc_date datetime
		, ckc_tractor char(8) 
		)

	INSERT INTO #ckc
	SELECT DISTINCT MAX (ckc_date), un_unit
	FROM 	checkcall, alk_fc_units
	WHERE	ckc_tractor = un_unit
	  AND 	ckc_event = 'TRP'
	GROUP BY un_unit 
	
	update alk_fc_units
	set 	un_gps_lat = ckc_latseconds
		, un_gps_long = ckc_longseconds
		, un_contact = ckc_comment
	from 	#ckc, checkcall
	WHERE	#ckc.ckc_tractor = un_unit
	  AND	checkcall.ckc_tractor = un_unit
	  AND	checkcall.ckc_date = #ckc.ckc_date

	END

ELSE -- gpsmethod = 'trc', faster, but requires eta agent installed
	BEGIN
	INSERT INTO alk_fc_units
	SELECT 
		lgh_tractor un_unit
		, legheader.lgh_number un_tripid
		, lgh_driver1 un_driver
		, lgh_driver2 un_driver2
		, lgh_primary_trailer un_trailer
		, lgh_outstatus un_sts
		, mpp_teamleader un_teamldr
		, mpp_fleet un_fleet
		, mpp_division un_dridiv
		, mpp_domicile un_dridom
		, mpp_terminal un_driterm
		, mpp_type1 un_drityp1
		, mpp_type2 un_drityp2
		, mpp_type3 un_drityp3
		, mpp_type4 un_drityp4
		, legheader.mov_number un_move
		, tractorprofile.trc_type1 un_vtyp
		, tractorprofile.trc_type2 un_vtyp2
		, tractorprofile.trc_type3 un_vtyp3
		, tractorprofile.trc_type4 un_vtyp4
		, tractorprofile.trc_terminal un_trterm
		, tractorprofile.trc_fleet un_trfleet
		, tractorprofile.trc_company un_trcompany
		, tractorprofile.trc_division un_trdiv
		, tractorprofile.trc_gps_date un_gps_date
		, tractorprofile.trc_gps_latitude 
		, tractorprofile.trc_gps_longitude
		, tractorprofile.trc_gps_desc
		, legheader.trl_type1 un_trlrtyp
		, legheader.trl_type2 un_trlrtyp2
		, legheader.trl_type3 un_trlrtyp3
		, legheader.trl_type4 un_trlrtyp4
		, legheader.lgh_carrier un_carrier
		, cty_o.cty_name un_orig_city
		, cty_o.cty_state un_orig_st
		, cty_d.cty_name un_dest_city
		, cty_d.cty_state un_dest_st
	from 	legheader
		, tractorprofile
		, city cty_o
		, city cty_d
	where 	lgh_active = 'Y'
	  and	lgh_tractor <> 'UNKNOWN'
	  and	legheader.lgh_outstatus in ('STD', 'CMP')
	  and 	tractorprofile.trc_number = legheader.lgh_tractor
	  AND	tractorprofile.trc_status <> 'OUT'
	  AND	cty_o.cty_code = lgh_startcity
	  AND	cty_d.cty_code = lgh_endcity

	END
GO
GRANT EXECUTE ON  [dbo].[alk_fc_populate_units] TO [public]
GO
