SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE    PROCEDURE [dbo].[d_drvdelticket_format06_sp]
	@revtype1 	VARCHAR(6),
	@drv		VARCHAR(8), 
	@status 	VARCHAR(15),
	@startdate	DATETIME,
	@enddate	DATETIME,
	@rpttitle	VARCHAR(50),
	@box1title	VARCHAR(25),
	@box1line1	VARCHAR(25),
	@box1line2	VARCHAR(25),
	@box2title	VARCHAR(25),
	@box2line1	VARCHAR(25),
	@box2line2	VARCHAR(25),
	@box3title	VARCHAR(25),
	@box3line1	VARCHAR(25),
	@box3line2	VARCHAR(25),
	@box4title	VARCHAR(25),
	@box4line1	VARCHAR(25),
	@box4line2	VARCHAR(25),
	@box5title	VARCHAR(25)
AS
SET NOCOUNT ON
/**
 * 
 * NAME:
 * dbo.d_drvdelticket_format06_sp 
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
 * 001 - @reprintflag varchar(10), input, null;
 *       This parameter indicates whether or not we will be doing a reprint or not. 
 *     
 * 002 - @mbnumber int, input, null;
 *       This parameter indicates our master bill number used.
 *
 * 003 - @billto varchar(8), input, null;
 *       This parameter  indicates the bill to to be filtered.
 *
 * 004 - @revtype1 varchar(6), input, null;
 *       This parameter indicates the revtype1 that will be filtered in the where clause.
 *
 * 005 - @revtype2 varchar(6), varchar(18), input, null;
 *       This parameter indicates the revtype2 that will be filtered in the where clause.
 *
 * 006 - @mbstatus varchar(6), input, null;
 *       This parameter indicates the master bill status that was entered in the datawindow.
 *
 * 007 - @shipstart datetime, varchar(18), input, null;
 *       This parameter indicates the ship start date entered in the datawindow.
 *
 * 008 - @shipend datetime, input, null;
 *       This parameter indicates the ship end date entered in the datawindow.
 *
 * 009 - @billdate datetime, input, null;
 *       This parameter indicates the bill date entered in the datawindow.  This will be
 *       used in the where clause.
 *
 * 010 - @shipper varchar(8), input, null;
 *       This parameter indicates the id of the shipper to be filtered.
 *
 * 011 - @consignee varchar(8), input, null;
 *       This parameter indicates the consignee to be filtered
 *
 * 012 - @copy int, input, null;
 *       This parameter indicates the number of copies to be printed.
 *
 * 013 - @ivh_invoicenumber varchar(12), input, null;
 *       This parameter indicates the invoice number to be selected.
 * 
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 09/26/2006 PTS 32801 - Imari Bremer - New format Driver delivery Ticket format 06
 * 10/27/06 PTS32614 custoomer wants sheets printed by driver , mfh_number for menu option
 * BDH 3/10/08 PTS 40395.  Multiple changes.
 * BDH 42621.  Changed final order by and returning loaded trip miles not overall order miles.
	Change was made by Jeff Graham on site and approved by the customer on 4/30/08. 
 **/


DECLARE @varchar2000 VARCHAR(2000),
  @not_number  INTEGER,
  @driver   VARCHAR(90),
  @ord_number  VARCHAR(12),
  @not_text  VARCHAR(254),
  @loading_instr VARCHAR(2000),
  @delivery_instr VARCHAR(2000),
  @tank_sizes  VARCHAR(2000),
  @drv_id         VARCHAR(8),
  @bill_to        VARCHAR(8),
  @directions     Varchar(2000),
  @cmp_directions Varchar(2000),
  @rack_id        varchar(8),
  @consignee_id   varchar(8),
                @MinOrd  int,
  @MinStp  int,
  @MinFgt  int,
  @v_cntr  int,
  @v_cmd  varchar(8),
  @v_qty  int
