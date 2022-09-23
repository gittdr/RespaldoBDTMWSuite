SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [dbo].[d_drvdelticket_format05_sp]
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

/**
 * 
 * NAME:
 * dbo.d_drvdelticket_format05_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Allows delivery ticket information to be printed.
 *
 * RETURNS:
 * A return value of zero indicates success. A non-zero return 
 * value
 * indicates a failure of some type
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 -	@revtype1 	VARCHAR(6),
 * 002 -	@drv		VARCHAR(8), 
 * 003 -	@status 	VARCHAR(15),
 * 004 -	@startdate	DATETIME,
 * 005 -	@enddate	DATETIME,
 * 006 -	@rpttitle	VARCHAR(50),
 * 007 -	@box1title	VARCHAR(25),
 * 008 -	@box1line1	VARCHAR(25),
 * 009 -	@box1line2	VARCHAR(25),
 * 010 -	@box2title	VARCHAR(25),
 * 011 -	@box2line1	VARCHAR(25),
 * 012 -	@box2line2	VARCHAR(25),
 * 013 -	@box3title	VARCHAR(25),
 * 014 -	@box3line1	VARCHAR(25),
 * 015 -	@box3line2	VARCHAR(25),
 * 016 -	@box4title	VARCHAR(25),
 * 017 -	@box4line1	VARCHAR(25),
 * 018 -	@box4line2	VARCHAR(25),
 * 019 -	@box5title	VARCHAR(25)
 *
 * REFERENCES: NONE
 *
 * 
 * REVISION HISTORY:
 * 11/3/2006.01 - PTS35095 - Phil Bidinger - History:
 *
 *  --ILB 03/23/2006 NOTE: this is a copy from format02 
 *  --The cursors created were already in place, time was not given to make the necessary changes
 *  --to use the current cursor format of TMW.
 *  --ILB
 *
 * 11/3/2006.02 ? PTS35095 - Phil Bidinger ? Created this description block, and brought up to
 *                                         - current coding standards.
 * 11/3/2006.03 - PTS35095 - Phil Bidinger - Fixed field widths.  Added # to refnumbers.
 * 11/30/2006.04 - PTS33271 - Phil Bidinger (for BL) - Altered for field size.
 * 12/7/06 PTs35028 DPETE - if lgh_mfh_number is null make 999 to filter out of del tickets by drv plan
 *
 **/



DECLARE	@varchar2000		VARCHAR(850),   --was 2000
	@not_number		INTEGER,
	@driver			VARCHAR(90),
	@ord_number		VARCHAR(12),
	@not_text		VARCHAR(254),
	@dest_NOTES		VARCHAR(254),
	@driver_note		varchar(254),
	@loading_instr		VARCHAR(850), 	--was 2000
	@delivery_instr		VARCHAR(850),	--was 2000
	@order_notes		VARCHAR(850),	--was 2000
	@drv_id         	VARCHAR(8),
	@bill_to        	VARCHAR(8),
	@directions     	Varchar(850),	--was 2000
	@cmp_directions 	Varchar(850),	--was 2000
	@special_instr  	VARCHAR(850),	--was 2000
	@rack_id2		VARCHAR(8),
	@rack_name_2    	VARCHAR(100),
	@rack_address1_2 	VARCHAR(50),
	@rack_ctstzip_2		VARCHAR(40),
	@rack_phone_2		VARCHAR(20),
	@consignee_fgt_number	INTEGER,
	@fgt_refnum		VARCHAR(30),
	@cmp_misc1		VARCHAR(254),
	@load_pin		VARCHAR(850),   --was 2000
	@page_number		INTEGER,
	@lul_name	    	VARCHAR(100),
	@lul_address1 		VARCHAR(50),
	@lul_ctstzip		VARCHAR(40),
	@lul_phone		VARCHAR(20),
	@lul_stp_number		INTEGER,
	@lul_cmp_id		VARCHAR(8),
	@cmp_id			varchar(8),
	@lul_fgt_number		INTEGER,
	@lul_fgt_refnum		VARCHAR(30),
	@cur_ord_hdrnumber	INTEGER, 
	@cur_evt_driver1	VARCHAR(8),
	@consignee_stp_number	INTEGER,
	@ord_consingee_id	VARCHAR(8),	
	@tank_sizes_lul		VARCHAR(850),   --was 2000
	@special_instr_lul	VARCHAR(850),   --was 2000
	@load_pin_lul		VARCHAR(850),   --was 2000
	@cmp_directions_lul	VARCHAR(850),	--was 2000
        @v_ord_number           varchar(12),
        @v_ord_hdrnumber	int,
	@v_ref_sequence		int,
	@v_cnt			int,
	@v_ref_type		varchar(6),
        @v_ref_num		varchar(30),
        @V_MIN_LGH		INT,
        @V_MOV			INT,
        @V_DRV_ID		VARCHAR(8),
        @V_PAGE  		INT,
        @V_DEST                 VARCHAR(8),
        @V_ORIGIN		VARCHAR(8),
        @not_sequence           INT ,
 @cur_lghnumber integer,@mfh_number int,@lgh_startdate datetime,@lgh_driver1 varchar(8),@stp_lghnumber int
