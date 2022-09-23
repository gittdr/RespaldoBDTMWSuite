SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_dateshub_sp    Script Date: 6/1/99 11:54:46 AM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_dateshub_sp](@v_legnumber int)
                                 

AS

--*********************************************************************************************
--Declaration and initialization of variables
DECLARE @char1         datetime,
        @char2         float,
        @char3         int,
        @begining_date datetime,
        @ending_date   datetime,
        @dates_beghub  float,
        @dates_endhub  float
        
--*********************************************************************************************
--Create temporary dateshub table for Printing of waybills process
select @char1 begining_date,
       @char1 ending_date,
       @char2 begining_hubmiles,
       @char2 ending_hubmiles,
       @char3 lgh_number
       

  into #dateshub


--select all the hub miles and stops for a particular leg for the primary event

select event.evt_hubmiles,
       stops.stp_mfh_sequence,
       event.evt_eventcode

  into #wrk_dateshub
    
  from stops,event
 where stops.lgh_number = @v_legnumber and
       stops.stp_number = event.stp_number and
       event.evt_sequence = 1

--********************************************************************************************** 
select @begining_date = stp_arrivaldate
  from stops
 where stp_mfh_sequence = (select min(stp_mfh_sequence)
                             from stops
                            where lgh_number = @v_legnumber) and
       lgh_number = @v_legnumber
 
select @ending_date = stp_arrivaldate
  from stops
 where stp_mfh_sequence = (select max(stp_mfh_sequence)
                             from stops
                            where lgh_number = @v_legnumber) and
       lgh_number = @v_legnumber

--********************************************************************************************** 
select @dates_beghub= #wrk_dateshub.evt_hubmiles
  from #wrk_dateshub,eventcodetable
 where #wrk_dateshub.evt_eventcode = eventcodetable.abbr and
       eventcodetable.mile_typ_to_stop = 'LD' and
       #wrk_dateshub.stp_mfh_sequence = (select min(stp_mfh_sequence)
                                           from #wrk_dateshub)

if @@rowcount = 0
   select @dates_beghub = evt_hubmiles
     from #wrk_dateshub
    where stp_mfh_sequence = (select min(stp_mfh_sequence)
                                from #wrk_dateshub)
                                

select @dates_endhub= #wrk_dateshub.evt_hubmiles
  from #wrk_dateshub,eventcodetable
 where #wrk_dateshub.evt_eventcode = eventcodetable.abbr and
       eventcodetable.mile_typ_to_stop = 'LD' and
       #wrk_dateshub.stp_mfh_sequence = (select max(stp_mfh_sequence)
                                           from #wrk_dateshub)

if @@rowcount = 0
   select @dates_endhub = evt_hubmiles
     from #wrk_dateshub
    where stp_mfh_sequence = (select max(stp_mfh_sequence)
                                from #wrk_dateshub)

--**********************************************************************************************
--update the temp table with the driver1,driver2 and carrier for the primary event

update #dateshub set     begining_date = @begining_date,
                           ending_date = @ending_date,
                     begining_hubmiles = @dates_beghub,
                       ending_hubmiles = @dates_endhub,
                       lgh_number = @v_legnumber


SELECT *
 FROM #dateshub

GO
GRANT EXECUTE ON  [dbo].[d_hddwn_dateshub_sp] TO [public]
GO