--PTS# 32164 ILB
CREATE TABLE #temp_ord (
ord_hdrnumber int null
,evt_driver1 varchar(8) null
,lgh_number int null)
CREATE TABLE #lgh (
  lgh_driver1     VARCHAR(8)      NULL, 
  lgh_mfh_number  INT             NULL, 
  lgh_startdate   DATETIME        NULL,
  ord_hdrnumber   INT             NULL,
  lgh_number      INT             NULL)
--PTS# 32164 ILB
CREATE TABLE #trips (
 header    VARCHAR(40)  NOT NULL,
 corp_address1  VARCHAR(30)  NOT NULL,
 corp_ctstzip  VARCHAR(30)  NOT NULL,
 remit_address1  VARCHAR(30)  NOT NULL,
 remit_ctstzip  VARCHAR(30)  NOT NULL,
 disp1    VARCHAR(30)  NOT NULL,
 disp1_phone   VARCHAR(30)  NOT NULL,
 disp1_fax   VARCHAR(30)  NOT NULL,
 disp2    VARCHAR(30)  NOT NULL,
 disp2_phone   VARCHAR(30)  NOT NULL,
 disp2_fax   VARCHAR(30)  NOT NULL,
 dispatch_date  DATETIME  NOT NULL,
 ord_number   VARCHAR(12)  NOT NULL,
 release_pickup  VARCHAR(30)  NULL,
 supplier   VARCHAR(20)  NULL,
 ord_refnum   VARCHAR(30)  NULL,
 tractor    VARCHAR(8)  NULL,
 trailer    VARCHAR(13)  NULL,
 driver    VARCHAR(90)  NULL,
 bill_to    VARCHAR(8)  NULL,
 rack_name   VARCHAR(100) NULL,
 rack_address1  VARCHAR(50)  NULL,
 rack_ctstzip  VARCHAR(40)  NULL,
 rack_address2   VARCHAR(50)  NULL,
 consignee_name  VARCHAR(100) NULL,
 consignee_address1 VARCHAR(50)  NULL,
 consignee_ctstzip VARCHAR(40)  NULL,
 consignee_address2  VARCHAR(50)  NULL,
 product1   VARCHAR(60)  NULL,
 quantity1   INTEGER   NULL,
 product2   VARCHAR(60)  NULL,
 quantity2   INTEGER   NULL,
 product3   VARCHAR(60)  NULL,
 quantity3   INTEGER   NULL,
 product4   VARCHAR(60)  NULL,
 quantity4   INTEGER   NULL,
 product5   VARCHAR(60)  NULL,
 quantity5   INTEGER   NULL,
 delivery_date  datetime NULL,
 loading_instr  VARCHAR(2000) NULL,
 delivery_instr  VARCHAR(2000) NULL,
 tank_sizes   VARCHAR(2000)  NULL,
 ord_heading   VARCHAR(30)  NOT NULL,
 ord_revtype1            VARCHAR(6) NULL ,
 ord_revtype_name        varchar(20)     null ,
 ord_startdate           datetime        null ,
 cmp_directions          VARCHAR(2000)   NULL,
 drv_id                  VARCHAR(8)      NULL,
 box1title  VARCHAR(25)     NULL,
 box2title  VARChAR(25)     NULL,
 ord_hdrnumber           INT  NULL,
        lgh_driver1             VARCHAR(8)      NULL, 
        lgh_mfh_number          INT             NULL, 
        lgh_startdate           DATETIME        NULL,
        lgh_number              INT             NULL,
        billto_cmpname          VARCHAR(100)    NULL,
        rack_id                 varchar(8)      NULL,
        consignee_id  varchar(8)      NULL,
        telephone_num           varchar(20)     NULL,
        load_account            varchar(20)     NULL,
        load_account_no  varchar(50)     NULL,