/* 35028 this does not work
--PTS# 32164 ILB
CREATE TABLE #lgh (
  lgh_driver1     VARCHAR(8)      NULL, 
  lgh_mfh_number  INT             NULL, 
  lgh_startdate   DATETIME        NULL,
  ord_hdrnumber   INT             NULL,
  lgh_number      INT             NULL)
--PTS# 32164 ILB
*/
CREATE TABLE #trips (
	header			VARCHAR(40)	NOT NULL,
	corp_address1		VARCHAR(30)	NOT NULL,
	corp_ctstzip		VARCHAR(30) 	NOT NULL,
	remit_address1		VARCHAR(30) 	NOT NULL,
	remit_ctstzip		VARCHAR(30)	NOT NULL,
	disp1			VARCHAR(30) 	NOT NULL,
	disp1_phone		VARCHAR(30) 	NOT NULL,
	disp1_fax		VARCHAR(30) 	NOT NULL,
	disp2			VARCHAR(30) 	NOT NULL,
	disp2_phone		VARCHAR(30) 	NOT NULL,
	disp2_fax		VARCHAR(30) 	NOT NULL,
	dispatch_date		DATETIME	NOT NULL,
        ord_number              VARCHAR(12)     NULL,	    
	customer_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size from 30
	shipper_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	doc_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	po_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	release_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	ac_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	petroex_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	load_number		VARCHAR(40) 	NULL,  --PRB PTS35059 increased size
	tractor			VARCHAR(8)	NULL,
	trailer			VARCHAR(13) 	NULL,
	driver			VARCHAR(90)	NULL,
	bill_to			VARCHAR(8)	NULL,
	rack_name		VARCHAR(100)	NULL,
	rack_address1		VARCHAR(50)	NULL,
	rack_ctstzip		VARCHAR(40)	NULL,
	rack_phone		VARCHAR(20)	NULL,
	consignee_name		VARCHAR(100)	NULL,
	consignee_address1	VARCHAR(50)	NULL,
	consignee_ctstzip	VARCHAR(40)	NULL,
	consignee_phone		VARCHAR(20)	NULL,
	product1		VARCHAR(60)	NULL,
	quantity1		INTEGER		NULL,
	product2		VARCHAR(60)	NULL,
	quantity2		INTEGER		NULL,
	product3		VARCHAR(60)	NULL,
	quantity3		INTEGER		NULL,
	product4		VARCHAR(60)	NULL,
	quantity4		INTEGER		NULL,
	product5		VARCHAR(60)	NULL,
	quantity5		INTEGER		NULL,
	delivery_date		VARCHAR(254)	NULL,
	loading_instr		VARCHAR(850)	NULL,--was 2000
	delivery_instr		VARCHAR(850)	NULL,--was 2000
	order_notes		VARCHAR(850)	NULL,--was 2000
	ord_heading		VARCHAR(30)	NOT NULL,
	ord_revtype3            VARCHAR(6)	NULL,
	ord_revtype3_name       VARCHAR(20)     NULL,
	ord_startdate           DATETIME        NULL,
	cmp_directions          VARCHAR(850)    NULL,--was 2000
	drv_id                  VARCHAR(8)      NULL,
	box1title		VARCHAR(25)     NULL,
	box2title		VARCHAR(25)     NULL,
	page_number		INTEGER		NULL,
	cur_date	        DATETIME        NULL,
	ord_dest_earliestdate   DATETIME        NULL,
	ord_dest_latestdate     DATETIME        NULL,
	ord_originpoint		VARCHAR(8)	NULL,
	ord_destpoint		VARCHAR(8)      NULL,
	special_instr		VARCHAR(850)   NULL,--was 2000
	rack_cmp_id_2		VARCHAR(8)	NULL,
	rack_name_2		VARCHAR(100)	NULL,
	rack_address1_2		VARCHAR(50)	NULL,
	rack_ctstzip_2		VARCHAR(40)	NULL,
	rack_phone_2		VARCHAR(20)	NULL,
        fgt_refnum		VARCHAR(30)	NULL,	
	bol_number		VARCHAR(30)	NULL,	
	cmp_misc1		VARCHAR(254)    NULL,
	load_pin		VARCHAR(850)   NULL,--was 2000
-- PTS 33271 -- BL (start)
--	ord_miscqty		MONEY		NULL,
	ord_miscqty		DECIMAL(12,4)		NULL,
-- PTS 33271 -- BL (end)
	ord_number_barcode	VARCHAR(20)	NULL,	
        ord_hdrnumber           INT		NULL,
        lgh_driver1             VARCHAR(8)      NULL, 
        lgh_mfh_number          INT             NULL, 
        lgh_startdate           DATETIME        NULL,
        lgh_number              INT             NULL) 

--JYANG create a temp table to hold the ord_hdrnumber based on event and stop.
--so could handle split trips
If @status = 'PLN,DSP'
 BEGIN
	select 	distinct(event.ord_hdrnumber), event.evt_driver1,lgh_number
	into 	#temp_ord
	from   	event,orderheader,stops
	where   @drv in ('UNKNOWN',  event.evt_driver1) and
		event.evt_startdate  >= @startdate AND
		event.evt_enddate <= @enddate and
 		event.ord_hdrnumber <> 0 and
		event.ord_hdrnumber in (select orderheader.ord_hdrnumber from orderheader
					where @revtype1 in( 'UNK', ord_revtype1)) and
		event.ord_hdrnumber = orderheader.ord_hdrnumber and
		orderheader.ord_status in ('PLN','DSP')
        and stops.stp_number = event.stp_number
 	group by event.ord_hdrnumber,evt_driver1,lgh_number
 END
Else 
  BEGIN
	select 	distinct(event.ord_hdrnumber), event.evt_driver1,lgh_number
	into	#temp_ord2
	from   	event, orderheader,stops
	where   @drv in ('UNKNOWN',  event.evt_driver1) and
		event.evt_startdate  >= @startdate AND
		event.evt_enddate <= @enddate and
 		event.ord_hdrnumber <> 0 and
		event.ord_hdrnumber in (select orderheader.ord_hdrnumber from orderheader
					where @revtype1 in( 'UNK', ord_revtype1)) and
		event.ord_hdrnumber = orderheader.ord_hdrnumber and
		orderheader.ord_status = @status
        and stops.stp_number = event.stp_number
	group by event.ord_hdrnumber,evt_driver1,lgh_number
 END

--------
If @status = 'PLN,DSP'
 BEGIN
	DECLARE ord_hdrnumber_cursor CURSOR FOR 
	SELECT  ord_hdrnumber, evt_driver1,lgh_number
	FROM 	#temp_ord
 END
