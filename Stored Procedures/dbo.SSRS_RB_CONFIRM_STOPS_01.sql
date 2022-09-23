SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[SSRS_RB_CONFIRM_STOPS_01]
	@lgh_number VARCHAR(10) 
AS

SELECT
	s.stp_number,
	co.cmp_id  stop_cmp_id,
	co.cmp_name  stop_cmp_name,
	SUBSTRING(cmp_primaryphone,1,3) + '-' + SUBSTRING(cmp_primaryphone,4,3) + '-' + SUBSTRING(cmp_primaryphone,7,4) as 'Stop Phone',
	ISNULL(cmp_Address1,'') stop_cmp_Address,

	ISNULL(cmp_Address2,'') stop_cmp_Address2,

	ISNULL(cty.cty_nmstct,'') stop_cty_nmstct,
	cty.cty_name + ', ' + cty.cty_state + ISNULL(co.cmp_zip,'') 'CityStateZip',
	s.stp_schdtearliest,
	s.stp_schdtlatest,
	s.stp_arrivaldate,
	s.stp_departuredate,
	s.lgh_number,
	s.mfh_number,
	s.stp_type,
	CASE s.stp_type 
		WHEN 'DRP' THEN 'Delever To'
		WHEN 'PUP' THEN 'Pickup At'
	else
		''
	END AS'Stop Type Text',
	s.stp_event,
	s.stp_sequence,
	s.trl_id,
	s.stp_mfh_sequence,
	s.stp_event,
	s.stp_ord_mileage,
	s.stp_lgh_mileage,
	s.stp_weight,
	s.stp_weightunit,
	s.cmd_code,
	s.stp_description,
	s.stp_count,
	s.stp_countunit,
	s.stp_comment,
	stp_status,
	stp_reftype,
	stp_refnum,
	stp_volume,
	stp_volumeunit,
	STP_DISPATCHED_SEQUENCE,
	stp_arr_confirmed,
	stp_dep_confirmed,
	cmp_directions
FROM stops s
LEFT JOIN city cty 
	ON s.stp_city = cty.cty_code
LEFT JOIN company co
	ON s.cmp_id = co.cmp_id
WHERE s.lgh_number = @lgh_number 
ORDER BY s.stp_mfh_sequence


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_CONFIRM_STOPS_01] TO [public]
GO
