SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[AdjustStpOrdDatesForDST]
 @P_copytype char(1), @p_OrigCopyKey int , @p_NewCopyKey int

AS
/**
 * 
 * NAME:
 * dbo.AdjustStpOrdDatesForDST
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Called by clone order and possible others if the GI Local Time Option is set to adjust the dates 
 *   on a copied trip (@p_NewCopyKey) from the original;@p_OrigCopyKey.  It maintains the travel time
 *   between stops if the trip goes from a location that does not observ DST to a location that does
 *   or vice versa.  

 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_copyType char(1)    -- "O" for order, "M" for move
 * 002 - @p_OrigCopyKey  int      -- ord_hdrnumber or lgh_number ot mov_number
 * 003 - @p_NewCopyKey  int    -- ord_hdrnumber or lgh_number or mov_number of copy
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 3/20/07 DPETE PTS35747 DPETE  - Created stored proc for SR requireing all copied trips to be adjusted for the time zone.
 *    Assumes the orignal trip dates and times are in local time.  Assumes city table has flags for DSTApplies set (default Y)
 *    Assumes this proc is only valid for US, Canada cities (otherwise need adjustment to the arguments to the IsDST proc calls)
 *
 **/


create table #OrigStops (stp_number int null
,stp_mfh_sequence int null
,stp_arrivaldate datetime null
,stp_dateisDST char(1) null
,cty_DSTApplies char(1) null
, EarliestIsGenesis char(1)
, LatestIsGenesis char(1)
,EtaIsGenesis char(1)
, EtdIsGenesis char(1)
, OrigIsGenesis char(1)
,stp_ident int identity(1,1) primary key clustered)  /* or mfh_sequence??? */

create table #NewStops (stp_number int null
,ord_hdrnumber int null
,lgh_number int null
,stp_mfh_sequence int null
,stp_arrivaldate datetime null
,stp_dateisDST char(1) null
,stp_departuredate datetime null
,stp_schdtearliest datetime null
,stp_schdtlatest datetime null
,stp_eta datetime null
,stp_etd datetime null
,stp_origschdt datetime null
,stp_type varchar(6) null
,stp_ident int identity(1,1) primary key clustered)  /* or mfh_sequence??? - not reliable per RE*/




declare  @v_nextStp int, @v_nextOrd int,@v_nextStart datetime,@v_nextComplete datetime,@v_ret smallint

Select @v_nextOrd = 0,@v_ret = 0

/* local time option not set */ 
if not exists (select 1 from generalinfo where gi_name = 'LocalTimeOption' and gi_string1 = 'LOCAL')
    goto EXIT_POINT


/* Get information from the stops of the copied order or trip */