Else
 BEGIN
	DECLARE ord_hdrnumber_cursor CURSOR FOR 
	SELECT  ord_hdrnumber, evt_driver1,lgh_number
	FROM 	#temp_ord2
 END

OPEN ord_hdrnumber_cursor

FETCH NEXT FROM ord_hdrnumber_cursor INTO @cur_ord_hdrnumber, @cur_evt_driver1,@cur_lghnumber

WHILE @@FETCH_STATUS = 0

BEGIN

------------
/* 35082  this is klunky but the way jack was heading */
select @mfh_number = isnull(mfh_number,999) ,@lgh_startdate= lgh_startdate,@lgh_driver1 = lgh_driver1
from legheader_active where lgh_number = @cur_lghnumber
	
SELECT @status = ',' + LTRIM(RTRIM(ISNULL(@status, ''))) + ','

--Place the cmp_id of the second shipper in @rack_id2
--DPH PTS 22528
Select @rack_id2 = Isnull(stops.cmp_id, '') 
from stops stops, orderheader oh
where stops.stp_event = 'LLD'
and stops.ord_hdrnumber = oh.ord_hdrnumber
and stops.cmp_id <> oh.ord_shipper
and @cur_ord_hdrnumber = oh.ord_hdrnumber 

Select 	@rack_name_2 = rack2.cmp_name, @rack_address1_2 = rack2.cmp_address1,
	@rack_ctstzip_2 = rackcity2.cty_name + ', ' + rackcity2.cty_state + ' ' + rackcity2.cty_zip,
	@rack_phone_2 = rack2.cmp_primaryphone
FROM	orderheader oh,
	company rack2,
	city rackcity2
WHERE   rack2.cmp_id = @rack_id2 AND
	rack2.cmp_city = rackcity2.cty_code AND
	@cur_ord_hdrnumber = oh.ord_hdrnumber


select @consignee_stp_number = stp_number
				from stops
				where ord_hdrnumber = @cur_ord_hdrnumber
				AND stp_sequence = (select min(stp_sequence)
							from stops
							where stp_event = 'LUL'
							AND ord_hdrnumber = @cur_ord_hdrnumber)


SELECT 	@lul_cmp_id = Isnull(cmp_id, '') 
	FROM 	stops
	WHERE 	stp_number = @consignee_stp_number


select @fgt_refnum = fgt_refnum
from freightdetail
where fgt_number = (select MIN(fgt_number)
			from freightdetail
			where stp_number = @consignee_stp_number)

select @cmp_misc1 = cmp_misc1
from company
where cmp_id = (select cmp_id
		from stops
		where ord_hdrnumber = @cur_ord_hdrnumber
		AND stp_sequence = (select min(stp_sequence)
					from stops
					where stp_event = 'LUL'
					AND ord_hdrnumber = @cur_ord_hdrnumber))

select @ord_consingee_id = cmp_id
from stops
where ord_hdrnumber = @cur_ord_hdrnumber
AND stp_sequence = (select min(stp_sequence)
			from stops
			where stp_event = 'LUL'
			AND ord_hdrnumber = @cur_ord_hdrnumber)

select @page_number = 1
--DPH PTS 22528

-- print cast(@cur_ord_hdrnumber as varchar(20))
--print @cur_evt_driver1
--print @revtype1
--print @ord_consingee_id
--print cast(@consignee_stp_number as varchar(20))
--print @cur_evt_driver1