stp_number int null,  -- 40395
ord_totalmiles int null,  -- 40395
stp_sequence int null, -- 40395
stp_schdtearliest datetime null, -- 40395
stp_schdtlatest datetime null -- 40395
)
--JYANG create a temp table to hold the ord_hdrnumber based on event and stop.
--so could handle split trips
/*
Insert into   #temp_ord
select distinct event.ord_hdrnumber,evt_driver1,lgh_number
from   event
join stops on event.stp_number = stops.stp_number
where  @drv in ('UNKNOWN',  event.evt_driver1) and
 evt_startdate  >= @startdate AND
 evt_enddate <= @enddate and
 event.ord_hdrnumber <> 0 
group by event.ord_hdrnumber,evt_driver1,lgh_number
*/
 

Insert into   #temp_ord
select distinct stops.ord_hdrnumber,lgh_driver1,stops.lgh_number
from   legheader_active
join stops on legheader_active.lgh_number = stops.lgh_number 
join event on stops.stp_number = event.stp_number  -- 40395
where  legheader_active.lgh_number in (
  select lgh_number from assetassignment
  where asgn_type = 'DRV' 
  and @drv in ('UNKNOWN',  asgn_id) and
  asgn_date  >= @startdate AND
  asgn_enddate <= @enddate ) 
and stops.ord_hdrnumber <> 0
and event.evt_pu_dr = 'DRP'  -- 40395
 
SELECT @status = ',' + LTRIM(RTRIM(ISNULL(@status, ''))) + ','
INSERT INTO #trips
 SELECT @rpttitle header,
   @box1line1 corp_address1,
   @box1line2 corp_ctstzip,
   @box2line1 remit_address1,
   @box2line2 remit_ctstzip,
   @box3title disp1,
   @box3line1 disp1_phone,
   @box3line2 disp1_fax,
   @box4title disp2,
   @box4line1 disp2_phone,
   @box4line2 disp2_fax,
   oh.ord_startdate dispatch_date,
   oh.ord_number ord_number,
   (SELECT MIN(ref_number)
      FROM referencenumber
     WHERE ref_tablekey = oh.ord_hdrnumber AND
     ref_type = 'REL' AND
     ref_table = 'orderheader') realease_pickup,
   lab1.name supplier,
   isnull(oh.ord_refnum,'') ord_refnum,
   --(SELECT MIN(ref_number)
   --   FROM referencenumber
   --  WHERE ref_tablekey = oh.ord_hdrnumber AND
   --  ref_type = 'BL#' AND
   --  ref_table = 'orderheader') shipper_bl,
   oh.ord_tractor tractor,
   oh.ord_trailer trailer,
   mpp.mpp_lastname + ', ' + mpp.mpp_firstname + ' ' + mpp.mpp_middlename driver,
   oh.ord_billto bill_to,
   rack.cmp_name rack_name,
   rack.cmp_address1 rack_address1,
   rackcity.cty_name + ', ' + rackcity.cty_state + ' ' + rackcity.cty_zip rack_ctstzip,
   rack.cmp_address2 rack_adress2,
   '',--consignee.cmp_name consignee_name,
   '',--consignee.cmp_address1 consignee_address1,
   '',--consigneecity.cty_name + ', ' + consigneecity.cty_state + ' ' + consigneecity.cty_zip consignee_ctstzip,
   '',--consignee.cmp_address2 consignee_adress2,
   
