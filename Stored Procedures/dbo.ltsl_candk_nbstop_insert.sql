SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ltsl_candk_nbstop_insert] @mov INT,@ord_hdrnumber INT

/**
 * 
 * NAME:
 * dbo.ltsl_candk_nbstop_insert
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Custom stored procedure for postprocessing of EDI inbound load tenders
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * NONE
 *
 * PARAMETERS:
 * @ord_number::varchar(12)::input - TMW order number
 * @trp_id::varchar(20)::input - Optional input parm with trading partner id from 204
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 *	01.01.2012.01 - A. Rossman(TMW) - Initial version
**/

AS

DECLARE  @ord_billto varchar(50)

SELECT  @ord_billto=ord_billto
FROM orderheader 
	WHERE ord_hdrnumber = @ord_hdrnumber




INSERT INTO edi_nonbillable_tender_stops
			([stp_number]
           ,[ord_hdrnumber]
           ,[mov_number]
           ,[nts_event]
           ,[nts_arv_status]
           ,[nts_arv_date]
           ,[nts_dep_status]
           ,[nts_dep_date]
           ,[ord_billto]
           )
SELECT  s.stp_number
		,@ord_hdrnumber
		,@mov
		,s.stp_event
		,'OPN'
		,s.stp_arrivaldate
		,'OPN'
		,s.stp_departuredate
		,@ord_billto
FROM stops s
	INNER JOIN eventcodetable e
		ON s.stp_event = e.abbr
		 inner join company c on c.cmp_id= s.cmp_id
		 INNER JOIN edi_nonbillable_status_events enb ON s.stp_event = enb.evt_code
		 inner join event  evt on  evt.stp_number= s.stp_number
WHERE s.mov_number = @mov
	AND e.ect_billable = 'N'		
	and isnull(c.cmp_railramp,'N') <>'Y' 
	and isnull(c.cmp_port,'N') <>'Y'
	And (  (isnull(evt.evt_trailer1,'UNKNOWN')   <> 'UNKNOWN' ) or
			(isnull(evt.evt_trailer2,'UNKNOWN')<> 'UNKNOWN' ) or
			(isnull(evt.evt_trailer3,'UNKNOWN')   <> 'UNKNOWN' ) or
			(isnull(evt.evt_trailer4,'UNKNOWN')   <> 'UNKNOWN' )
		 )
	and  s.stp_number not in (select stp_number from edi_nonbillable_tender_stops)	


GO
GRANT EXECUTE ON  [dbo].[ltsl_candk_nbstop_insert] TO [public]
GO