INSERT INTO #trips
	SELECT	@rpttitle header,
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
			'' customer_number,
			'' shipper_number,
			'' doc_number,
			'' po_number,
			'' release_number,
			'' ac_number,
			'' petroex_number,
			'' load_number,			
			oh.ord_tractor tractor,
			oh.ord_trailer trailer,
			mpp.mpp_lastname + ', ' + mpp.mpp_firstname + ' ' + mpp.mpp_middlename driver,
			oh.ord_billto bill_to,
			rack.cmp_name rack_name,
			rack.cmp_address1 rack_address1,
			rackcity.cty_name + ', ' + rackcity.cty_state + ' ' + rackcity.cty_zip rack_ctstzip,
			rack.cmp_primaryphone rack_phone,
			consignee.cmp_name consignee_name,
			consignee.cmp_address1 consignee_address1,
			consigneecity.cty_name + ', ' + consigneecity.cty_state + ' ' + consigneecity.cty_zip consignee_ctstzip,
			consignee.cmp_primaryphone consignee_phone,
			(SELECT fd.cmd_code
			   FROM	freightdetail fd
			   WHERE fd.fgt_number = (SELECT MIN(fgt_number)
						  FROM	freightdetail
						  WHERE	stp_number = @consignee_stp_number AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 1)) product1,
			(SELECT	quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
					      FROM	freightdetail
					      WHERE	stp_number = @consignee_stp_number AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 1)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
				        	   FROM	freightdetail
									  WHERE	stp_number = @consignee_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2) ) product2,
			(SELECT	quantity2 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = @consignee_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
						 FROM	freightdetail
						 WHERE	stp_number = @consignee_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) product3,
			(SELECT	quantity3 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
						FROM	freightdetail
						WHERE	stp_number = @consignee_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = @consignee_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4) ) product4,
			(SELECT	quantity4 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
						FROM	freightdetail
					       WHERE	stp_number = @consignee_stp_number AND
											cmd_code <> 'UNKNOWN' AND

											fgt_sequence = 4)) ,
			
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
						 FROM	freightdetail
						 WHERE	stp_number = @consignee_stp_number AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 5) ) product5,
			(SELECT	quantity5 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT	MIN(fgt_number)
						FROM	freightdetail
						WHERE	stp_number = @consignee_stp_number AND
										cmd_code <> 'UNKNOWN' AND
										fgt_sequence = 5)),
			oh.ord_remark delivery_date,
			@varchar2000 loading_instr,
			@varchar2000 delivery_instr,
			@varchar2000 order_notes,
			@box5title ord_heading,
			oh.ord_revtype3,
			lab2.name,
			oh.ord_startdate,
			consignee.cmp_directions,			
			@cur_evt_driver1,
			@box1title,
			@box2title,			
			@page_number,			
			(select isnull(lgh_schdtlatest,'')
			 from legheader 
			where lgh_number = (select min(lgh_number)
			                      from legheader 
			                     where ord_hdrnumber = @cur_ord_hdrnumber)),			
			(SELECT	ord_dest_earliestdate = isnull(stp_schdtearliest,'')
			 FROM	stops
			 WHERE	stp_number = (select stp_number
			                        from stops
			                       where stp_mfh_sequence = (select min(stp_mfh_sequence)
			                                                   from stops
			                                                  where ord_hdrnumber = @cur_ord_hdrnumber and
			                                                        stp_type = 'DRP')
			                        and ord_hdrnumber = @cur_ord_hdrnumber   
						and stp_type = 'DRP'))	,			
			(SELECT	ord_dest_latestdate = isnull(stp_schdtlatest,'') 
			 FROM	stops
			 WHERE	stp_number = (select stp_number
			                        from stops
			                       where stp_mfh_sequence = (select min(stp_mfh_sequence)
			                                                   from stops
			                                                  where ord_hdrnumber = @cur_ord_hdrnumber and
			                                                        stp_type = 'DRP')
			                        and ord_hdrnumber = @cur_ord_hdrnumber   
						and stp_type = 'DRP')),		
                	ord_originpoint,
			@lul_cmp_id,
			@varchar2000 special_instr,
			@rack_id2,
			@rack_name_2,
			@rack_address1_2,
			@rack_ctstzip_2,
			@rack_phone_2,
			@fgt_refnum,			
			(SELECT	MIN(ref_number)
			   FROM	referencenumber
			  WHERE	ref_tablekey = oh.ord_hdrnumber AND
					ref_type = 'BOL#' AND
					ref_table = 'orderheader') bol_number,			
			@cmp_misc1,
			@varchar2000 load_pin,
			oh.ord_miscqty,
			'*' + rtrim(ltrim(oh.ord_number)) + '*' ord_number_barcode,			
			oh.ord_hdrnumber,
      @lgh_driver1,  --            '' lgh_driver1, 
        	@mfh_number,   --	0  lgh_mfh_number, 
        	@lgh_startdate,  --	'' lgh_startdate ,
            @cur_lghnumber --            0  lgh_number	
	  FROM	        orderheader oh,
			company rack,
			company consignee,
			city rackcity,
			city consigneecity,
			labelfile lab1,
			labelfile lab2,
			manpowerprofile mpp

	 WHERE	        oh.ord_shipper = rack.cmp_id AND
			@ord_consingee_id = consignee.cmp_id AND
			rack.cmp_city = rackcity.cty_code AND
			consignee.cmp_city = consigneecity.cty_code AND
			lab1.abbr = oh.ord_revtype4 AND
			lab1.labeldefinition = 'revtype4' AND
			mpp.mpp_id =  @cur_evt_driver1 AND
			--CHARINDEX(',' + oh.ord_status + ',', @status) > 0 AND
			--(@drv = 'UNKNOWN' OR ord_driver1 = @drv) AND
			@revtype1 in( 'UNK' ,ord_revtype1) AND
			ord_startdate >= @startdate AND
			ord_startdate <= @enddate AND
			lab2.abbr = oh.ord_revtype3 AND
			lab2.labeldefinition = 'revtype3' and
			@cur_ord_hdrnumber = oh.ord_hdrnumber

--CREATE INDEX order_ind ON #trips (ord_number)
--print '  inserted ok'

	SELECT @not_text = ''
	SELECT @order_notes = ''
	SELECT @cmp_directions = ''
	SELECT @special_instr = ''
	SELECT @load_pin = ''
	SELECT @tank_sizes_lul = ''
	SELECT @special_instr_lul = ''
	SELECT @load_pin_lul = ''

----------Order Notes 

	DECLARE notes3_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	 WHERE	ntb_table = 'orderheader' AND
		nre_tablekey = @cur_ord_hdrnumber
	ORDER BY not_sequence

	OPEN notes3_cursor

	FETCH NEXT FROM notes3_cursor INTO @not_text

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @order_notes = @order_notes + @not_text + '  '

		FETCH NEXT FROM notes3_cursor INTO @not_text
	END

	CLOSE notes3_cursor
	DEALLOCATE notes3_cursor
----------Order Notes 