--jyang client required to return cmd_code instead of cmd_name and request return quantity which is not only from the fgt_quantity
 -- BDH 40395 start
   (SELECT f.cmd_code
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 1),
   (SELECT quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
     case when fgt_volume >0 then fgt_volume else
     case when fgt_weight > 0 then fgt_weight else
     case when fgt_count >0 then fgt_count else 0 end end end end)
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 1),
   (SELECT f.cmd_code
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 2),
   (SELECT quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
     case when fgt_volume >0 then fgt_volume else
        case when fgt_weight > 0 then fgt_weight else
     case when fgt_count >0 then fgt_count else 0 end end end end)
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 2),
   (SELECT f.cmd_code
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 3),
   (SELECT quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
     case when fgt_volume >0 then fgt_volume else
        case when fgt_weight > 0 then fgt_weight else
     case when fgt_count >0 then fgt_count else 0 end end end end)
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 3),
   (SELECT f.cmd_code
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 4),
   (SELECT quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
     case when fgt_volume >0 then fgt_volume else
         case when fgt_weight > 0 then fgt_weight else
     case when fgt_count >0 then fgt_count else 0 end end end end)
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 4),
   (SELECT f.cmd_code
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 5),
   (SELECT quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
     case when fgt_volume >0 then fgt_volume else
        case when fgt_weight > 0 then fgt_weight else
     case when fgt_count >0 then fgt_count else 0 end end end end)
    FROM freightdetail f
    where f.stp_number = stops.stp_number and fgt_sequence = 5),
  -- 40395 end
   --oh.ord_remark delivery_date,
   oh.ord_completiondate delivery_date,
   oh.ord_remark loading_instr, -- 40395  @varchar2000 loading_instr,
   @varchar2000 delivery_instr,
   @varchar2000 tank_sizes,
   @box5title ord_heading,
   oh.ord_revtype1,
   lab2.name,
   oh.ord_startdate,
   --consignee.cmp_directions,
   '',
   #temp_ord.evt_driver1,
   @box1title,
   @box2title,
   oh.ord_hdrnumber,
                        '' lgh_driver1, 
          0  lgh_mfh_number, 
          '' lgh_startdate ,
               #temp_ord.lgh_number, --32164   0  lgh_number,
   billto.cmp_name,
                        oh.ord_shipper,
   stops.cmp_id,-- 40395 oh.ord_consignee,
                        '', --telephone number,
                        '',  --Load Account,
                        oh.ord_pin, --Load Account number
stops.stp_number, -- 40395
--oh.ord_totalmiles, -- 40395
stops.stp_lgh_mileage as ord_totalmiles,
--jdg 5/1/2008 per rg/hd/jk SR 42621-- pull loaded trip miles not overall order miles 
-- slot them into the exisitng mileage field for the report
stops.stp_sequence,  -- 40395           
stops.stp_schdtearliest,  -- 40395
stops.stp_schdtlatest   -- 40395        
   FROM orderheader oh,
   company rack,
   company consignee,
   company billto,
   city rackcity,
   city consigneecity,
   labelfile lab1,
   labelfile lab2,
   manpowerprofile mpp,
   #temp_ord
,stops  -- 40395
,event -- 40395
  WHERE         oh.ord_shipper = rack.cmp_id AND
   oh.ord_consignee = consignee.cmp_id AND
   oh.ord_billto = billto.cmp_id AND
   rack.cmp_city = rackcity.cty_code AND
   consignee.cmp_city = consigneecity.cty_code AND
   lab1.abbr = oh.ord_revtype4 AND
   lab1.labeldefinition = 'revtype4' AND
   mpp.mpp_id =  #temp_ord.evt_driver1 AND
   CHARINDEX(',' + oh.ord_status + ',', @status) > 0 AND
 -- loosing splits and Xdock (@drv = 'UNKNOWN' OR ord_driver1 = @drv) AND
   @revtype1 in( 'UNK' ,oh.ord_revtype1) AND
 --  ord_startdate >= @startdate AND
 --  ord_startdate <= @enddate AND
   lab2.abbr = oh.ord_revtype1 AND
   lab2.labeldefinition = 'revtype1' and
   #temp_ord.ord_hdrnumber = oh.ord_hdrnumber 
and stops.ord_hdrnumber = oh.ord_hdrnumber  -- 40395
and stops.stp_type = 'DRP' -- 04395
and event.evt_pu_dr = 'DRP' -- 04395
and stops.stp_number = event.stp_number -- 40395

