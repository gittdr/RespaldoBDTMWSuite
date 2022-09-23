SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--exec [SSRS_Vital_Confirm_Stops]640
CREATE procedure [dbo].[SSRS_RB_CONFIRM_ICC_STOPS_01]
	@lgh_number varchar(10) 
as

Select
	stops.stp_number,
	company.cmp_id  stop_cmp_id,
	company.cmp_name  stop_cmp_name,
	substring(cmp_primaryphone,1,3) + '-' + substring(cmp_primaryphone,4,3) + '-' + substring(cmp_primaryphone,7,4) as 'Stop Phone',
	isnull(cmp_Address1,'') stop_cmp_Address,

	isnull(cmp_Address2,'') stop_cmp_Address2,

	isnull(city.cty_nmstct,'') stop_cty_nmstct,
	city.cty_name + ', ' + city.cty_state + isnull(company.cmp_zip,'') 'CityStateZip',
	company.cmp_contact,
	stops.stp_schdtearliest,
	stops.stp_schdtlatest,
	stops.stp_arrivaldate,
	stops.stp_departuredate,
	stops.lgh_number,
	stops.mfh_number,
	stops.stp_type,
	case when stops.stp_type = 'DRP' or stp_event in ('XDU','DLT') then 'Deliver To'
		when stops.stp_type = 'PUP' or stp_event in ('XDL','HLT')  then 'Load At'
	else
		stp_event
	end as 'Stop Type Text',
	stops.stp_event,
	stops.stp_sequence,
	stops.trl_id,
	stops.stp_mfh_sequence,
	stops.stp_event,
	stops.stp_ord_mileage,
	stops.stp_lgh_mileage,
	stops.stp_weight,
	stops.stp_weightunit,
	stops.cmd_code,
	stops.stp_description,
	stops.stp_count,
	stops.stp_countunit,
	stops.stp_comment,
	stp_status,
	stp_reftype,
	stp_refnum,
	stp_volume,
	stp_volumeunit,
	STP_DISPATCHED_SEQUENCE,
	stp_arr_confirmed,
	stp_dep_confirmed,
	cmp_directions,
	f.fgt_description,
	fgt_reftype,
	fgt_refnum,
	ord_cmdvalue	
	

from stops 
	left join city on stops.stp_city = cty_code
	left join Company on stops.cmp_id = Company.cmp_id
	left join freightdetail f on f.stp_number = stops.stp_number
	left join orderheader O on o.ord_hdrnumber = stops.ord_hdrnumber
where
	stops.lgh_number = @lgh_number 
	and stp_event not in ('BMT','EMT')
	

order by stp_mfh_sequence




GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_CONFIRM_ICC_STOPS_01] TO [public]
GO
