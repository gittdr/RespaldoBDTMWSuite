SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[d_stlmnt_stops_sp] (@stringparm varchar(13),
         @numberparm int,
         @retrieve_by varchar(8))
as


/* lor   pts3913  add volume and volumeunit to the stops table
   dpete PTS12599 add geographical location
   07/29/2002  Vern Jewett    PTS 14924   label=vmj1  Change stp_description from 30
                                          to 60 chars
   12/07/2002  Vern Jewett    PTS 15629   label=vmj2  Add a new @retrieve_by option,
                                          ORDHDR, to accommodate
                                          PayDetailCorrection window's
                                          handling of orders cross-docked
                                          to multiple moves.
   04/11/2003  Vern Jewett    PTS 17818   vmj3     Add event.evt_hubmiles to the result set.
   01/15/2007  EMK            PTS 35796            Added stp_ord_toll_cost to result set.
   08/09/2007  vjh            PTS 37595            Added stop othertype1/2 logic to event counts
   08/17/2007  vjh            PTS 37595            Added more permutation of event/OT1/OT2 to support rows/columns use
 * 11/07/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
   LOR   PTS# 40714  added stp_ord_mileage_stlrate, stp_lgh_mileage_stlrate
 * 10/20/2008 JSwindell       PTS 43875 -- lgh_type1 lgh_type2 lgh_type3 lgh_type4 (varchar6)
 * 03/18/2010  SPN            PTS 51036            Added order number revtype 3 and revtype 4
 * 10/26/2012  SPN            PTS 64373 -- CalculateLegMiles
 *
/**********************************************************************************************************************/
/* 3/31/2008 PTS 40259 ljb Pauls hauling integration which includes below                                  */
/*          9/14/04 DPETE 24631 add stp_lgh_mileage_mtid,stp_ord_mileage_mtid, evt_trailer1, evt_trailer2, and    */
/*          ord_trlconfiguration (the last 2 for recomputing stp_ord_mileage) to return set                   */
/**********************************************************************************************************************/

*/

declare @mov_number int,
   @lgh_number int,
   @ord_hdrnumber int,
   @invoice_count int,
   @ord_count int,
   @varchar50 varchar(50),
   @event_count int,
   @event varchar(6),
   @li_ctr int,
   @li_stp int,
   @i int,
   @ls_cmp varchar(8),
   @v_othertype1 varchar(6),
   @v_othertype2 varchar(6),
   @DistanceByTrlConfig char(1),/* 40259*/
   @seq int /* 40259*/

--BEGIN PTS 51036 SPN
declare @ls_ord_revtype3_label varchar(20),
        @ls_ord_revtype4_label varchar(20)
--END PTS 51036 SPN

--BEGIN PTS 64373 SPN
DECLARE @CalculateLegMiles CHAR(1)
--END PTS 64373 SPN

--BEGIN PTS 64373 SPN
SELECT @CalculateLegMiles = dbo.fn_GetSetting('CalculateLegMiles','C1')
--END PTS 64373 SPN

create table #distincteventcount (evt_code varchar(6) ,cmp_id varchar(8))
create table #eventcount(evt_id int identity  ,evt_code varchar(6), evt_count int ,lgh_number int)
create table #distincteventothertypescount (evt_code varchar(6) ,cmp_id varchar(8),stp_othertype1 varchar(6),stp_othertype2 varchar(6))
create table #eventothertypescount(evt_id int identity  ,evt_code varchar(6),stp_othertype1 varchar(6),stp_othertype2 varchar(6), evt_count int ,lgh_number int)
create table #distincteventothertype_count (evt_code varchar(6) ,cmp_id varchar(8),stp_othertype_ varchar(6))
create table #eventothertype_count(evt_id int identity  ,evt_code varchar(6),stp_othertype_ varchar(6), evt_count int ,lgh_number int)
create table #stopstempmov(   stp_event   varchar(6)  not null,
   cmp_id   varchar(8)  null,
   cmp_name varchar(30) null,
   cty_nmstct  varchar(25) null,
   stp_schdtearliest    datetime null,
   stp_schdtlatest   datetime null,
   stp_arrivaldate      datetime null,
   stp_departuredate datetime null,
   stp_count         int   null,
   stp_countunit     varchar(6) null,
   cmd_code       varchar(8) null,
   --vmj1+
   stp_description      varchar(60) null,
