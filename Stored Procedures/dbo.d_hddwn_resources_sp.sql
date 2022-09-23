SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_resources_sp    Script Date: 6/1/99 11:54:46 AM ******/
/* 8/28/97 MF Added column name to temp table becuase no name caused error in 6.5 */

/****** Object:  Stored Procedure dbo.d_hddwn_resources_sp    Script Date: 8/20/97 1:57:30 PM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_resources_sp](@v_legnumber int)
                                 

AS

--*********************************************************************************************
--Declaration and initialization of variables

DECLARE @mov_number  int,
        @char1       Varchar(8),
        @char2       int,
        @rscrs_drv1  Varchar(8),
        @rscrs_drv2  Varchar(8),
        @rscrs_car   Varchar(8)
	
--*********************************************************************************************
--Create temporary waybill table for Printing of waybills process
   
select lgh_tractor,
       lgh_primary_trailer,
       lgh_primary_pup,
       @char1 driver_1,
       @char1 driver_2,
       @char1 carrier,
       ord_hdrnumber,
       lgh_number,
       mov_number
       

  into #resources

  from legheader

where legheader.lgh_number = @v_legnumber 

--********************************************************************************************** 

--determine the driver1,driver2 and carrier for the primary trailer event
select event.evt_carrier,event.evt_driver1,
       event.evt_driver2,min(stops.stp_mfh_sequence) minstop

  into #rscrs_tmp 

  from stops,event,eventcodetable
 where stops.lgh_number = @v_legnumber and
       stops.stp_number = event.stp_number and
       event.evt_sequence = 1 and
       event.evt_eventcode = eventcodetable.abbr and
       eventcodetable.mile_typ_to_stop = 'LD'

group by evt_carrier,evt_driver1,evt_driver2

--Update variables with primary trailer event resources

if @@rowcount <> 0
 begin
   select @rscrs_car = #rscrs_tmp.evt_carrier,
          @rscrs_drv1 = #rscrs_tmp.evt_driver1,
          @rscrs_drv2 = #rscrs_tmp.evt_driver2
     from #rscrs_tmp
 end

else

 begin
   select @rscrs_drv1 = event.evt_driver1,@rscrs_drv2 = event.evt_driver2,@rscrs_car = event.evt_carrier
     from stops,event
    where stops.lgh_number = @v_legnumber and
          stops.stp_number = event.stp_number and
          stops.stp_mfh_sequence = 1 and 
          event.evt_sequence = 1
 end

--update the temp table with the driver1,driver2 and carrier for the primary event

update #resources set driver_1 = @rscrs_drv1,
                      driver_2 = @rscrs_drv2,
                      carrier  = @rscrs_car


SELECT *
 FROM #resources


GO
GRANT EXECUTE ON  [dbo].[d_hddwn_resources_sp] TO [public]
GO