-- 40395 start
update #trips
set consignee_name = c.cmp_name,
consignee_address1 = c.cmp_address1,
consignee_ctstzip = city.cty_name + ', ' + city.cty_state + ' ' + c.cmp_zip,
consignee_address2 = c.cmp_address2
from company c , city 
where c.cmp_id = #trips.consignee_id
and c.cmp_city = city.cty_code
-- 40395 end

CREATE INDEX order_ind ON #trips (ord_number)
DECLARE trip_cursor CURSOR FOR 
SELECT ord_number,drv_id,bill_to, rack_id, consignee_id
  FROM #trips 
OPEN trip_cursor
FETCH NEXT FROM trip_cursor INTO @ord_number,@drv_id,@bill_to, @rack_id, @consignee_id
WHILE @@FETCH_STATUS = 0
BEGIN
 SELECT @not_text = ''
 --SELECT @loading_instr = '' --40395
 SELECT @delivery_instr = ''
 SELECT @tank_sizes = ''
 SELECT @cmp_directions = ''
--jyang original not_type 'loadpin' is not valid. abbr in labelfile is only char(6)
--       select @loading_instr = cmp_misc1 + ' '+ cmp_misc2  -- 40395
--         from company
--        where cmp_id = @rack_id 
       /* 
       DECLARE notes1_cursor CURSOR FOR 
 SELECT not_text
         FROM  notes 
  WHERE not_type IN ('COMB', 'LI') AND
  ntb_table = 'orderheader' AND
  nre_tablekey = @ord_number
       ORDER BY not_type, not_sequence
 OPEN notes1_cursor
 FETCH NEXT FROM notes1_cursor INTO @not_text
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @loading_instr = @loading_instr + @not_text + '  '
  FETCH NEXT FROM notes1_cursor INTO @not_text
 END
 CLOSE notes1_cursor
 DEALLOCATE notes1_cursor
 DECLARE notes4_cursor CURSOR FOR 
  SELECT not_text
        FROM  notes,stops,orderheader 
  WHERE not_type IN ('COMB', 'LI') AND
  ntb_table = 'company' AND
  (nre_tablekey = stops.cmp_id or nre_tablekey = @bill_to) and
  stops.ord_hdrnumber = orderheader.ord_hdrnumber and
         orderheader.ord_number = @ord_number
 ORDER BY not_type, not_sequence
 OPEN notes4_cursor
 FETCH NEXT FROM notes4_cursor INTO @not_text
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @loading_instr = @loading_instr + @not_text + '  '
  FETCH NEXT FROM notes4_cursor INTO @not_text
 END
 CLOSE notes4_cursor
 DEALLOCATE notes4_cursor
        */
    
       select @delivery_instr = cmp_misc1 + ' '+ cmp_misc2
         from company
        where cmp_id = @consignee_id 
 /*
 DECLARE notes2_cursor CURSOR FOR 
 SELECT not_text
        FROM  notes
  WHERE not_type = 'DI' AND
  ntb_table = 'orderheader' AND
  nre_tablekey = @ord_number
 ORDER BY not_sequence
 OPEN notes2_cursor
 FETCH NEXT FROM notes2_cursor INTO @not_text
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @delivery_instr = @delivery_instr + @not_text + '  '
  FETCH NEXT FROM notes2_cursor INTO @not_text
 END
 CLOSE notes2_cursor
 DEALLOCATE notes2_cursor
 DECLARE notes5_cursor CURSOR FOR 
  SELECT not_text
        FROM  notes,stops,orderheader 
  WHERE not_type = 'DI' AND
  ntb_table = 'company' AND
  (nre_tablekey = stops.cmp_id or nre_tablekey = @bill_to) and
  stops.ord_hdrnumber = orderheader.ord_hdrnumber and
         orderheader.ord_number = @ord_number
 ORDER BY not_type, not_sequence
 OPEN notes5_cursor
 FETCH NEXT FROM notes5_cursor INTO @not_text
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @delivery_instr = @delivery_instr + @not_text + '  '
  FETCH NEXT FROM notes5_cursor INTO @not_text
 END
 CLOSE notes5_cursor
 DEALLOCATE notes5_cursor
 */
 DECLARE notes3_cursor CURSOR FOR 
 SELECT not_text
        FROM  notes
  WHERE not_type = 'TANKSZ' AND
   ntb_table = 'orderheader' AND
   nre_tablekey = @ord_number
 ORDER BY not_sequence
 OPEN notes3_cursor
 FETCH NEXT FROM notes3_cursor INTO @not_text
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @tank_sizes = @tank_sizes + @not_text + '  '
  FETCH NEXT FROM notes3_cursor INTO @not_text
 END
 CLOSE notes3_cursor
 DEALLOCATE notes3_cursor
 DECLARE notes6_cursor CURSOR FOR 
  SELECT not_text
        FROM  notes,stops,orderheader 
  WHERE not_type = 'TANKSZ' AND
  ntb_table = 'company' AND
  (nre_tablekey = stops.cmp_id or nre_tablekey = @bill_to) and
  stops.ord_hdrnumber = orderheader.ord_hdrnumber and
         orderheader.ord_number = @ord_number
 ORDER BY not_type, not_sequence
 OPEN notes6_cursor
 FETCH NEXT FROM notes6_cursor INTO @not_text
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @tank_sizes = @tank_sizes + @not_text + '  '
  FETCH NEXT FROM notes6_cursor INTO @not_text
 END
 CLOSE notes6_cursor
 DEALLOCATE notes6_cursor
 DECLARE cmp_direction_cursor CURSOR FOR 
  SELECT cmp_directions
        FROM  company,stops,orderheader
  WHERE stops.ord_hdrnumber = orderheader.ord_hdrnumber and
         orderheader.ord_number = @ord_number and
  stp_type = 'DRP' and
  stops.cmp_id = company.cmp_id
 ORDER BY stp_sequence
 OPEN cmp_direction_cursor
 FETCH NEXT FROM cmp_direction_cursor INTO @directions
 WHILE @@FETCH_STATUS = 0
 BEGIN
  SELECT @cmp_directions = @cmp_directions + @directions + '  '
  FETCH NEXT FROM cmp_direction_cursor INTO @directions
 END
 CLOSE cmp_direction_cursor
 DEALLOCATE cmp_direction_cursor
 UPDATE #trips
 SET tank_sizes = @tank_sizes,
  cmp_directions = @cmp_directions
  WHERE ord_number = @ord_number and
  drv_id = @drv_id