If @p_copytype = 'O'
BEGIN
  insert into #OrigStops(stp_number 
  ,stp_mfh_sequence 
  ,stp_arrivaldate
  ,stp_dateisDST
  ,cty_DSTApplies 
  , EarliestIsGenesis
  , LatestIsGenesis 
  ,EtaIsGenesis 
  , EtdIsGenesis 
  , OrigIsGenesis)
  Select stp_number
  ,stp_mfh_sequence
  ,stp_arrivaldate , dbo.inDST(stp_arrivaldate,0)
  ,cty_DSTApplies = isnull(cty_DSTApplies,'Y')  -- assume if arival date is in DST, all dates on stop are in DST
  ,EarliestIsGenesis = Case isnull(stp_schdtearliest,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,LatestIsGenesis = Case isnull(stp_schdtlatest,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,EtaIsGenesis = Case isnull(stp_eta,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,EtdIsGenesis = Case isnull(stp_etd,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,OrigIsGenesis = Case isnull(stp_origschdt,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  from stops
  left outer join city on stops.stp_city = city.cty_code
  Where ord_hdrnumber = @p_OrigCopyKey
  order by stp_mfh_sequence,stp_arrivaldate

END



If @p_copytype = 'M'
BEGIN
  insert into #OrigStops (stp_number 
  ,stp_mfh_sequence 
  ,stp_arrivaldate
  ,stp_dateisDST
  ,cty_DSTApplies 
  , EarliestIsGenesis
  , LatestIsGenesis 
  ,EtaIsGenesis 
  , EtdIsGenesis 
  , OrigIsGenesis)
  Select stp_number
  ,stp_mfh_sequence
  ,stp_arrivaldate , dbo.inDST(stp_arrivaldate,0)
  ,cty_DSTApplies = isnull(cty_DSTApplies,'Y')
  ,EarliestIsGenesis = Case isnull(stp_schdtearliest,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,LatestIsGenesis = Case isnull(stp_schdtlatest,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,EtaIsGenesis = Case isnull(stp_eta,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,EtdIsGenesis = Case isnull(stp_etd,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  ,OrigIsGenesis = Case isnull(stp_origschdt,'19500101') when '19500101' then 'Y' when '20491231 23:59' then 'Y' else 'N' end
  from stops
  left outer join city on stops.stp_city = city.cty_code
  Where mov_number = @p_OrigCopyKey
  order by stp_mfh_sequence,stp_arrivaldate


END

 If not exists (select 1 from #OrigStops where cty_DSTApplies = 'Y')
     GOTO EXIT_POINT  -- if none of the locations on the stops does not observe DST no ajustment necessary
 If not exists(select 1 from #origStops where cty_DSTApplies = 'N')
     GOTO EXIT_POINT  -- if all stops on the trip do not observe DST no adjustment is necessary
 
-- Process  copy

    /*   Retrieve the dates from the copied order or move (one copy at a time) */
   If @p_copytype = 'O'
   BEGIN
   --truncate table #NewStops
   insert into #NewStops (stp_number 
   ,ord_hdrnumber 
   ,lgh_number 
   ,stp_mfh_sequence
   ,stp_arrivaldate
   ,stp_dateisDST
   ,stp_departuredate 
   ,stp_schdtearliest 
   ,stp_schdtlatest 
   ,stp_eta 
   ,stp_etd 
   ,stp_origschdt
   ,stp_type)
   select stp_number
   ,ord_hdrnumber
   ,lgh_number
   ,stp_mfh_sequence
   ,stp_arrivaldate ,dbo.inDST(stp_arrivaldate,0)
   ,stp_departuredate
   ,stp_schdtearliest
   ,stp_schdtlatest
   ,stp_eta
   ,stp_etd
   ,stp_origschdt
   ,stp_type
   from stops
   where ord_hdrnumber = @p_NewCopyKey
   order by stp_mfh_sequence,stp_arrivaldate

  END


  If @p_copytype = 'M'
  BEGIN
    truncate table #NewStops

    insert into #NewStops (stp_number 
    ,ord_hdrnumber 
    ,lgh_number 
    ,stp_mfh_sequence
    ,stp_arrivaldate
    ,stp_dateisDST
    ,stp_departuredate 
    ,stp_schdtearliest 
    ,stp_schdtlatest 
    ,stp_eta 
    ,stp_etd 
    ,stp_origschdt
    ,stp_type)
    select stp_number
    ,ord_hdrnumber
    ,lgh_number
    ,stp_mfh_sequence
    ,stp_arrivaldate , dbo.inDST(stp_arrivaldate,0)
    ,stp_departuredate
    ,stp_schdtearliest
    ,stp_schdtlatest
    ,stp_eta
    ,stp_etd
    ,stp_origschdt
    ,stp_type
    from stops
    where mov_number = @p_NewCopyKey
    order by stp_mfh_sequence,stp_arrivaldate
  END


--select '##ORIGIN',* from #origstops
--select '##BEFORE',* from #NewStops

  /* if all dates are within or without the DST period on orignal and copy, no conversion necessary */
  If not exists (select 1 from #OrigStops where stp_dateisDST = 'Y') 
     and  not exists (select 1 from #NewStops where stp_dateisDST = 'Y') 
   begin
    GOTO EXIT_POINT  -- no dates on this copy need adjustment (2)
   end
  If not exists (select 1 from #OrigStops where stp_dateisDST = 'N') 
     and not exists (select 1 from #NewStops where stp_dateisDST = 'N')
    GOTO EXIT_POINT  -- no dates on this copy need adjustment (2)
 

/* rules for trip starting at a location that obsrves DST */
If exists (select 1 from #OrigStops where  #Origstops.cty_DSTApplies = 'Y'  and stp_ident = 1)
 BEGIN

   /*  Convert dates where necessary */
    update #NewStops
      set stp_arrivaldate = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST + #Origstops.cty_DSTApplies 
                  WHEN 'YNN' then dateadd(hh,1,#NewStops.stp_arrivaldate)  --NYN
                  WHEN 'NYN' then dateadd(hh,-1,#NewStops.stp_arrivaldate)
                  ELSE #NewStops.stp_arrivaldate END,
          stp_departuredate = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST+ #Origstops.cty_DSTApplies
                  WHEN 'YNN' then dateadd(hh,1,#NewStops.stp_departuredate)
                  WHEN 'NYN' then dateadd(hh,-1,#NewStops.stp_departuredate)
                  ELSE #NewStops.stp_departuredate END,
          stp_schdtearliest  = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST  + #Origstops.cty_DSTApplies + #origStops.EarliestIsGenesis
                  WHEN 'YNNN' then dateadd(hh,1,#NewStops.stp_schdtearliest )
                  WHEN 'NYNN' then dateadd(hh,-1,#NewStops.stp_schdtearliest )
                  ELSE #NewStops.stp_schdtearliest END,
          stp_schdtlatest  = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST   + #Origstops.cty_DSTApplies + #origStops.LatestIsGenesis
                  WHEN 'YNNN' then dateadd(hh,1,#NewStops.stp_schdtlatest)
                  WHEN 'NYNN' then dateadd(hh,-1,#NewStops.stp_schdtlatest)
                  ELSE #NewStops.stp_schdtlatest END,
          stp_eta = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST    + #Origstops.cty_DSTApplies + #origStops.EtaIsGenesis
                  WHEN 'YNNN' then dateadd(hh,1,#NewStops.stp_eta)
                  WHEN 'NYNN' then dateadd(hh,-1,#NewStops.stp_eta)
                  ELSE #NewStops.stp_eta END,
          stp_etd = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST   + #Origstops.cty_DSTApplies  + #origStops.EtdIsGenesis
                  WHEN 'YNNN' then dateadd(hh,1,#NewStops.stp_etd)
                  WHEN 'NYNN' then dateadd(hh,-1,#NewStops.stp_etd)
                  ELSE #NewStops.stp_etd END,
          stp_origschdt = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST + #Origstops.cty_DSTApplies + #origStops.OrigIsGenesis 
                  WHEN 'YNNN' then dateadd(hh,1,#NewStops.stp_origschdt)
                  WHEN 'NYNN' then dateadd(hh,-1,#NewStops.stp_origschdt)
                  ELSE stp_origschdt END
      From #OrigStops
      Where #NewStops.stp_ident = #OrigStops.stp_ident

  END
/* rules for trip starting at a location that does not observe DST */
If exists (select 1 from #OrigStops where  #Origstops.cty_DSTApplies = 'N'  and stp_ident = 1)
  BEGIN
    
   /*  Convert dates where necessary */
    update #NewStops
      set stp_arrivaldate = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST + #Origstops.cty_DSTApplies 
                  WHEN 'YNY' then dateadd(hh,-1,#NewStops.stp_arrivaldate)
                  WHEN 'NYY' then dateadd(hh,1,#NewStops.stp_arrivaldate)
                  ELSE #NewStops.stp_arrivaldate END,
          stp_departuredate = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST+ #Origstops.cty_DSTApplies
                  WHEN 'YNY' then dateadd(hh,-1,#NewStops.stp_departuredate)
                  WHEN 'NYY' then dateadd(hh,1,#NewStops.stp_departuredate)
                  ELSE #NewStops.stp_departuredate END,
          stp_schdtearliest  = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST  + #Origstops.cty_DSTApplies + #origStops.EarliestIsGenesis
                  WHEN 'YNYN' then dateadd(hh,-1,#NewStops.stp_schdtearliest )
                  WHEN 'NYYN' then dateadd(hh,1,#NewStops.stp_schdtearliest )
                  ELSE #NewStops.stp_schdtearliest END,
          stp_schdtlatest  = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST   + #Origstops.cty_DSTApplies + #origStops.LatestIsGenesis
                  WHEN 'YNYN' then dateadd(hh,-1,#NewStops.stp_schdtlatest)
                  WHEN 'NYYN' then dateadd(hh,1,#NewStops.stp_schdtlatest)
                  ELSE #NewStops.stp_schdtlatest END,
          stp_eta = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST    + #Origstops.cty_DSTApplies + #origStops.EtaIsGenesis
                  WHEN 'YNYN' then dateadd(hh,-1,#NewStops.stp_eta)
                  WHEN 'NYYN' then dateadd(hh,1,#NewStops.stp_eta)
                  ELSE #NewStops.stp_eta END,
          stp_etd = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST   + #Origstops.cty_DSTApplies  + #origStops.EtdIsGenesis
                  WHEN 'YNYN' then dateadd(hh,-1,#NewStops.stp_etd)
                  WHEN 'NYYN' then dateadd(hh,1,#NewStops.stp_etd)
                  ELSE #NewStops.stp_etd END,
          stp_origschdt = case #Origstops.stp_dateisDST + #NewStops.stp_dateisDST + #Origstops.cty_DSTApplies + #origStops.OrigIsGenesis 
                  WHEN 'YNYN' then dateadd(hh,-1,#NewStops.stp_origschdt)
                  WHEN 'NYYN' then dateadd(hh,1,#NewStops.stp_origschdt)
                  ELSE stp_origschdt END
      From #OrigStops
      Where #NewStops.stp_ident = #OrigStops.stp_ident
  END
--select '##AFTER',* from #NewStops


      Select @v_nextStp = min(stp_number) from #NewStops
      while @v_nextStp > 0
        BEGIN   -- stop/event update loop
          update stops
            set stp_arrivaldate = #NewStops.stp_arrivaldate
            ,stp_departuredate = #NewStops.stp_departuredate
            ,stp_schdtearliest = #NewStops.stp_schdtearliest
            ,stp_schdtlatest = #NewStops.stp_schdtlatest
            ,stp_eta = #NewStops.stp_eta
            ,stp_etd = #NewStops.stp_etd
            ,stp_origschdt = #NewStops.stp_origschdt
            ,skip_trigger = 1
            From #NewStops
            where #NewStops.stp_number = @v_nextStp
            and stops.stp_number = #NewStops.stp_number
            AND (stops.stp_arrivaldate <> #NewStops.stp_arrivaldate
              or stops.stp_departuredate <> #NewStops.stp_departuredate
              or isnull(stops.stp_schdtearliest,'19500101') <> isnull(#NewStops.stp_schdtearliest,'19500101')
              or isnull(stops.stp_schdtlatest,'19500101') <> isnull(#NewStops.stp_schdtlatest,'19500101')
              or isnull(stops.stp_eta,'19500101') <> isnull(#NewStops.stp_eta,'19500101')
              or isnull(stops.stp_etd,'19500101') <> isnull(#NewStops.stp_etd,'19500101')
              or isnull(stops.stp_origschdt,'19500101') <> isnull(#NewStops.stp_origschdt,'19500101') )

            update event
            set evt_startdate = #NewStops.stp_arrivaldate
            ,evt_enddate = #NewStops.stp_departuredate
            ,evt_earlydate = #NewStops.stp_schdtearliest
            ,evt_latedate = #NewStops.stp_schdtlatest
            From #NewStops
            where #NewStops.stp_number = @v_nextStp
            and event.stp_number = #NewStops.stp_number
            AND evt_sequence = 1
            AND (evt_startdate <> #NewStops.stp_arrivaldate
              or evt_enddate <> #NewStops.stp_departuredate
              or isnull(evt_earlydate,'19500101') <> isnull(#NewStops.stp_schdtearliest,'19500101')
              or isnull(evt_latedate,'19500101') <> isnull(#NewStops.stp_schdtlatest,'19500101') )

            select @v_nextStp = min(stp_number) from #NewStops where #NewStops.stp_number > @v_nextStp
         END  -- stop/event update loop

      select @v_nextOrd = min( ord_hdrnumber) from #NewStops where ord_hdrnumber > @v_nextord

      /* adjust orderheader dates if necessary */
      While @v_nextord is not null and @v_nextord > 0
        BEGIN  -- order update loop
          select @v_nextStart = min(stp_arrivaldate) from #NewStops where #NewStops.ord_hdrnumber = @v_nextOrd and stp_type = 'PUP'
          select @v_nextComplete = max(stp_arrivaldate) from #NewStops where #NewStops.ord_hdrnumber = @v_nextOrd and stp_type = 'DRP'

          update orderheader
          set ord_startdate = @v_nextStart
              ,ord_completiondate = @v_nextComplete
          where ord_hdrnumber = @v_nextOrd and 
              (ord_startdate <> @v_nextStart or ord_completiondate = @v_nextComplete)

           select @v_nextOrd = min( ord_hdrnumber) from #NewStops where ord_hdrnumber > @v_nextord
        END  -- order update loop 

EXIT_POINT:
drop table #OrigStops
drop table #NewStops
 

GO
GRANT EXECUTE ON  [dbo].[AdjustStpOrdDatesForDST] TO [public]
GO