-- stp_description      varchar(30) null,
   --vmj1-
   stp_weight        float null,
   stp_reftype       varchar(6)  null,
   stp_refnum        varchar(30) null,
   stp_ord_mileage      int null,
   ord_hdrnumber     int null,
   stp_number        int null,
   stp_region1       varchar(6) null,
   stp_region2       varchar(6) null,
   stp_region3       varchar(6) null,
   stp_city       int null,
   stp_state         varchar(6) null,
   stp_origschdt     datetime   null,
   stp_reasonlate    varchar(6) null,
   lgh_number        int null,
   mfh_number        int null,
   stp_type       varchar(6) null,
   stp_paylegpt      char(1)    null,
   stp_sequence      int null ,
   stp_region4       varchar(6) null,
   stp_lgh_sequence  int null,
   stp_mfh_sequence  int null,
   stp_lgh_mileage      int null,
   stp_mfh_mileage      int null,
   mov_number        int null,
   stp_loadstatus    char(3) null,
   stp_weightunit    varchar(6) null,
   stp_status        varchar(6) null,
   evt_driver1       varchar(8) null,
   evt_driver2       varchar(8) null,
   evt_tractor       varchar(8) null,
   lgh_primary_trailer  varchar(13) null,
   evt_carrier       varchar(8) null,
   lgh_outstatus     varchar(6) null,
   cmd_count         int null,
   event_count       int null,
   ref_count         int null,
   sch_done          int null,
   sch_opn        int null,
   mile_typ_to_stop  varchar(6) null,
   mile_typ_from_stop   varchar(6) null,
   drv_pay_event     varchar(6) null,
   ect_payondepart      char(1) null,
   stp_reason1late_depart  varchar(6) null,
   stp_screenmode       varchar(6) null,
   lgh_primary_pup         varchar(13) null,
   stp_volume           float null,
   stp_volumeunit       varchar(6) null,
   stp_delayhours       float null,
   stp_ooa_mileage         float null,
   stp_OOA_stop         int   null,
   fgt_carryins1        float null,
   fgt_carryins2        float null,
   stp_type1            varchar(6) null,
   -- PTS 29302 -- BL (start)
-- stp_zipcode          varchar(9) null,
   stp_zipcode          varchar(10) null,
   -- PTS 29302 -- BL (end)
   ivd_distance         float null,
   stp_stl_mileage_flag char(1) null,
   cmp_geoloc           varchar(50) null,
   stp_event_count         int null,
   lgh_type1            varchar(6) null,
   mpp_type1            varchar(6) null,
   mpp_type2            varchar(6) null,
   mpp_type3            varchar(6) null,
   mpp_type4            varchar(6) null,
   mpp_team          char(1) null,
   --vmj3+
   evt_hubmiles         int      null,
   --vmj3-
   --PTS 35796 EMK
   stp_ord_toll_cost    money    null,
   --vjh 37595
   stp_othertype1       varchar(6) null,
   stp_othertype2       varchar(6) null,
   stp_event_othertypes_count int   null,
   stp_event_othertype1_count int   null,
   stp_event_othertype2_count int   null,
   stp_event_ot1        varchar(6) null,
   stp_event_ot2        varchar(6) null,
   stp_ord_mileage_stlrate int   null,
   stp_lgh_mileage_stlrate int   null,
   stp_lgh_mileage_mtid int NULL,         /* 40259 */
    ord_trlconfiguration varchar(6) NULL, /* 40259 */
    stp_ord_mileage_mtid int null,        /* 40259 */
   evt_trailer1 varchar(13) NULL,         /* 40259 */
    evt_trailer2 varchar(13) NULL,        /* 40259 */
   lgh_type2    varchar(6)  null,         -- PTS 43875
   lgh_type3    varchar(6)  null,         -- PTS 43875
   lgh_type4    varchar(6)  null,         -- PTS 43875
   cmd_class    varchar(8)  null, --44416 JD
   evt_chassis       varchar(13) null,
   evt_chassis2      varchar(13) null,
   evt_dolly         varchar(13) null,
   evt_dolly2        varchar(13) null,
   evt_trailer3      varchar(13) null,
   evt_trailer4      varchar(13) null,
   --BEGIN PTS 51036 SPN
   ord_revtype3_label   varchar(20) null,
   ord_revtype4_label   varchar(20) null
   --END PTS 51036 SPN
)

--BEGIN PTS 51036 SPN
select @ls_ord_revtype3_label = ( SELECT TOP 1 RevType3 FROM labelfile_headers)
select @ls_ord_revtype4_label = ( SELECT TOP 1 RevType4 FROM labelfile_headers)
if @ls_ord_revtype3_label IS NULL
   BEGIN
      set @ls_ord_revtype3_label = 'RevType3'
   END
if @ls_ord_revtype4_label IS NULL
   BEGIN
      set @ls_ord_revtype4_label = 'RevType4'
   END
--END PTS 51036 SPN


create table #move
      (mov_number int null)
/* 40259 Begin*/
Select @DistanceByTrlConfig = Left(Upper(gi_string1),1) From generalinfo Where gi_name = 'DistanceBasedOnTrlConfig'
Select @DistanceByTrlConfig = IsNull(@DistanceByTrlConfig,'N')
/* 40259 End*/