--print ' error yet!'
----------Driver Notes PTS#31135 ILB
	SELECT @V_MIN_LGH = 0
	SELECT @V_MOV = 0 
	SELECT @V_DRV_ID = ''
	select @not_sequence = 0

	SELECT @V_MOV = MOV_NUMBER 
          FROM ORDERHEADER 
         WHERE ORD_HDRNUMBER = @cur_ord_hdrnumber
        --PRINT '1'
        --PRINT CAST(@cur_ord_hdrnumber AS VARCHAR(20))
	--PRINT CAST(@V_MOV AS VARCHAR(20))

	WHILE (SELECT COUNT(*) 
		FROM ASSETASSIGNMENT 
		WHERE MOV_NUMBER = @V_MOV AND
                      ASGN_TYPE = 'DRV' AND
                      LGH_NUMBER > @V_MIN_LGH) > 0

		BEGIN  
		  SELECT @V_MIN_LGH = MIN(LGH_NUMBER)
                    FROM ASSETASSIGNMENT 
		   WHERE MOV_NUMBER = @V_MOV AND
                         ASGN_TYPE = 'DRV' AND
                         LGH_NUMBER > @V_MIN_LGH 
		 --PRINT CAST(@V_MIN_LGH AS VARCHAR(20))

		  SELECT @V_DRV_ID = ASGN_ID
                    FROM ASSETASSIGNMENT
                   WHERE MOV_NUMBER = @V_MOV AND
                         ASGN_TYPE = 'DRV' AND
                         LGH_NUMBER = @V_MIN_LGH  
		--PRINT @V_DRV_ID 
                         
		WHILE (SELECT COUNT(*) 
			 FROM NOTES 
			WHERE not_type IN ('C','DI','LI','NONE') AND
			      ntb_table IN ('MANPOWERPROFILE') AND
			      nre_tablekey = @V_DRV_ID AND
                              not_sequence > @not_sequence) > 0

			BEGIN
			
			  select @not_sequence = min(not_sequence)
                            from notes 
                           WHERE not_type IN ('C','DI','LI','NONE') AND
				 ntb_table IN ('MANPOWERPROFILE') AND
				 nre_tablekey = @V_DRV_ID and
                                 not_sequence > @not_sequence
		
			  SELECT @driver_note = isnull(not_text,'')
		            FROM notes
			   WHERE not_type IN ('C','DI','LI','NONE') AND
				 ntb_table IN ('MANPOWERPROFILE') AND
				 nre_tablekey = @V_DRV_ID and
                                 not_sequence = @not_sequence	

	              
		          SELECT @ORDER_NOTES = @ORDER_NOTES + @driver_note + '  '

		       END
	     END 
-----Driver Notes PTS#31135 ILB
--print ' error yet!'
----- Company Notes PTS#31135 ILB
         select @cmp_id = ''
	 select @not_sequence = 0
         SELECT @DEST_NOTES = ''
	
	 select @cmp_id = ord_destpoint 
           from #trips
          where page_number = 1

	 WHILE (SELECT COUNT(*) 
		  FROM notes 
		 WHERE not_type IN ('C','TANKSZ','DI','LI') AND
		       ntb_table IN ('COMPANY') AND
		       nre_tablekey = @cmp_id and
                       not_sequence > @not_sequence) > 0

		BEGIN
			  select @not_sequence = min(not_sequence)
                            from notes
                           where not_type IN ('C','TANKSZ','DI','LI') AND
		       		 ntb_table IN ('COMPANY') AND
		       		 nre_tablekey = @cmp_id and
                        	 not_sequence > @not_sequence

			  SELECT @DEST_NOTES = ISNULL(not_text,'')
		            FROM notes
			   WHERE not_type IN ('C','TANKSZ','DI','LI') AND
				 ntb_table IN ('COMPANY') AND
				 nre_tablekey = @cmp_id and
                                 not_sequence = @not_sequence	

			  --PRINT @ORDER_NOTES
        
	       		  SELECT @ORDER_NOTES = @ORDER_NOTES + @DEST_NOTES + '  '
		
			  --PRINT @DEST_NOTES
	      
            	END
----- Company Notes PTS#31135 ILB
--print ' error yet!'
	--DPH PTS 22528(BEGIN)
	DECLARE notes7_cursor CURSOR FOR
	--PTS# 31135 ILB 05/03/2006 
	--SELECT	not_text
        --FROM 	notes
	--WHERE	not_type = 'SPI' AND
	--		ntb_table = 'orderheader' AND
	--		nre_tablekey = @cur_ord_hdrnumber
	--ORDER BY not_sequence

	SELECT	ord_remark
        FROM 	orderheader
	WHERE	ord_hdrnumber = @cur_ord_hdrnumber
	--PTS# 31135 ILB 05/03/2006
	
	OPEN notes7_cursor

	FETCH NEXT FROM notes7_cursor INTO @not_text

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @special_instr = @special_instr + @not_text + '  '

		FETCH NEXT FROM notes7_cursor INTO @not_text
	END

	CLOSE notes7_cursor

	DEALLOCATE notes7_cursor

--print ' error yet!'
	--DPH PTS 22528(BEGIN)
	DECLARE notes9_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	 WHERE	not_type = 'COMB' AND  
		ntb_table = 'orderheader' AND
		nre_tablekey = @cur_ord_hdrnumber
	ORDER BY not_sequence

	OPEN notes9_cursor

	FETCH NEXT FROM notes9_cursor INTO @not_text


	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @load_pin = @load_pin + @not_text + '  '

		FETCH NEXT FROM notes9_cursor INTO @not_text
	END

	CLOSE notes9_cursor

	DEALLOCATE notes9_cursor
--print ' error yet!'
-----
--ILB
--GET NOTES AND DIRECTIONS FOR FIRST LUL COMPANY (START) - DPH
--select 	@tank_sizes_lul = not_text
--FROM 	notes, stops
--WHERE	not_type = 'TANKSZ' AND
--	ntb_table = 'company' AND
--	nre_tablekey = stops.cmp_id AND
--	stops.stp_number = @consignee_stp_number
--ILB

select	@special_instr_lul = not_text
FROM 	notes,stops,orderheader 
WHERE	not_type = 'SPI' AND
	ntb_table = 'company' AND
	nre_tablekey = stops.cmp_id AND
	stops.stp_number = @consignee_stp_number
--print ' error yet!'	
select	@load_pin_lul = not_text
FROM 	notes,stops,orderheader 
WHERE	not_type = 'COMB' AND
	ntb_table = 'company' AND
	nre_tablekey = stops.cmp_id AND
	stops.stp_number = @consignee_stp_number
--print ' error yet!'

UPDATE	#trips
SET	order_notes = @order_notes ,
	special_instr = @special_instr + '' + @special_instr_lul,
	load_pin = @load_pin + '' + @load_pin_lul
 WHERE	ord_hdrnumber = @cur_ord_hdrnumber and
	drv_id = @cur_evt_driver1 and
	ord_destpoint = (select cmp_id
			  from stops
			  where stp_number = @consignee_stp_number)
