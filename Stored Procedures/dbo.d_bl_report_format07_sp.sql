SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_bl_report_format07_sp]( @ordnum int )
AS

/**
 * 
 * REVISION HISTORY:
 * 02/29/2008 ? PTS41162 - REF ? Initialized
 *
**/

declare @pup_cnt int, 
				@drp_cnt int,
				@first_pick datetime,
				@last_drop datetime,
				@pup_schdtearliest datetime, 
				@pup_schdtlatest datetime,
				@drp_schdtearliest datetime, 
				@drp_schdtlatest datetime


SELECT @pup_cnt = COUNT(*) 
FROM STOPS 
WHERE STP_TYPE = 'PUP'
AND ord_hdrnumber = @ordnum

SELECT @drp_cnt = COUNT(*) 
FROM STOPS 
WHERE STP_TYPE = 'DRP'
AND ord_hdrnumber = @ordnum

select @first_pick = min(stp_arrivaldate) 
from stops 
where ord_hdrnumber = @ordnum 
and stp_type = 'PUP'

select @last_drop = max(stp_arrivaldate) 
from stops 
where ord_hdrnumber = @ordnum 
and stp_type = 'DRP'

select @pup_schdtearliest = stp_schdtearliest, @pup_schdtlatest = stp_schdtlatest 
from stops 
where ord_hdrnumber = @ordnum 
and stp_arrivaldate = @first_pick
and stp_type = 'PUP'

select @drp_schdtearliest = stp_schdtearliest, @drp_schdtlatest = stp_schdtlatest 
from stops 
where ord_hdrnumber = @ordnum 
and stp_arrivaldate = @last_drop
and stp_type = 'DRP'
				
/*
If there are one pickup with one or more drops or one or more pickups with one drop
then we need to print a BOL for each combo. Otherwise print one BOL the original way.
*/
IF @pup_cnt = 1 and @drp_cnt >= 1
	SELECT @ordnum,
				STP_MFH_SEQUENCE,
				C1.cmp_name,
				C1.cmp_address1,
				C2.cty_name,
				C2.cty_state,
				C1.cmp_zip,
				C1.cmp_primaryphone,
				C1.cmp_contact,
 				C3.cmp_name,
				C3.cmp_address1,
				C4.cty_name,
				C4.cty_state,
				C3.cmp_zip,
				C3.cmp_primaryphone,
				C3.cmp_contact,
				@pup_schdtearliest as first_schdtearliest,
				@pup_schdtlatest as first_schdtlatest,
				stp_schdtearliest as last_schdtearliest,
				stp_schdtlatest as last_schdtlatest,
				ORDERHEADER.ord_remark
	
	FROM ORDERHEADER INNER JOIN COMPANY C1 ON ORDERHEADER.ord_shipper = C1.cmp_id
									 INNER JOIN CITY C2 ON ORDERHEADER.ord_origincity = C2.cty_code,
			       STOPS INNER JOIN COMPANY C3 ON STOPS.cmp_id = C3.cmp_id
						       INNER JOIN CITY C4 ON STOPS.stp_city = C4.cty_code
									 
	WHERE ORDERHEADER.ord_hdrnumber = @ordnum
	  AND STOPS.ord_hdrnumber = ORDERHEADER.ord_hdrnumber
		AND STP_TYPE = 'DRP'
	ORDER BY STP_MFH_SEQUENCE
	
ELSE
	IF @pup_cnt >= 1 and @drp_cnt = 1
			SELECT @ordnum,
				STP_MFH_SEQUENCE,
				C3.cmp_name,
				C3.cmp_address1,
				C4.cty_name,
				C4.cty_state,
				C3.cmp_zip,
				C3.cmp_primaryphone,
				C3.cmp_contact,
 				DRP.cmp_name,
				DRP.cmp_address1,
				DRP.cty_name,
				DRP.cty_state,
				DRP.cmp_zip,
				DRP.cmp_primaryphone,
				DRP.cmp_contact,
				stp_schdtearliest as first_schdtearliest,
				stp_schdtlatest as first_schdtlatest,
				@drp_schdtearliest as last_schdtearliest,
				@drp_schdtlatest as last_schdtlatest,
				ORDERHEADER.ord_remark
	
	FROM ORDERHEADER INNER JOIN COMPANY C1 ON ORDERHEADER.ord_shipper = C1.cmp_id
									 INNER JOIN CITY C2 ON ORDERHEADER.ord_origincity = C2.cty_code,
			       STOPS INNER JOIN COMPANY C3 ON STOPS.cmp_id = C3.cmp_id
						       INNER JOIN CITY C4 ON STOPS.stp_city = C4.cty_code,

			(SELECT C5.cmp_name, C5.cmp_address1, C6.cty_name, C6.cty_state, C5.cmp_zip, C5.cmp_primaryphone, C5.cmp_contact
			 FROM STOPS INNER JOIN COMPANY C5 ON STOPS.cmp_id = C5.cmp_id
						      INNER JOIN CITY C6 ON STOPS.stp_city = C6.cty_code
			 WHERE STP_TYPE = 'DRP'
				AND ord_hdrnumber = @ordnum
			) DRP
									 
	WHERE ORDERHEADER.ord_hdrnumber = @ordnum
	AND STOPS.ord_hdrnumber = ORDERHEADER.ord_hdrnumber
	AND STP_TYPE = 'PUP'
	ORDER BY STP_MFH_SEQUENCE
	
ELSE
	select @ordnum,
				1 STP_MFH_SEQUENCE,
				C1.cmp_name 'shipper_cmp_name',
				C1.cmp_address1 'shipper_cmp_address1',
				C2.cty_name 'shipper_cmp_city_name',
				C2.cty_state 'shipper_cmp_state',
				C1.cmp_zip 'shipper_cmp_zip',
				C1.cmp_primaryphone 'shipper_cmp_primaryphone',
				C1.cmp_contact 'shipper_cmp_contact',
				C3.cmp_name 'consignee_cmp_name',
				C3.cmp_address1 'consignee_cmp_address1',
				C4.cty_name 'consignee_cmp_city_name',
				C4.cty_state 'consignee_cmp_city_state',
				C3.cmp_zip 'consignee_cmp_zip',
				C3.cmp_primaryphone 'consignee_cmp_primaryphone',
				C3.cmp_contact 'consignee_cmp_contact',
				@pup_schdtearliest 'first_schdtearliest',
				@pup_schdtlatest 'first_schdtlatest',
				@drp_schdtearliest 'last_schdtearliest',
				@drp_schdtlatest 'last_schdtlatest',
				oh.ord_remark
	from orderheader oh inner join company C1 on oh.ord_shipper = C1.cmp_id
											inner join city C2 on oh.ord_origincity = C2.cty_code
											inner join company C3 on oh.ord_consignee = C3.cmp_id
											inner join city C4 on oh.ord_destcity = C4.cty_code
	where ord_hdrnumber = @ordnum


RETURN 0
GO
GRANT EXECUTE ON  [dbo].[d_bl_report_format07_sp] TO [public]
GO