-- UPDATE #trips --40395
--    SET loading_instr = @loading_instr  
--  WHERE ord_number = @ord_number and
--  rack_id = @rack_id
 UPDATE #trips
    SET delivery_instr = @delivery_instr
  WHERE ord_number = @ord_number and
  consignee_id = @consignee_id
 FETCH NEXT FROM trip_cursor INTO @ord_number,@drv_id,@bill_to,@rack_id,@consignee_id
END
CLOSE trip_cursor
DEALLOCATE trip_cursor
--PTS# 32164 ILB 06/02/2006
/*
INSERT INTO #lgh
    SELECT lgh.lgh_driver1,
           isnull(lgh.mfh_number,9999),
           lgh.lgh_startdate,
           lgh.ord_hdrnumber,
           min(lgh.lgh_number)
      FROM #trips, legheader_active lgh
     WHERE #trips.ord_hdrnumber = lgh.ord_hdrnumber and
           #trips.drv_id = lgh.lgh_driver1 
          -- and (lgh.lgh_outstatus = 'PLN' OR lgh.lgh_outstatus = 'DSP')
 group by  lgh.lgh_driver1,lgh.mfh_number,lgh.lgh_startdate,lgh.ord_hdrnumber
order by lgh.lgh_driver1, isnull(lgh.mfh_number,9999),lgh.lgh_startdate
*/
update #trips
   set #trips.lgh_driver1    = lgh.lgh_driver1, --#lgh.lgh_driver1, 
       #trips.lgh_mfh_number = lgh.mfh_number, --#lgh.lgh_mfh_number, 
       #trips.lgh_startdate  = lgh.lgh_startdate, --#lgh.lgh_startdate,
       #trips.lgh_number     = lgh.lgh_number --#lgh.lgh_number
  from #trips --, #lgh
  join legheader_active lgh on #trips.lgh_number = lgh.lgh_number