/* LOOK UP BY LGH NUMBER */
IF (@retrieve_by = 'LGHNUM')
BEGIN

   SELECT @mov_number = -1

   SELECT DISTINCT @mov_number = stops.mov_number
          FROM stops
         WHERE stops.lgh_number = @numberparm

   /* NUMBER PARM WILL REMAIN -1 IF ORDERNUMBER IS INVALID */
   IF (@numberparm = -1 )
             select @retrieve_by = 'NODATA'
   ELSE
   BEGIN
             select @retrieve_by = 'MOVE'
             select @numberparm = @mov_number
   END
END


--JD 12/28/99 PTS#6966 this now checks for combined orders as well
-- LOR 12/29/99 PTS#6703  this now checks for split trips that don't have to be invoiced when
--          other trip types do have to be invoiced
IF (@retrieve_by = 'MOVE')
BEGIN
   --vmj2+
   insert into #move
         (mov_number)
     values (@numberparm)
end

if @retrieve_by = 'ORDHDR'
begin
   insert into #move
         (mov_number)
     select distinct mov_number
     from   stops
     where  ord_hdrnumber = @numberparm
end
--vmj2-


Insert into #stopstempmov (
      stp_event ,
      cmp_id  ,
      cmp_name,
      cty_nmstct,
      stp_schdtearliest ,
      stp_schdtlatest ,
      stp_arrivaldate,
      stp_departuredate,
      stp_count,
      stp_countunit,
      cmd_code,
      stp_description,
      stp_weight,
      stp_reftype,
      stp_refnum,
      stp_ord_mileage,
      ord_hdrnumber,
      stp_number,
      stp_region1,
      stp_region2,
      stp_region3,
      stp_city,
      stp_state,
      stp_origschdt,
      stp_reasonlate,
      lgh_number,
      mfh_number,
      stp_type,
      stp_paylegpt,
      stp_sequence,
      stp_region4,
      stp_lgh_sequence,
      stp_mfh_sequence,
      stp_lgh_mileage,
      stp_mfh_mileage,
      mov_number ,
      stp_loadstatus,
      stp_weightunit,
      stp_status,
      evt_driver1,
      evt_driver2,
      evt_tractor,
      lgh_primary_trailer,
      evt_carrier,
      lgh_outstatus,
      cmd_count ,
      event_count,
      ref_count ,
      sch_done ,
      sch_opn ,
      mile_typ_to_stop,
      mile_typ_from_stop,
      drv_pay_event,
      ect_payondepart,
      stp_reason1late_depart,
      stp_screenmode,
      lgh_primary_pup,
      stp_volume,
      stp_volumeunit,
      stp_delayhours,
      stp_ooa_mileage,
      stp_OOA_stop,
      fgt_carryins1,
      fgt_carryins2,
      stp_type1,
      stp_zipcode,
      ivd_distance,
      stp_stl_mileage_flag,
      cmp_geoloc ,
      stp_event_count,
      lgh_type1,
      --vmj3+
      evt_hubmiles,
      --vmj3-
      -- PTS 35796
      stp_ord_toll_cost,
      stp_othertype1,   --vjh 37595
      stp_othertype2,   --vjh 37595
      stp_ord_mileage_stlrate,
      stp_lgh_mileage_stlrate,
        stp_lgh_mileage_mtid, /*40259*/
        ord_Trlconfiguration, /*40259*/
        stp_ord_mileage_mtid, /*40259*/
      evt_trailer1,       /*40259*/
        evt_trailer2,        /*40259*/
      lgh_type2,        -- pts 43875
      lgh_type3,        -- pts 43875
      lgh_type4,        -- pts 43875
      cmd_class,        --44416 JD
      evt_chassis,
      evt_chassis2,
      evt_dolly,
      evt_dolly2,
      evt_trailer3,
      evt_trailer4
)
(SELECT stops.stp_event,
      stops.cmp_id,
      stops.cmp_name,
      city.cty_nmstct,
      stops.stp_schdtearliest,
      stops.stp_schdtlatest,
      stops.stp_arrivaldate,
      stops.stp_departuredate,
      stops.stp_count,
      stops.stp_countunit,
      stops.cmd_code,
      stops.stp_description,
      stops.stp_weight,
      stops.stp_reftype,
      stops.stp_refnum,
      stops.stp_ord_mileage,
      stops.ord_hdrnumber,
      stops.stp_number,
      stops.stp_region1,
      stops.stp_region2,
      stops.stp_region3,
      stops.stp_city,
      stops.stp_state,
      stops.stp_origschdt,
      stops.stp_reasonlate,
      stops.lgh_number,
      stops.mfh_number,
      stops.stp_type,
      stops.stp_paylegpt,
      stops.stp_sequence,
      stops.stp_region4,
      stops.stp_lgh_sequence,
      stops.stp_mfh_sequence,
      (CASE WHEN @CalculateLegMiles = 'Y' THEN stops.stp_trip_mileage ELSE stops.stp_lgh_mileage END) AS stp_lgh_mileage,
      stops.stp_mfh_mileage,
      stops.mov_number,
      stops.stp_loadstatus,
      stops.stp_weightunit,
      stops.stp_status,
      event.evt_driver1,
      event.evt_driver2,
      evt_tractor = IsNull(event.evt_tractor,'UNKNOWN'),  /*40259*/
      legheader.lgh_primary_trailer,
      event.evt_carrier,
      legheader.lgh_outstatus ,
      0,
      1,
      0,
      0,
      0,
      eventcodetable.mile_typ_to_stop,
      eventcodetable.mile_typ_from_stop,
      eventcodetable.drv_pay_event,
      eventcodetable.ect_payondepart,
      stops.stp_reasonlate_depart,
      stops.stp_screenmode,
      legheader.lgh_primary_pup,
      stops.stp_volume,
      stops.stp_volumeunit,
      stops.stp_delayhours,
           stops.stp_ooa_mileage,
           stops.stp_OOA_stop,
           ISNULL((SELECT sum(fgt_carryins1)
                          FROM freightdetail
                         WHERE freightdetail.stp_number = stops.stp_number), 0),
           ISNULL((SELECT sum(fgt_carryins2)
                          FROM freightdetail
                         WHERE freightdetail.stp_number = stops.stp_number), 0),
           stops.stp_type1,
           stops.stp_zipcode,
      0,
      stops.stp_stl_mileage_flag,
      cmp_geoloc = @varchar50,
      stp_event_count= @event_count,
      legheader.lgh_type1,
      --vmj3+
      evt_hubmiles,
      --vmj3-
      --PTS 35796
      IsNuLl(stops.stp_ord_toll_cost,0),
      --PTS 35796
      cmp_othertype1,   --vjh 37595
      cmp_othertype2,   --vjh 37595
      stp_ord_mileage_stlrate,
      stp_lgh_mileage_stlrate,
      stp_lgh_mileage_mtid -- = IsNull(stp_lgh_mileage_mtid,0)
      ,ord_trlconfiguration =       /*40259*/
      Case @DistanceByTrlConfig     /*40259*/
          When 'N' Then 'UNK'          /*40259*/
          Else Case stops.ord_hdrnumber   /*40259*/
          When 0 Then 'UNK'            /*40259*/
           Else (Select IsNull(ord_trlconfiguration,'UNK') From orderheader o2 where o2.ord_hdrnumber = stops.ord_hdrnumber) /*40259*/
           End    /*40259*/
      End   ,    /*40259*/
      stp_ord_mileage_mtid --= IsNull(stops.stp_ord_mileage_mtid,0), /*40259*/
      , evt_trailer1 = IsNull(event.evt_trailer1,'UNKNOWN'),         /*40259*/
       evt_trailer2 = IsNull(event.evt_trailer2,'UNKNOWN')        /*40259*/
      ,legheader.lgh_type2       -- pts 43875
      ,legheader.lgh_type3       -- pts 43875
       ,legheader.lgh_type4         -- pts 43875
      ,null       -- 44416 JD
      ,evt_chassis
      ,evt_chassis2
      ,evt_dolly
      ,evt_dolly2
      ,evt_trailer3
      ,evt_trailer4
--  FROM    stops,
--    --vmj2+
--    #move m,
--    --vmj2-
--    city,
--    event,
--    legheader,
--    eventcodetable
--  WHERE ( stops.stp_event *= eventcodetable.abbr) and
--    ( stops.stp_city = city.cty_code ) and
--    ( event.stp_number = stops.stp_number ) and
--    ( stops.lgh_number *= legheader.lgh_number ) and
--    --vmj2+
--    (stops.mov_number = m.mov_number AND
----     (( stops.mov_number = @numberparm ) AND
--    --vmj2-
--    ( event.evt_sequence = 1 )) )
  FROM   stops
      join company on stops.cmp_id = company.cmp_id
      join #move m on stops.mov_number = m.mov_number
      join city on stops.stp_city = city.cty_code
      join event on event.stp_number = stops.stp_number
      left join legheader on stops.lgh_number = legheader.lgh_number
      left join eventcodetable on stops.stp_event = eventcodetable.abbr
  WHERE event.evt_sequence = 1 )

