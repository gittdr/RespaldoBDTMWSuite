SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[GetStopsByLegList] (@legTable as TableVarLegList READONLY)  
AS  
BEGIN  
	SELECT	s.stp_number,
			lgh.lgh_number,
			lgh.lgh_outstatus,
			lgh.lgh_class1,
			lgh.lgh_class2,
			lgh.lgh_class3,
			lgh.lgh_class4,
			lgh.lgh_primary_trailer,
			lgh.lgh_tractor,
			lgh.lgh_driver1,
			s.stp_number,
			ISNULL(oh.ord_number, '') 'ord_number',
			ISNULL(oh2.ord_number, '') 'stp_order',
			s.stp_event,
			s.cmp_id,
			s.cmp_name,
			s.stp_address,
			c.cty_name + ', ' + c.cty_state 'City',
			s.stp_zipcode,
			s.stp_schdtearliest,
			s.stp_schdtlatest,
			s.stp_arrivaldate,
			s.stp_departuredate,
			s.stp_status,
			s.stp_departure_status,
			CASE 
				WHEN ISNULL(s.stp_lgh_mileage, 0) < 0 THEN 0
				ELSE ISNULL(s.stp_lgh_mileage, 0)
			END stp_lgh_mileage,
			s.stp_loadstatus,
			CASE 
				WHEN s.stp_type = 'NONE' AND s.stp_event IN ('HLT', 'HCT', 'XDL', 'XHT') THEN 'PUP'
				WHEN s.stp_type = 'NONE' AND s.stp_event IN ('DLT', 'XDU', 'XDT') THEN 'DRP'
				ELSE s.stp_type
			END 'stp_type'
	  FROM	@legTable as legs
			INNER JOIN dbo.legheader lgh ON lgh.lgh_number = legs.legNumber
			INNER JOIN dbo.stops s ON s.lgh_number = legs.legNumber
			LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = lgh.ord_hdrnumber
			LEFT OUTER JOIN city c ON c.cty_code = s.stp_city
			LEFT OUTER JOIN orderheader oh2 ON oh2.ord_hdrnumber = s.ord_hdrnumber
END  
GO
GRANT EXECUTE ON  [dbo].[GetStopsByLegList] TO [public]
GO
