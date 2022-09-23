SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_stop_events_sp    Script Date: 6/1/99 11:54:57 AM ******/
CREATE PROCEDURE [dbo].[d_stop_events_sp] (	@strparm	char(12),
												@numparm	int,
												@rettype	varchar(10))
AS

/*SELECT	@rettype = UPPER(@rettype)

IF @rettype = "" SELECT	@rettype = "MOVE"
*/

/* Below is the two same set of select statements
   If you add column to one, also add to another
*/

IF (@rettype = "MOVE")
	SELECT event.ord_hdrnumber,   
         event.stp_number,   
         event.evt_eventcode,   
         event.evt_number,   
         event.evt_startdate,   
         event.evt_enddate,   
         event.evt_status,   
         event.evt_earlydate,   
         event.evt_latedate,   
         event.evt_weight,   
         event.evt_weightunit,   
         event.fgt_number,   
         event.evt_count,   
         event.evt_countunit,   
         event.evt_volume,   
         event.evt_volumeunit,   
         event.evt_pu_dr,   
         event.evt_sequence,   
         event.evt_contact,   
/*         event.timestamp,    */
	 "" dummy1,
         event.evt_driver1,   
         event.evt_driver2,   
         event.evt_tractor,   
         event.evt_trailer1,   
         event.evt_trailer2,   
         event.evt_chassis,   
         event.evt_dolly,   
         event.evt_carrier,   
         event.evt_refype,   
         event.evt_refnum,   
         company.cmp_id,   
         company.cmp_name,   
         city.cty_nmstct  
    FROM event,   
         company,   
         stops,   
         city  
   WHERE ( company.cmp_id = stops.cmp_id ) and  
         ( stops.stp_number = event.stp_number ) and  
         ( stops.stp_city = city.cty_code ) and  
         ( ( stops.mov_number = @numparm ) )


IF(@rettype ="STOPS")
	SELECT	event.ord_hdrnumber,   
     	event.stp_number,   
     	event.evt_eventcode,   
		event.evt_number,   
		event.evt_startdate,   
		event.evt_enddate,   
		event.evt_status,   
		event.evt_earlydate,   
		event.evt_latedate,   
		event.evt_weight,   
		event.evt_weightunit,   
		event.fgt_number,   
		event.evt_count,   
		event.evt_countunit,   
		event.evt_volume,   
		event.evt_volumeunit,   
		event.evt_pu_dr,   
		event.evt_sequence,   
		event.evt_contact,   
/*		event.timestamp,   */
		"" dummy1,
		event.evt_driver1,   
		event.evt_driver2,   
		event.evt_tractor,   
		event.evt_trailer1,   
		event.evt_trailer2,   
		event.evt_chassis,   
		event.evt_dolly,   
		event.evt_carrier,   
		event.evt_refype,   
		event.evt_refnum,   
		company.cmp_id,   
		company.cmp_name,   
		city.cty_nmstct  
	FROM	event,   
		company,   
		stops,   
		city  
	WHERE	( company.cmp_id = stops.cmp_id ) and  
		( stops.stp_number = event.stp_number ) and  
		( stops.stp_city = city.cty_code ) and  
		( ( stops.stp_number = @numparm ) )



GO
GRANT EXECUTE ON  [dbo].[d_stop_events_sp] TO [public]
GO