if (select count(*) from #stopstempmov ) > 0
BEGIN

   update #stopstempmov set cmd_class = commodity.cmd_class from commodity where #stopstempmov.cmd_code = commodity.cmd_code -- 44416 JD



   update   #stopstempmov
   set #stopstempmov.ivd_distance = (select sum(invoicedetail.ivd_distance)
      from  invoicedetail
      where    #stopstempmov.stp_number = invoicedetail.stp_number and  --pts40186 jguo removed the left outer join from the corelated query
                                       invoicedetail.ivd_unit = 'MIL' and
                                       invoicedetail.ivh_hdrnumber = (select max(ivh_hdrnumber) from
                                       invoicedetail ivd where ivd.stp_number = invoicedetail.stp_number))

   update #stopstempmov
   set #stopstempmov.cmd_count =( SELECT COUNT(*)
      FROM freightdetail
      WHERE freightdetail.stp_number = #stopstempmov.stp_number)
   update #stopstempmov
   set     #stopstempmov.event_count = (SELECT COUNT(*)
      FROM event
      WHERE event.stp_number = #stopstempmov.stp_number
      )
   update #stopstempmov
   set     #stopstempmov.ref_count = (SELECT COUNT(*)
      FROM referencenumber r
      WHERE r.ref_table = 'stops' AND r.ref_tablekey = #stopstempmov.stp_number
         )
   update #stopstempmov
   set     #stopstempmov.sch_done = (SELECT COUNT(*)
   FROM event e
   WHERE e.evt_eventcode = 'SAP' AND
         e.evt_status = 'DNE' AND
         e.stp_number = #stopstempmov.stp_number
      )
   update #stopstempmov
   set     #stopstempmov.sch_opn = (SELECT COUNT(*)
   FROM event ev
   WHERE ev.evt_eventcode = 'SAP' AND
         ev.evt_status = 'OPN' and
         ev.stp_number = #stopstempmov.stp_number
   /*    pts 4655 Dsk 11/19/98
   *  use lgh_sequence (unused column) to indicate
   *  how many legheaders there are for the move
   */                            )
   update #stopstempmov
   set #stopstempmov.stp_lgh_sequence = (SELECT COUNT(*)
                  FROM  legheader
                  WHERE legheader.mov_number = @numberparm )

   update #stopstempmov
   set #stopstempmov.cmp_geoloc = (SELECT ISNULL(cmp_geoloc,'')
                  FROM  company
                  WHERE company.cmp_id = #stopstempmov.cmp_id )


      --16809 put in the driver tractor trailer information on a cancelled trip.

      If exists(select * from generalinfo where gi_name = 'SettleCancelledTrips' and gi_string1 = 'Y')
      Begin
            if exists (select * from orderheader where mov_number  = @numberparm and ord_status in ('CAN','ICO'))
            begin
               -- PTS 26088 - Added Carrier
               update #stopstempmov
               set evt_driver1 = lgh_driver1,
                  evt_driver2 = lgh_driver2,
                  evt_tractor = lgh_tractor,
                  lgh_primary_trailer = lgh_trailer,
                  evt_carrier = car_id
               from  cancelledtripresources
               where #stopstempmov.ord_hdrnumber = cancelledtripresources.ord_hdrnumber

            end
      end

