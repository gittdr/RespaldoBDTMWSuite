SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[update_audit] @mov_number int
as

/**
 * 
 * NAME:
 * dbo.update_audit 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * MF   insert generalinfo (gi_name, gi_string1) values ('TRIPAUDIT', "YES")
 * PTS 23691 CGK 9/3/2004
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

if (SELECT substring(upper(gi_string1),1,1) 
	FROM	generalinfo
	WHERE	gi_name = 'TRIPAUDIT')='Y'
begin
	declare @dt datetime
	select @dt = getdate()

	insert tripaudit (upd_date, upd_user,upd_app,mov_number, ord_hdrnumber, customer, lgh_number,lgh_outstatus, eventcode, cmp_id, stp_city,
	arrivaldate, departuredate,evt_status, mfh_sequence, stp_sequence, driver1,  driver2,  tractor,  trailer1, trailer2,
	carrier,  cmd_code, mfh_mileage, ord_mileage, lgh_mileage, weight, cnt, volume,quantity, tare_weight,stp_number,
	fgt_number,  evt_number,  evt_sequence, fgt_sequence)
	SELECT 
		 @dt as 'upd_date',
		 @tmwuser as 'user',
		 app_name(),
		 stops.mov_number mov_number, 
        	 stops.ord_hdrnumber, 
	         orderheader.ord_billto customer,   
	  	 stops.lgh_number, 
		 lgh_outstatus,
         	 event.evt_eventcode eventcode, 
         	stops.cmp_id, 
         	stops.stp_city stp_city, 
         	event.evt_startdate arrivaldate, 
         	evt_enddate departuredate, 
         	event.evt_status evt_status, 
         	stops.stp_mfh_sequence mfh_sequence, 
         	stops.stp_sequence, 
 	 	event.evt_driver1 driver1, 
         	event.evt_driver2 driver2, 
         	event.evt_tractor tractor, 
         	event.evt_trailer1 trailer1, 
         	event.evt_trailer2 trailer2, 
         	event.evt_carrier carrier, 
         	freightdetail.cmd_code, 
         	stops.stp_mfh_mileage mfh_mileage, 
         	stops.stp_ord_mileage ord_mileage, 
         	stops.stp_lgh_mileage lgh_mileage, 
         	freightdetail.fgt_weight weight, 
         	freightdetail.fgt_count cnt, 
         	freightdetail.fgt_volume volume, 
         	freightdetail.fgt_quantity quantity, 
         	freightdetail.tare_weight,
         	stops.stp_number, 
         	freightdetail.fgt_number, 
         	event.evt_number, 
         	event.evt_sequence, 
         	freightdetail.fgt_sequence
  	  FROM stops  LEFT OUTER JOIN  legheader  ON  stops.lgh_number  = legheader.lgh_number   --pts40189 outer join conversion
				LEFT OUTER JOIN  freightdetail  ON  freightdetail.stp_number  = stops.stp_number   
				LEFT OUTER JOIN  orderheader  ON  stops.ord_hdrnumber  = orderheader.ord_hdrnumber ,
		   event 
   	WHERE  stops.stp_number = event.stp_number and 
	 	   stops.mov_number = @mov_number 
	order by stops.stp_sequence
end
GO
GRANT EXECUTE ON  [dbo].[update_audit] TO [public]
GO