--print ' error yet!'

--Cursor for additional pages for additional LUL's
DECLARE additional_lul_cursor CURSOR FOR 

SELECT 	stops.stp_number
	from stops, orderheader
	where stops.ord_hdrnumber = orderheader.ord_hdrnumber and
	@cur_ord_hdrnumber = orderheader.ord_hdrnumber and
	stp_event = 'LUL' and
	stops.stp_sequence > (select min(stp_sequence)
				from stops
				where stp_event = 'LUL'
				AND ord_hdrnumber = @cur_ord_hdrnumber)
order by stp_sequence


OPEN additional_lul_cursor

FETCH NEXT FROM additional_lul_cursor INTO @lul_stp_number
/* 35082  this is klunky but the way jack was heading */
select @mfh_number = isnull(legheader_active.mfh_number,999) ,@lgh_startdate= lgh_startdate,@lgh_driver1 = lgh_driver1
from stops
join legheader_active on stops.lgh_number = legheader_active.lgh_number
where stp_number = @lul_stp_number
	


WHILE @@FETCH_STATUS = 0
BEGIN
	--Do processing here
	select @page_number = @page_number + 1

        --print cast(@lul_stp_number as varchar(20))

	INSERT INTO #trips
		SELECT	@rpttitle header,
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
			'' customer_number,
			'' shipper_number,
			'' doc_number,
			'' po_number,
			'' release_number,
			'' ac_number,
			'' petroex_number,
			'' load_number,			
			oh.ord_tractor tractor,
			oh.ord_trailer trailer,
			mpp.mpp_lastname + ', ' + mpp.mpp_firstname + ' ' + mpp.mpp_middlename driver,
			oh.ord_billto bill_to,
			rack.cmp_name rack_name,
			rack.cmp_address1 rack_address1,
			rackcity.cty_name + ', ' + rackcity.cty_state + ' ' + rackcity.cty_zip rack_ctstzip,
			rack.cmp_primaryphone rack_phone,
			consignee.cmp_name consignee_name,
			consignee.cmp_address1 consignee_address1,
			consigneecity.cty_name + ', ' + consigneecity.cty_state + ' ' + consigneecity.cty_zip consignee_ctstzip,
			consignee.cmp_primaryphone consignee_phone,
			 (SELECT fd.cmd_code
			   FROM	freightdetail fd
			   WHERE fd.fgt_number = (SELECT MIN(fgt_number)
						  FROM	freightdetail
						  WHERE	stp_number = @lul_stp_number AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 1)) product1,
			(SELECT	quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
					      FROM	freightdetail
					      WHERE	stp_number = @lul_stp_number AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 1)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
				        	   FROM	freightdetail
									  WHERE	stp_number = @lul_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2) ) product2,
			(SELECT	quantity2 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = @lul_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
						 FROM	freightdetail
						 WHERE	stp_number = @lul_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) product3,
			(SELECT	quantity3 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
						FROM	freightdetail
						WHERE	stp_number = @lul_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = @lul_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4) ) product4,
			(SELECT	quantity4 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
						FROM	freightdetail
					       WHERE	stp_number = @lul_stp_number AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4)) ,
			
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
						 FROM	freightdetail
						 WHERE	stp_number = @lul_stp_number AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 5) ) product5,
			(SELECT	quantity5 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT	MIN(fgt_number)
						FROM	freightdetail
						WHERE	stp_number = @lul_stp_number AND
										cmd_code <> 'UNKNOWN' AND
										fgt_sequence = 5)),
			oh.ord_remark delivery_date,
			@varchar2000 loading_instr,
			@varchar2000 delivery_instr,
			@varchar2000 order_notes,
			@box5title ord_heading,
			oh.ord_revtype3,
			lab2.name,
			oh.ord_startdate,			
			'',
			@cur_evt_driver1,
			@box1title,
			@box2title,			
			@page_number,			
			(select lgh_schdtlatest
			   from legheader 
			  where lgh_number = (select min(lgh_number)
			                        from legheader 
			                       where ord_hdrnumber = @cur_ord_hdrnumber)),			
                        (SELECT	ord_dest_earliestdate = stp_schdtearliest 
			   FROM	stops
			  WHERE	stp_number = @lul_stp_number),			
			(SELECT	ord_dest_latestdate = stp_schdtlatest 
			   FROM	stops
			  WHERE	stp_number = @lul_stp_number),
			ord_originpoint,
			ord_destpoint,
			@varchar2000 special_instr,
			@rack_id2,
			@rack_name_2,
			@rack_address1_2,
			@rack_ctstzip_2,
			@rack_phone_2,
			@fgt_refnum,			
			(SELECT	MIN(ref_number)
			   FROM	referencenumber
			  WHERE	ref_tablekey = oh.ord_hdrnumber AND
					ref_type = 'BOL#' AND
					ref_table = 'orderheader') bol_number,			
			@cmp_misc1,
			@varchar2000 load_pin,
			oh.ord_miscqty,
			'*' + rtrim(ltrim(oh.ord_number)) + '*' ord_number_barcode,			
			oh.ord_hdrnumber,
         @lgh_driver1,  --            '' lgh_driver1, 
        	@mfh_number,   --	0  lgh_mfh_number, 
        	@lgh_startdate,  --	'' lgh_startdate ,
            @stp_lghnumber --            0  lgh_number	               
	  	 FROM	orderheader oh,
			company rack,
			company consignee,
			city rackcity,
			city consigneecity,
			labelfile lab1,
			labelfile lab2,
			manpowerprofile mpp
		 WHERE	oh.ord_shipper = rack.cmp_id AND
			oh.ord_consignee = consignee.cmp_id AND
			rack.cmp_city = rackcity.cty_code AND
			consignee.cmp_city = consigneecity.cty_code AND
			lab1.abbr = oh.ord_revtype4 AND
			lab1.labeldefinition = 'revtype4' AND
			mpp.mpp_id =  @cur_evt_driver1 AND
			--CHARINDEX(',' + oh.ord_status + ',', @status) > 0 AND
			--(@drv = 'UNKNOWN' OR ord_driver1 = @drv) AND
			@revtype1 in( 'UNK' ,ord_revtype1) AND
			ord_startdate >= @startdate AND
			ord_startdate <= @enddate AND
			lab2.abbr = oh.ord_revtype3 AND
			lab2.labeldefinition = 'revtype3' and
			@cur_ord_hdrnumber = oh.ord_hdrnumber 

	--GET NOTES AND DIRECTIONS FOR FIRST LUL COMPANY (START) - DPH
	--select 	@tank_sizes_lul = not_text
	--FROM 	notes, stops
	--WHERE	not_type = 'TANKSZ' AND
	--	ntb_table = 'company' AND
	--	nre_tablekey = stops.cmp_id AND
	--	stops.stp_number = @lul_stp_number

	select	@special_instr_lul = not_text
	FROM 	notes,stops,orderheader 
	WHERE	not_type = 'SPI' AND
		ntb_table = 'company' AND
		nre_tablekey = stops.cmp_id AND
		stops.stp_number = @lul_stp_number

	--Determine remaining values
	SELECT 	@lul_cmp_id = Isnull(cmp_id, '') 
	FROM 	stops
	WHERE 	stp_number = @lul_stp_number

	select	@load_pin_lul = not_text
	FROM 	notes,stops,orderheader 
	WHERE	not_type = 'COMB' AND
		ntb_table = 'company' AND
		nre_tablekey = stops.cmp_id AND
		stops.stp_number = @lul_stp_number AND
		stops.cmp_id = @lul_cmp_id

 	select	@cmp_directions_lul = cmp_directions
 	FROM 	company
 	WHERE	cmp_id = @lul_cmp_id
	
	 --Company Notes PTS# 31135 06/21/2006 
	 select @not_sequence = 0
         SELECT @DEST_NOTES = ''

	 WHILE (SELECT COUNT(*) 
		  FROM notes 
		 WHERE not_type IN ('C','TANKSZ','DI','LI') AND
		       ntb_table IN ('COMPANY') AND
		       nre_tablekey = @lul_cmp_id and
                       not_sequence > @not_sequence) > 0

		BEGIN
			  select @not_sequence = min(not_sequence)
                            from notes
                           where not_type IN ('C','TANKSZ','DI','LI') AND
		       		 ntb_table IN ('COMPANY') AND
		       		 nre_tablekey = @lul_cmp_id and
                        	 not_sequence > @not_sequence

			  SELECT @DEST_NOTES = ISNULL(not_text,'')
		            FROM notes
			   WHERE not_type IN ('C','TANKSZ','DI','LI') AND
				 ntb_table IN ('COMPANY') AND
				 nre_tablekey = @lul_cmp_id and
                                 not_sequence = @not_sequence	
			  --PRINT @ORDER_NOTES
        
	       		  SELECT @ORDER_NOTES = @ORDER_NOTES + @DEST_NOTES + '  '
		
			  --PRINT @DEST_NOTES
	      
            	END
	 --Company Notes PTS# 31135 06/21/2006 

	--Update Notes
	UPDATE	#trips
	SET	order_notes = @order_notes ,
		cmp_directions = @cmp_directions_lul,
		special_instr = @special_instr + '' + @special_instr_lul,
		load_pin = @load_pin + '' + @load_pin_lul
	WHERE	ord_hdrnumber = @cur_ord_hdrnumber and
		drv_id = @cur_evt_driver1 and
		page_number =  @page_number

	SELECT 	@lul_name = company.cmp_name, @lul_address1 = company.cmp_address1,
		@lul_ctstzip = city.cty_name + ', ' + city.cty_state + ' ' + city.cty_zip,
		@lul_phone = company.cmp_primaryphone
	FROM	company,
		city
	WHERE   company.cmp_id = @lul_cmp_id AND
		company.cmp_city = city.cty_code

	select @lul_fgt_number = MIN(fgt_number)
	from   freightdetail
	where  stp_number = (select min(stops.stp_number)
				from stops stops, orderheader oh
				where @cur_ord_hdrnumber = oh.ord_hdrnumber
				AND stops.ord_hdrnumber = oh.ord_hdrnumber
				AND stops.cmp_id = @lul_cmp_id)

	select @lul_fgt_refnum = fgt_refnum
	from   freightdetail
	where  fgt_number = @lul_fgt_number

	--Update remaining values
 	UPDATE #trips
 	SET    fgt_refnum = @lul_fgt_refnum,
	       ord_destpoint = @lul_cmp_id,
	       consignee_name = @lul_name,
 	       consignee_address1 = @lul_address1,
 	       consignee_ctstzip = @lul_ctstzip,
 	       consignee_phone = @lul_phone
 	where  ord_hdrnumber = @cur_ord_hdrnumber and
 	       drv_id = @cur_evt_driver1 and
 	       page_number = @page_number

	FETCH NEXT FROM additional_lul_cursor INTO @lul_stp_number