END


insert into #eventcount select stp_event, count(*),lgh_number  from #stopstempmov group by stp_event,lgh_number

select @li_ctr = 0

while 1 = 1
begin
   select @li_ctr = min(evt_id) from #eventcount where evt_id > @li_ctr
   if @li_ctr is null
      break
   select @event = evt_code from #eventcount where evt_id = @li_ctr
   set rowcount 1
   update   #stopstempmov set stp_event_count = evt_count from #eventcount
   where    stp_event = #eventcount.evt_code and
         stp_event = @event and
         #stopstempmov.lgh_number = #eventcount.lgh_number and
         evt_id = @li_ctr
   set rowcount 0
end

--17150 JD ignore duplicate events at the same location if the geninfo setting is set
select @li_stp = 0
if exists (select * from generalinfo where gi_name = 'StlIgnoreDuplicateEvents' and substring(gi_string1,1,1) ='Y')
begin
      while 1 = 1
      begin
         Select @li_stp = min(stp_number) from #stopstempmov where stp_event_count > 1 and stp_number > @li_stp
         If @li_stp is null
               break
         select @li_ctr = stp_event_count,@ls_cmp =cmp_id  ,@event = stp_event ,@lgh_number = lgh_number  from #stopstempmov where stp_number = @li_stp
--       select @i = count(*) from #stopstempmov where stp_number <> @li_stp  and stp_event = @event and cmp_id = @ls_cmp
            delete #distincteventcount
            insert into #distincteventcount select distinct stp_event,cmp_id from #stopstempmov where stp_event = @event and lgh_number = @lgh_number
            select @i = count(*) from #distincteventcount
         If @i <> @li_ctr
         begin
            update #stopstempmov set stp_event_count = @i where stp_number = @li_stp
         end

      end

end
-- end 17150 JD


/*********************************************************************/
/* PH Integration 40259 Begin                                */
/*********************************************************************/