-- where #trips.ord_hdrnumber = #lgh.ord_hdrnumber and
--       #trips.drv_id = #lgh.lgh_driver1
--PTS# 32164 ILB 06/02/2006
Select @MinOrd = 0
select @MinStp = 0
select @MinFgt = 0
select @v_cntr = 0
select @v_cmd  = ''
select @v_qty  = 0
WHILE (SELECT COUNT(*) 
  FROM #trips 
        WHERE ord_hdrnumber > @MinOrd) > 0
 BEGIN    
  select @MinOrd = min(ord_hdrnumber)
                  from #trips
                 where ord_hdrnumber > @MinOrd
  --print 'Order Loop '+ cast(@minord as varchar(20))
  Update #trips
     set #trips.telephone_num = label_extrastring1
    from labelfile, Orderheader 
   where labeldefinition = 'revtype1'
     and #trips.ord_hdrnumber = @MinOrd
     and Orderheader.ord_revtype1 = abbr
     and Orderheader.ord_hdrnumber = #trips.ord_hdrnumber
-- 40395 start
--execute dbo.d_drvdelticket_format06_sp   @revtype1 = 'UNK', @drv = 'UNKNOWN', @status = 'PLN,DSP', @startdate = {ts '2008-03-06 00:00:00.000'}, 
--@enddate = {ts '2008-03-12 23:59:00.000'}, @rpttitle = 'report title', @box1title = 'box1 title', @box1line1 = 'box1 line1', @box1line2 = 'box1 line2', 
--@box2title = 'box2 title', @box2line1 = 'box2 line1', @box2line2 = 'box2 line2', @box3title = 'box3 title', @box3line1 = 'box3 line1', 
--@box3line2 = 'box3 line2', @box4title = 'box4 title', @box4line1 = 'box4 line1', @box4line2 = '', @box5title = 'box5 title'
-- 40395 start
 Update #trips
 set ord_totalmiles = 0
 where ord_number = @MinOrd
 and stp_sequence <> (select max(stp_sequence) from #trips
      where ord_number = @minord)
-- 40395 end
  
  --select @loadacct =  name  
  --  from orderheader, labelfile 
  -- where ord_hdrnumber = @MinOrd and
  --       ord_accounttype = abbr and
   --      labeldefinition = 'LoadAccount'
  --print @loadacct
  Update #trips
     set #trips.load_account = name
    from labelfile, Orderheader 
   where labeldefinition = 'LoadAccount'
     and #trips.ord_hdrnumber = @MinOrd
     and Orderheader.ord_accounttype = abbr
     and Orderheader.ord_hdrnumber = #trips.ord_hdrnumber
