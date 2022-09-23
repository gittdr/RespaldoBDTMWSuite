SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_stops_sp_v3    Script Date: 6/1/99 11:54:47 AM ******/
/****** Object:  Stored Procedure dbo.d_hddwn_stops_sp    Script Date: 8/20/97 1:57:32 PM ******/
create proc [dbo].[d_hddwn_stops_sp_v3] (	@stringparm varchar(13),
				@numberparm int,
				@retrieve_by varchar(6),
				@slacktime int)
as
declare 	@mov_number int

If @retrieve_by = "LGHNUM"
	SELECT 	@mov_number = mov_number  
	FROM legheader
	WHERE lgh_number = @numberparm

Else
	SELECT @mov_number = @numberparm

/*mf 8/6/97 added extra datetime cols to allow seperation of date and time*/
SELECT  stops.stp_event, 
	stops.cmp_id, 
	stops.cmp_name, 
	city.cty_nmstct,
	event.evt_hubmiles, 
	stops.stp_schdtearliest, 
	stops.stp_schdtlatest, 
	stops.stp_arrivaldate,
	stops.stp_reasonlate, 
	stops.stp_departuredate, 
	stops.stp_reasonlate_depart, 
	stops.stp_status,
	stops.ord_hdrnumber,
	stops.stp_number,
	stops.lgh_number, 
	stops.mov_number,
	stops.stp_type,
	stops.stp_lgh_mileage,
	stops.stp_ord_mileage, 		 		 
	stops.stp_city, 
	stops.stp_state,		 		 
	stops.stp_sequence,  
	stops.stp_mfh_sequence,
	orderheader.ord_number,
	lbl1.name,
	lbl2.name,
	evt_number,
	stops.stp_arrivaldate 'arr_dte',
	substring(convert(char(5), stops.stp_arrivaldate, 8),1,2) + substring(convert(char(5), stops.stp_arrivaldate, 8),4,2) 'arr_tm',
	stops.stp_departuredate 'dep_dte',
	substring(convert(char(5), stops.stp_departuredate, 8),1,2) + substring(convert(char(5), stops.stp_departuredate, 8),4,2) 'dep_tm',
	@slacktime slacktime, 
	company.cmp_altid 
FROM stops, city, event, orderheader, labelfile lbl1, labelfile lbl2, company
WHERE   ( stops.stp_city = city.cty_code ) AND 
	( event.stp_number = stops.stp_number ) AND 
	( stops.ord_hdrnumber *= orderheader.ord_hdrnumber) AND
	(( stops.mov_number = @mov_number ) AND ( event.evt_sequence = 1 )) and
	(( stops.stp_reasonlate *= lbl1.abbr ) AND ( lbl1.labeldefinition = "ReasonLate" )) and
	(( stops.stp_reasonlate_depart *= lbl2.abbr ) AND ( lbl2.labeldefinition = "ReasonLate" )) and
	stops.cmp_id = company.cmp_id 
ORDER BY stops.stp_mfh_sequence, stops.ord_hdrnumber, stops.stp_sequence


GO
GRANT EXECUTE ON  [dbo].[d_hddwn_stops_sp_v3] TO [public]
GO