-- 24064 DSK Paul's Hauling.  Count LLD and LUL events as they are clustered together.
-- LLD/LUL/LLD/LUL counts as two of each
-- LLD/LLD/LUL/LUL counts as one of each
IF (SELECT gi_string1 FROM generalinfo WHERE gi_name = 'ClusterLLD/LUL') = 'Y'
BEGIN
   UPDATE #stopstempmov
   SET stp_event_count = 0 WHERE stp_event in ('LLD', 'LUL')
   select @seq = 0, @li_ctr = 0, @li_stp = 0
   while 1=1
   begin
   select @seq = min(stp_mfh_sequence) from #stopstempmov where stp_mfh_sequence > @seq and stp_event = 'LLD'
      if @seq is null
         break
      SET @li_ctr = @li_ctr + 1
      IF @li_stp = 0
         SELECT @li_stp = stp_number FROM #stopstempmov WHERE stp_mfh_sequence = @seq
      select @seq = min(stp_mfh_sequence) from #stopstempmov where stp_mfh_sequence > @seq and stp_event = 'LUL'
      if @seq is null
         break
   end
   update #stopstempmov set stp_event_count = @li_ctr where stp_number = @li_stp

   select @seq = 0, @li_ctr = 0, @li_stp = 0
   while 1=1
   begin
   select @seq = min(stp_mfh_sequence) from #stopstempmov where stp_mfh_sequence > @seq and stp_event = 'LUL'
      if @seq is null
         break
      SET @li_ctr = @li_ctr + 1
      IF @li_stp = 0
         SELECT @li_stp = stp_number FROM #stopstempmov WHERE stp_mfh_sequence = @seq
      select @seq = min(stp_mfh_sequence) from #stopstempmov where stp_mfh_sequence > @seq and stp_event = 'LLD'
      if @seq is null
         break
   end
   update #stopstempmov set stp_event_count = @li_ctr where stp_number = @li_stp
END
-- end 24064
/*********************************************************************/
/* PH Integration 40259 End                                  */
/*********************************************************************/


--vmj2+
--end if
--vmj2-

--vjh 37595 - this is the construct for Event, Othertype1 AND Othertype2 (othertypeS - the construct for just a single OT will have an underscore)
insert into #eventothertypescount
select stp_event, #stopstempmov.stp_othertype1, #stopstempmov.stp_othertype2, count(*),lgh_number
from #stopstempmov
group by stp_event, #stopstempmov.stp_othertype1, #stopstempmov.stp_othertype2, lgh_number

select @li_ctr = 0

while 1 = 1
begin
   select @li_ctr = min(evt_id) from #eventothertypescount where evt_id > @li_ctr
   if @li_ctr is null
      break
   select @event = evt_code from #eventothertypescount where evt_id = @li_ctr
   set rowcount 1
   update   #stopstempmov set stp_event_othertypes_count = evt_count from #eventothertypescount
   where    stp_event = #eventothertypescount.evt_code and
         #stopstempmov.stp_othertype1 = #eventothertypescount.stp_othertype1 and
         #stopstempmov.stp_othertype2 = #eventothertypescount.stp_othertype2 and
         stp_event = @event and
         #stopstempmov.lgh_number = #eventothertypescount.lgh_number and
         evt_id = @li_ctr
   set rowcount 0
end

--this is the construct for Event and just Othertype1 (othertype_ which will also be used for event and OT2)
insert into #eventothertype_count
select stp_event, #stopstempmov.stp_othertype1, count(*),lgh_number
from #stopstempmov
group by stp_event, #stopstempmov.stp_othertype1, lgh_number

select @li_ctr = 0

while 1 = 1
begin
   select @li_ctr = min(evt_id) from #eventothertype_count where evt_id > @li_ctr
   if @li_ctr is null
      break
   select @event = evt_code from #eventothertype_count where evt_id = @li_ctr
   set rowcount 1
   update   #stopstempmov set stp_event_othertype1_count = evt_count, stp_event_ot1 = stp_event from #eventothertype_count
   where    stp_event = #eventothertype_count.evt_code and
         #stopstempmov.stp_othertype1 = #eventothertype_count.stp_othertype_ and
         stp_event = @event and
         #stopstempmov.lgh_number = #eventothertype_count.lgh_number and
         evt_id = @li_ctr
   set rowcount 0
end


--this is the construct for Event and just Othertype2 (othertype_ which was also used for event and OT1)
insert into #eventothertype_count
select stp_event, #stopstempmov.stp_othertype2, count(*),lgh_number
from #stopstempmov
group by stp_event, #stopstempmov.stp_othertype2, lgh_number

select @li_ctr = 0