END

CLOSE additional_lul_cursor

DEALLOCATE additional_lul_cursor

FETCH NEXT FROM ord_hdrnumber_cursor INTO @cur_ord_hdrnumber, @cur_evt_driver1,@cur_lghnumber

END

CLOSE ord_hdrnumber_cursor
DEALLOCATE ord_hdrnumber_cursor


--PTS# 31135 ILB 03/23/2006
BEGIN	
	
	Select @v_ord_number = 0 
	Select @v_ord_hdrnumber = 0
	Select @v_ref_sequence = 0
	Select @v_cnt = 0
        Select @v_ref_type = ''
        Select @v_ref_num = ''
	 	
	--print 'are we in yet'
	WHILE (SELECT COUNT(ord_number) 
		 FROM #trips 
		WHERE ord_number > @v_ord_number) > 0
	BEGIN
	  	--print 'what is the deal'
		SELECT @v_ord_number = MIN(ord_number) 
	          FROM #trips 
	         WHERE ord_number > @v_ord_number 

		Select @v_ord_hdrnumber = ord_hdrnumber
                  from orderheader
                 where ord_number = @v_ord_number

		--print 'order number ' + @v_ord_number
                --print 'order hdr number ' + cast(@v_ord_hdrnumber as varchar(12))
                 
		WHILE (select count(ref_tablekey)
                         from referencenumber
			where ref_tablekey = @v_ord_hdrnumber
                          and ref_table = 'orderheader'
                          and ref_sequence <= 8
                          and ref_sequence > @v_ref_sequence) > 0

			BEGIN 
				Select @v_cnt = @v_cnt + 1
				--print cast(@v_cnt as varchar(20))

				select @v_ref_sequence = Min(ref_sequence)
	                         from referencenumber
				where ref_tablekey = @v_ord_hdrnumber
	                          and ref_table = 'orderheader'	                         
	                          and ref_sequence > @v_ref_sequence
				  and ref_sequence <= 8 
				
				--print cast(@v_ref_sequence as varchar(20))

				select @v_ref_type = ref_type,
                                       @v_ref_num = ref_number
                                  from referencenumber
                                 where ref_tablekey = @v_ord_hdrnumber
				   and ref_sequence = @v_ref_sequence
	                           and ref_table = 'orderheader'						
				
				--print @v_ref_type +' '+@v_ref_num

				IF @v_cnt = 1 
				   Begin
					update #trips
					   set customer_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END
					
				IF @v_cnt = 2 
				   Begin
					update #trips
					   set shipper_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END

				IF @v_cnt = 3
				   Begin
					update #trips
					   set doc_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END

				IF @v_cnt = 4 
				   Begin
					update #trips
					   set po_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END

				IF @v_cnt = 5
				   Begin
					update #trips
					   set release_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END

				IF @v_cnt = 6
				   Begin
					update #trips
					   set ac_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END

				IF @v_cnt = 7 
				   Begin
					update #trips
					   set petroex_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END

				IF @v_cnt = 8 
				   Begin
					update #trips
					   set load_number = @v_ref_type +'# '+@v_ref_num
                                         where ord_number = @v_ord_number
                                   END
			
			--Reset the type and number 
			Select @v_ref_type = ''
        		Select @v_ref_num = ''

			END --Reference Number loop

		--Reset the counter
		Select @v_cnt = 0
		Select @v_ref_sequence = 0
		END--Order Number loop
	END
