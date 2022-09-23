SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--create stored procedure 
CREATE PROC [dbo].[d_hddwn_resources_update_sp](@v_legnumber int, 
                                        @v_carrier VarChar(12),
                                        @v_driver1 VarChar(12),
                                        @v_driver2 Varchar(12),
                                        @v_tractor Varchar(12),
                                        @v_trailer1 Varchar(13),
                                        @v_trailer2 Varchar(13))
					
       
                                     
                                 

AS

BEGIN
--Declaration
  DECLARE @stp_mfh_sequence int

--Find the stops stp_mfh_sqeuence number for the primary trailer event
select @stp_mfh_sequence = min(stops.stp_mfh_sequence)
  from stops,event,eventcodetable
 where stops.lgh_number = @v_legnumber and
       stops.stp_number = event.stp_number and
       event.evt_sequence = 1 and
       event.evt_eventcode = eventcodetable.abbr and
       eventcodetable.mile_typ_to_stop = 'LD'

--Update Carrier, tractor and drivers for the leg
-- JT added 10/24/97 - removed the following resources from the trailer update.  The rest of the
-- resources need set for all stops on the leg.
update event
   set evt_carrier = @v_carrier,
       evt_driver1 = @v_driver1,
       evt_driver2 = @v_driver2,
       evt_tractor = @v_tractor 
  from stops
 where stops.lgh_number = @v_legnumber and
       stops.stp_number = event.stp_number

--Update Assets for the primary trailer event and all primary events prior to the primary trailer event 
update event
   set evt_trailer1 = @v_trailer1,
       evt_trailer2 = @v_trailer2
  from stops,event
 where stops.lgh_number = @v_legnumber and
       stops.stp_mfh_sequence <= @stp_mfh_sequence  and
       stops.stp_number = event.stp_number and
       event.evt_sequence = 1 

--Update legheader information       
update legheader
   set lgh_tractor = @v_tractor,
       lgh_primary_trailer = @v_trailer1,
       lgh_primary_pup = @v_trailer2

 where lgh_number = @v_legnumber

END

GO
GRANT EXECUTE ON  [dbo].[d_hddwn_resources_update_sp] TO [public]
GO