while 1 = 1
begin
   select @li_ctr = min(evt_id) from #eventothertype_count where evt_id > @li_ctr
   if @li_ctr is null
      break
   select @event = evt_code from #eventothertype_count where evt_id = @li_ctr
   set rowcount 1
   update   #stopstempmov set stp_event_othertype2_count = evt_count, stp_event_ot2 = stp_event from #eventothertype_count
   where    stp_event = #eventothertype_count.evt_code and
         #stopstempmov.stp_othertype2 = #eventothertype_count.stp_othertype_ and
         stp_event = @event and
         #stopstempmov.lgh_number = #eventothertype_count.lgh_number and
         evt_id = @li_ctr
   set rowcount 0
end



--17150 JD ignore duplicate events at the same location if the geninfo setting is set
select @li_stp = 0
if exists (select * from generalinfo where gi_name = 'StlIgnoreDuplicateEvents' and substring(gi_string1,1,1) ='Y')
begin
      while 1 = 1
      begin
         Select @li_stp = min(stp_number) from #stopstempmov where stp_event_count > 1 and stp_number > @li_stp
         If @li_stp is null
               break
         select   @li_ctr = stp_event_count,
               @ls_cmp =cmp_id  ,
               @event = stp_event ,
               @lgh_number = lgh_number,
               @v_othertype1 = stp_othertype1,
               @v_othertype2 = stp_othertype2
         from #stopstempmov where stp_number = @li_stp
--       select @i = count(*) from #stopstempmov where stp_number <> @li_stp  and stp_event = @event and cmp_id = @ls_cmp
            delete #distincteventothertypescount
            insert into #distincteventothertypescount
               select distinct stp_event,cmp_id, stp_othertype1, stp_othertype2
               from #stopstempmov
               where stp_event = @event
               and stp_othertype1 = @v_othertype1
               and stp_othertype2 = @v_othertype2
               and lgh_number = @lgh_number
            select @i = count(*) from #distincteventothertypescount
         If @i <> @li_ctr
         begin
            update #stopstempmov set stp_event_othertypes_count = @i where stp_number = @li_stp
         end

      end

end
--end 37595

--BEGIN PTS 51036 SPN Added order number revtype 3 and revtype 4
--Select
--    stp_event ,
--    cmp_id  ,
--    cmp_name,
--    cty_nmstct,
--    stp_schdtearliest ,
--    stp_schdtlatest ,
--    stp_arrivaldate,
--    stp_departuredate,
--    stp_count,
--    stp_countunit,
--    cmd_code,
--    stp_description,
--    stp_weight,
--    stp_reftype,
--    stp_refnum,
--    stp_ord_mileage,
--    ord_hdrnumber,
--    stp_number,
--    stp_region1,
--    stp_region2,
--    stp_region3,
--    stp_city,
--    stp_state,
--    stp_origschdt,
--    stp_reasonlate,
--    lgh_number,
--    mfh_number,
--    stp_type,
--    stp_paylegpt,
--    stp_sequence,
--    stp_region4,
--    stp_lgh_sequence,
--    stp_mfh_sequence,
--    stp_lgh_mileage,
--    stp_mfh_mileage,
--    mov_number ,
--    stp_loadstatus,
--    stp_weightunit,
--    stp_status,
--    evt_driver1,
--    evt_driver2,
--    evt_tractor,
--    lgh_primary_trailer,
--    evt_carrier,
--    lgh_outstatus,
--    cmd_count ,
--    event_count,
--    ref_count ,
--    sch_done ,
--    sch_opn ,
--    mile_typ_to_stop,
--    mile_typ_from_stop,
--    drv_pay_event,
--    ect_payondepart,
--    stp_reason1late_depart,
--       stp_screenmode,
--    lgh_primary_pup,
--    stp_volume,
--    stp_volumeunit,
--    stp_delayhours,
--    stp_ooa_mileage,
--    stp_OOA_stop,
--    fgt_carryins1,
--    fgt_carryins2,
--    stp_type1,
--    stp_zipcode,
--    ivd_distance,
--    stp_stl_mileage_flag,
--    cmp_geoloc ,
--    stp_event_count,
--    lgh_type1,
--    --vmj3+
--    evt_hubmiles,
--    0 as net_hubmiles,
--    --vmj3-
--    --PTS 35796
--    stp_ord_toll_cost,
--    stp_event_othertypes_count,
--    stp_othertype1,
--    stp_othertype2,
--    stp_event_othertype1_count,
--    stp_event_othertype2_count,
--    stp_event_ot1,
--    stp_event_ot2,
--    stp_ord_mileage_stlrate,
--    stp_lgh_mileage_stlrate,
--    stp_lgh_mileage_mtid,                              /*40259*/
--    ord_trlconfiguration = IsNull(ord_trlconfiguration,'UNK'),  /*40259*/
--    stp_ord_mileage_mtid,                              /*40259*/
--    evt_trailer1,                                   /*40259*/
--    evt_trailer2                                    /*40259*/
--    ,lgh_type2        -- pts 43875
--    ,lgh_type3        -- pts 43875
--       ,lgh_type4        -- pts 43875
--    ,cmd_class,       -- 44416 JD
--    evt_chassis,
--    evt_chassis2,
--    evt_dolly,
--    evt_dolly2,
--    evt_trailer3,
--    evt_trailer4
--From   #stopstempmov