-- 40395 start commenting
--   WHILE (Select count(*)
--     from stops
--    where ord_hdrnumber = @MinOrd and
--                               stp_number > @MinStp and
--                               stp_type = 'DRP') > 0
--     BEGIN
--   select @MinStp = min(stp_number)
--                     from stops
--                   where ord_hdrnumber = @MinOrd
--                           and stp_number > @MinStp
--                           and stp_type = 'DRP'
--
--   --print 'Stops Loop' + cast(@MinStp as varchar(20))
--
--    WHILE (Select count(*)
--     from Freightdetail
--    where stp_number = @MinStp and
--                               fgt_number > @MinFgt) > 0
--
--      Begin
--    Select @MinFgt = min(fgt_number)
--                           from freightdetail
--                          where stp_number = @MinStp
--                                   and fgt_number > @MinFgt
--
--    --print 'Freight Loop' + cast(@MinFgt as varchar(20))
--
--    Select @v_cntr = @v_cntr + 1
--
--    SELECT @v_cmd = fd.cmd_code
--      FROM freightdetail fd
--     WHERE fd.fgt_number = @MinFgt
-- 
--    SELECT @v_qty = (case when fd.fgt_volume >0 then fd.fgt_volume else
--              case when fd.fgt_weight > 0 then fd.fgt_weight else
--       case when fd.fgt_count >0 then fd.fgt_count else 0 end end end)
--      FROM freightdetail fd
--     where fd.fgt_number = @MinFgt     
--    
--    --Print 'Commodity & Qty'
--    --print @v_cmd
--    --print cast(@v_qty as varchar(20))
--    --print cast(@v_cntr as varchar(20))   
-- 
--    IF @v_cntr = 1
--        Begin
--     Update #trips
--        set product1 = @v_cmd,
--                                        quantity1 = @v_qty
--      where ord_hdrnumber = @MinOrd
--        End 
-- 
--    IF @v_cntr = 2
--       Begin
--     Update #trips
--        set product2 = @v_cmd,
--                                        quantity2 = @v_qty
--      where ord_hdrnumber = @MinOrd
--       End 
--    
-- 
--    IF @v_cntr = 3
--       Begin
--     Update #trips
--        set product3 = @v_cmd,
--                                        quantity3 = @v_qty
--      where ord_hdrnumber = @MinOrd
--       End
-- 
--    IF @v_cntr = 4
--       Begin
--     Update #trips
--        set product4 = @v_cmd,
--                                        quantity4 = @v_qty
--      where ord_hdrnumber = @MinOrd
--    
--       End
--    IF @v_cntr = 5
--       Begin
--     Update #trips
--        set product5 = @v_cmd,
--                                        quantity5 = @v_qty
--      where ord_hdrnumber = @MinOrd
--       End  
--   End --Freight Loop   
--   END --Stops Loop
--  Set @MinStp = 0 
--  Set @MinFgt = 0 
--  Set @v_cntr = 0
 END -- Order Loop
-- 40395 end commenting
SELECT 
header ,
 corp_address1,
 corp_ctstzip,
 remit_address1,
 remit_ctstzip,
 disp1,
 disp1_phone ,
 disp1_fax,
 disp2,
 disp2_phone ,
 disp2_fax,
 dispatch_date,
 ord_number,
 release_pickup,
 supplier,
 ord_refnum,
 tractor,
 trailer,
 driver,
 bill_to,
 rack_name,
 rack_address1,
 rack_ctstzip,
 rack_address2,
 consignee_name,
 consignee_address1,
 consignee_ctstzip,
 consignee_address2,
 product1,
 quantity1,
 product2,
 quantity2,
 product3,
 quantity3,
 product4,
 quantity4,
 product5,
 quantity5,
 delivery_date,
 loading_instr,
 delivery_instr,
 tank_sizes,
 ord_heading,
 ord_revtype1,
 ord_revtype_name,
 ord_startdate,
 cmp_directions,
 drv_id ,
 box1title,
 box2title,
 ord_hdrnumber,
        lgh_driver1, 
        lgh_mfh_number , 
        lgh_startdate,
        lgh_number ,
        billto_cmpname,
        rack_id ,
        consignee_id,
        telephone_num ,
        load_account,
        load_account_no
,stp_number  -- 40395
, ord_totalmiles  -- 40395
,stp_sequence  -- 40395
,stp_schdtearliest  -- 40395
,stp_schdtlatest  -- 40395
FROM #trips --ORDER BY lgh_number,tractor,driver,ord_startdate
--jdg 4/29/08 SR 42621 -- change sort order
ORDER BY ord_revtype1, driver, lgh_mfh_number
DROP TABLE #trips
DROP TABLE #lgh
DROP TABLE #temp_ord
GO
GRANT EXECUTE ON  [dbo].[d_drvdelticket_format06_sp] TO [public]
GO