--PTS# 31135 ILB 03/23/2006

--PTS# 32164 ILB 06/02/2006
/* 32508 does not work
INSERT INTO #lgh
    SELECT lgh.lgh_driver1,
           isnull(lgh.mfh_number,999),  --lgh.mfh_number
           lgh.lgh_startdate,
           lgh.ord_hdrnumber,
           min(lgh.lgh_number)
      FROM #trips, legheader_active lgh
     WHERE #trips.ord_hdrnumber = lgh.ord_hdrnumber and
           #trips.drv_id = lgh.lgh_driver1 and
           (lgh.lgh_outstatus = 'PLN' OR lgh.lgh_outstatus = 'DSP')
 group by  lgh.lgh_driver1,lgh.mfh_number,lgh.lgh_startdate,lgh.ord_hdrnumber
order by lgh.lgh_driver1, isnull(lgh.mfh_number,2147483647),lgh.lgh_startdate


update #trips
   set #trips.lgh_driver1    = #lgh.lgh_driver1, 
       #trips.lgh_mfh_number = isnull(#lgh.lgh_mfh_number, 999), --35028  #lgh.lgh_mfh_number
       #trips.lgh_startdate  = #lgh.lgh_startdate,
       #trips.lgh_number     = #lgh.lgh_number
  from #trips, #lgh
 where #trips.ord_hdrnumber = #lgh.ord_hdrnumber and
       #trips.drv_id = #lgh.lgh_driver1			

--PTS# 32164 ILB 06/02/2006
*/
   SELECT  header,
	corp_address1,
	corp_ctstzip,
	remit_address1,
	remit_ctstzip,
	disp1,
	disp1_phone,
	disp1_fax,
	disp2,
	disp2_phone,
	disp2_fax,
	dispatch_date,
        ord_number,	    
	customer_number, 
	shipper_number,  
	doc_number,  
	po_number,  
	release_number,  
	ac_number,  
	petroex_number,  
	load_number,  
	tractor,
	trailer,
	driver,
	bill_to,
	rack_name,
	rack_address1,
	rack_ctstzip,
	rack_phone,
	consignee_name,
	consignee_address1,
	consignee_ctstzip,
	consignee_phone,
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
	order_notes,
	ord_heading,
	ord_revtype3,
	ord_revtype3_name,
	ord_startdate,
	cmp_directions,
	drv_id,
	box1title,
	box2title,
	page_number,
	cur_date,
	ord_dest_earliestdate,
	ord_dest_latestdate,
	ord_originpoint,
	ord_destpoint,
	special_instr,
	rack_cmp_id_2,
	rack_name_2,
	rack_address1_2,
	rack_ctstzip_2,
	rack_phone_2,
        fgt_refnum,	
	bol_number,	
	cmp_misc1,
	load_pin,
	ord_miscqty,
	ord_number_barcode,	
        ord_hdrnumber,
        lgh_driver1, 
        lgh_mfh_number, 
        lgh_startdate,
        lgh_number
FROM #trips 
ORDER BY tractor,driver,ord_startdate

DROP TABLE #trips
GO
GRANT EXECUTE ON  [dbo].[d_drvdelticket_format05_sp] TO [public]
GO