UPDATE #stopstempmov
   SET ord_revtype3_label = @ls_ord_revtype3_label
     , ord_revtype4_label = @ls_ord_revtype4_label

SELECT stm.stp_event
     , stm.cmp_id
     , stm.cmp_name
     , stm.cty_nmstct
     , stm.stp_schdtearliest
     , stm.stp_schdtlatest
     , stm.stp_arrivaldate
     , stm.stp_departuredate
     , stm.stp_count
     , stm.stp_countunit
     , stm.cmd_code
     , stm.stp_description
     , stm.stp_weight
     , stm.stp_reftype
     , stm.stp_refnum
     , stm.stp_ord_mileage
     , stm.ord_hdrnumber
     , stm.stp_number
     , stm.stp_region1
     , stm.stp_region2
     , stm.stp_region3
     , stm.stp_city
     , stm.stp_state
     , stm.stp_origschdt
     , stm.stp_reasonlate
     , stm.lgh_number
     , stm.mfh_number
     , stm.stp_type
     , stm.stp_paylegpt
     , stm.stp_sequence
     , stm.stp_region4
     , stm.stp_lgh_sequence
     , stm.stp_mfh_sequence
     , stm.stp_lgh_mileage
     , stm.stp_mfh_mileage
     , stm.mov_number
     , stm.stp_loadstatus
     , stm.stp_weightunit
     , stm.stp_status
     , stm.evt_driver1
     , stm.evt_driver2
     , stm.evt_tractor
     , stm.lgh_primary_trailer
     , stm.evt_carrier
     , stm.lgh_outstatus
     , stm.cmd_count
     , stm.event_count
     , stm.ref_count
     , stm.sch_done
     , stm.sch_opn
     , stm.mile_typ_to_stop
     , stm.mile_typ_from_stop
     , stm.drv_pay_event
     , stm.ect_payondepart
     , stm.stp_reason1late_depart
     , stm.stp_screenmode
     , stm.lgh_primary_pup
     , stm.stp_volume
     , stm.stp_volumeunit
     , stm.stp_delayhours
     , stm.stp_ooa_mileage
     , stm.stp_OOA_stop
     , stm.fgt_carryins1
     , stm.fgt_carryins2
     , stm.stp_type1
     , stm.stp_zipcode
     , stm.ivd_distance
     , stm.stp_stl_mileage_flag
     , stm.cmp_geoloc
     , stm.stp_event_count
     , stm.lgh_type1
     , stm.evt_hubmiles
     , 0 as net_hubmiles
     , stm.stp_ord_toll_cost
     , stm.stp_event_othertypes_count
     , stm.stp_othertype1
     , stm.stp_othertype2
     , stm.stp_event_othertype1_count
     , stm.stp_event_othertype2_count
     , stm.stp_event_ot1
     , stm.stp_event_ot2
     , stm.stp_ord_mileage_stlrate
     , stm.stp_lgh_mileage_stlrate
     , stm.stp_lgh_mileage_mtid
     , ord_trlconfiguration = IsNull(stm.ord_trlconfiguration,'UNK')
     , stm.stp_ord_mileage_mtid
     , stm.evt_trailer1
     , stm.evt_trailer2
     , stm.lgh_type2
     , stm.lgh_type3
     , stm.lgh_type4
     , stm.cmd_class
     , stm.evt_chassis
     , stm.evt_chassis2
     , stm.evt_dolly
     , stm.evt_dolly2
     , stm.evt_trailer3
     , stm.evt_trailer4
     , oh.ord_number
     , oh.ord_revtype3
     , oh.ord_revtype4
     , stm.ord_revtype3_label
     , stm.ord_revtype4_label
     ,IsNull(company.cmp_address1, '')'cmp_address1'
     ,IsNull(company.cmp_address2, '')'cmp_address2'
     ,IsNull(company.cmp_address3, '')'cmp_address3'
  FROM #stopstempmov stm LEFT OUTER JOIN orderheader oh ON stm.ord_hdrnumber = oh.ord_hdrnumber
         LEFT Outer Join company on stm.cmp_id = company.cmp_id
--END PTS 51036 SPN Added order number revtype 3 and revtype 4
--PTS58265: d_stlmnt_stops_sp:  Add company join + cmp_addr1-2-3.
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_stops_sp] TO [public]
GO
