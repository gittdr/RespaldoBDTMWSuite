SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [dbo].[d_drvdelticket_format02_sp]
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
DECLARE	@varchar2000		VARCHAR(2000),
	@not_number		INTEGER,
	@driver			VARCHAR(90),
	@ord_number		VARCHAR(12),
	@not_text		VARCHAR(254),
	@loading_instr		VARCHAR(2000),
	@delivery_instr		VARCHAR(2000),
	@tank_sizes		VARCHAR(2000),
	@drv_id         	VARCHAR(8),
	@bill_to        	VARCHAR(8),
	@directions     	Varchar(2000),
	@cmp_directions 	Varchar(2000),
	@special_instr  	VARCHAR(2000),
	@rack_id2		VARCHAR(8),
	@rack_name_2    	VARCHAR(100),
	@rack_address1_2 	VARCHAR(50),
	@rack_ctstzip_2		VARCHAR(40),
	@rack_phone_2		VARCHAR(20),
	@consignee_fgt_number	INTEGER,
	@fgt_refnum		VARCHAR(30),
	@cmp_misc1		VARCHAR(254),
	@load_pin		VARCHAR(2000),
	@page_number		INTEGER,
	@lul_name	    	VARCHAR(100),
	@lul_address1 		VARCHAR(50),
	@lul_ctstzip		VARCHAR(40),
	@lul_phone		VARCHAR(20),
	@lul_stp_number		INTEGER,
	@lul_cmp_id		VARCHAR(8),
	@lul_fgt_number		INTEGER,
	@lul_fgt_refnum		VARCHAR(30),
	@cur_ord_hdrnumber	INTEGER, 
	@cur_evt_driver1	VARCHAR(8),
	@consignee_stp_number	INTEGER,
	@ord_consingee_id	VARCHAR(8),	
	@tank_sizes_lul		VARCHAR(2000),
	@special_instr_lul	VARCHAR(2000),
	@load_pin_lul		VARCHAR(2000),
	@cmp_directions_lul	VARCHAR(2000),
    @cur_lghnumber integer,@mfh_number int,@lgh_startdate datetime,@lgh_driver1 varchar(8),@stp_lghnumber int

/* 35028 does not work
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
	ord_number		VARCHAR(14) 	NOT NULL,
	release_pickup		VARCHAR(20) 	NULL,
	supplier		VARCHAR(20) 	NULL,
	shipper_bl		VARCHAR(20) 	NULL,
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
	loading_instr		VARCHAR(2000)	NULL,
	delivery_instr		VARCHAR(2000)	NULL,
	tank_sizes		VARCHAR(2000)	NULL,
	ord_heading		VARCHAR(30)	NOT NULL,
	ord_revtype3            VARCHAR(6)	NULL,
	ord_revtype3_name       VARCHAR(20)     NULL,
	ord_startdate           DATETIME        NULL,
	cmp_directions          VARCHAR(2000)   NULL,
	drv_id                  VARCHAR(8)      NULL,
	box1title		VARCHAR(25)     NULL,
	box2title		VARCHAR(25)     NULL,
	--DPH PTS 22528
	page_number		INTEGER		NULL,
	cur_date	        DATETIME        NOT NULL,
	ord_dest_earliestdate   DATETIME        NOT NULL,
	ord_dest_latestdate     DATETIME        NOT NULL,
	ord_originpoint		VARCHAR(8)	NULL,
	ord_destpoint		VARCHAR(8)      NULL,
	special_instr		VARCHAR(2000)   NULL,
	rack_cmp_id_2		VARCHAR(8)	NULL,
	rack_name_2		VARCHAR(100)	NULL,
	rack_address1_2		VARCHAR(50)	NULL,
	rack_ctstzip_2		VARCHAR(40)	NULL,
	rack_phone_2		VARCHAR(20)	NULL,
	fgt_refnum		VARCHAR(30)	NULL,
	cmp_misc1		VARCHAR(254)    NULL,
	load_pin		VARCHAR(2000)   NULL,
-- PTS 33271 -- BL (start)
--	ord_miscqty		MONEY		NULL,
	ord_miscqty		DECIMAL(12,4)		NULL,
-- PTS 33271 -- BL (end)
	ord_number_barcode	VARCHAR(20)	NULL,
	--DPH PTS 22528
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
	from   	event
    join orderheader on event.ord_hdrnumber = orderheader.ord_hdrnumber
    join stops on event.stp_number = stops.stp_number
	where   @drv in ('UNKNOWN',  event.evt_driver1) and
		event.evt_startdate  >= @startdate AND
		event.evt_enddate <= @enddate and
 		event.ord_hdrnumber <> 0 and
        (@revtype1 = 'UNK' or @revtype1 = ord_revtype1) and
--		event.ord_hdrnumber in (select orderheader.ord_hdrnumber from orderheader
--					where @revtype1 in( 'UNK', ord_revtype1)) and
--		event.ord_hdrnumber = orderheader.ord_hdrnumber and
		orderheader.ord_status in ('PLN','DSP')
 	group by event.ord_hdrnumber,evt_driver1,lgh_number

 END
Else 
  BEGIN
	select 	distinct(event.ord_hdrnumber), event.evt_driver1,lgh_number
	into	#temp_ord2
	from   	event
    join    orderheader on event.ord_hdrnumber = event.ord_hdrnumber
    join stops on event.stp_number = stops.stp_number
	where   @drv in ('UNKNOWN',  event.evt_driver1) and
		event.evt_startdate  >= @startdate AND
		event.evt_enddate <= @enddate and
 		event.ord_hdrnumber <> 0 and
         (@revtype1 = 'UNK' or @revtype1 = ord_revtype1) and
--		event.ord_hdrnumber in (select orderheader.ord_hdrnumber from orderheader
--					where @revtype1 in( 'UNK', ord_revtype1)) and
--		event.ord_hdrnumber = orderheader.ord_hdrnumber and
		orderheader.ord_status = @status
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
/* 35082  this is klunky but the way jack was heading */
select @mfh_number = isnull(mfh_number,999) ,@lgh_startdate= lgh_startdate,@lgh_driver1 = lgh_driver1
from legheader_active where lgh_number = @cur_lghnumber

------------
	
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
			(SELECT	MIN(ref_number)
			   FROM	referencenumber
			  WHERE	ref_tablekey = oh.ord_hdrnumber AND
					ref_type = 'REL' AND
					ref_table = 'orderheader') realease_pickup,
			lab1.name supplier,
			(SELECT	MIN(ref_number)
			   FROM	referencenumber
			  WHERE	ref_tablekey = oh.ord_hdrnumber AND
					ref_type = 'BL#' AND
					ref_table = 'orderheader') shipper_bl,
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
			@varchar2000 tank_sizes,
			@box5title ord_heading,
			oh.ord_revtype3,
			lab2.name,
			oh.ord_startdate,
			consignee.cmp_directions,
			--'',
			@cur_evt_driver1,
			@box1title,
			@box2title,
			--DPH PTS 22528,
			@page_number,
			getdate(),
			ord_dest_earliestdate,
			ord_dest_latestdate,
			ord_originpoint,
			@lul_cmp_id,
			@varchar2000 special_instr,
			@rack_id2,
			@rack_name_2,
			@rack_address1_2,
			@rack_ctstzip_2,
			@rack_phone_2,
			@fgt_refnum,
			@cmp_misc1,
			@varchar2000 load_pin,
			oh.ord_miscqty,
			'*' + rtrim(ltrim(oh.ord_number)) + '*' ord_number_barcode,
			--DPH PTS 22528
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


	SELECT @not_text = ''
	SELECT @tank_sizes = ''
	SELECT @cmp_directions = ''
	SELECT @special_instr = ''
	SELECT @load_pin = ''
	SELECT @tank_sizes_lul = ''
	SELECT @special_instr_lul = ''
	SELECT @load_pin_lul = ''

---------------------------------------------

	DECLARE notes3_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	 WHERE	not_type = 'TANKSZ' AND
			ntb_table = 'orderheader' AND
			nre_tablekey = @cur_ord_hdrnumber
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

-----

	--DPH PTS 22528(BEGIN)
	DECLARE notes7_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	WHERE	not_type = 'SPI' AND
			ntb_table = 'orderheader' AND
			nre_tablekey = @cur_ord_hdrnumber
	ORDER BY not_sequence

	OPEN notes7_cursor

	FETCH NEXT FROM notes7_cursor INTO @not_text


	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @special_instr = @special_instr + @not_text + '  '

		FETCH NEXT FROM notes7_cursor INTO @not_text
	END

	CLOSE notes7_cursor

	DEALLOCATE notes7_cursor

-----

	--DPH PTS 22528(BEGIN)
	DECLARE notes8_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	WHERE	not_type = 'E' AND
			ntb_table = 'orderheader' AND
			nre_tablekey = @cur_ord_hdrnumber
	ORDER BY not_sequence

	OPEN notes8_cursor

	FETCH NEXT FROM notes8_cursor INTO @not_text


	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @special_instr = @special_instr + @not_text + '  '

		FETCH NEXT FROM notes8_cursor INTO @not_text
	END

	CLOSE notes8_cursor

	DEALLOCATE notes8_cursor

-----

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

-----

--GET NOTES AND DIRECTIONS FOR FIRST LUL COMPANY (START) - DPH
select 	@tank_sizes_lul = not_text
FROM 	notes, stops
WHERE	not_type = 'TANKSZ' AND
	ntb_table = 'company' AND
	nre_tablekey = stops.cmp_id AND
	stops.stp_number = @consignee_stp_number

select	@special_instr_lul = not_text
FROM 	notes,stops,orderheader 
WHERE	not_type = 'SPI' AND
	ntb_table = 'company' AND
	nre_tablekey = stops.cmp_id AND
	stops.stp_number = @consignee_stp_number
	
select	@load_pin_lul = not_text
FROM 	notes,stops,orderheader 
WHERE	not_type = 'COMB' AND
	ntb_table = 'company' AND
	nre_tablekey = stops.cmp_id AND
	stops.stp_number = @consignee_stp_number

	UPDATE	#trips
	SET	tank_sizes = @tank_sizes + '' + @tank_sizes_lul,
		special_instr = @special_instr + '' + @special_instr_lul,
		load_pin = @load_pin + '' + @load_pin_lul
	 WHERE	ord_hdrnumber = @cur_ord_hdrnumber and
		drv_id = @cur_evt_driver1 and
		ord_destpoint = (select cmp_id
				  from stops
				  where stp_number = @consignee_stp_number)


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
select @mfh_number = isnull(legheader_active.mfh_number,999) ,@lgh_startdate= lgh_startdate,@lgh_driver1 = lgh_driver1,@stp_lghnumber = stops.lgh_number
from stops
join legheader_active on stops.lgh_number = legheader_active.lgh_number
where stops.stp_number = @lul_stp_number



WHILE @@FETCH_STATUS = 0
BEGIN
	--Do processing here
	select @page_number = @page_number + 1

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
			(SELECT	MIN(ref_number)
			   FROM	referencenumber
			  WHERE	ref_tablekey = oh.ord_hdrnumber AND
					ref_type = 'REL' AND
					ref_table = 'orderheader') realease_pickup,
			lab1.name supplier,
			(SELECT	MIN(ref_number)
			   FROM	referencenumber
			  WHERE	ref_tablekey = oh.ord_hdrnumber AND
					ref_type = 'BL#' AND
					ref_table = 'orderheader') shipper_bl,
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
			@varchar2000 tank_sizes,
			@box5title ord_heading,
			oh.ord_revtype3,
			lab2.name,
			oh.ord_startdate,
			--consignee.cmp_directions,
			'',
			@cur_evt_driver1,
			@box1title,
			@box2title,
			--DPH PTS 22528
			@page_number,
			getdate(),
			ord_dest_earliestdate,
			ord_dest_latestdate,
			ord_originpoint,
			ord_destpoint,
			@varchar2000 special_instr,
			@rack_id2,
			@rack_name_2,
			@rack_address1_2,
			@rack_ctstzip_2,
			@rack_phone_2,
			@fgt_refnum,
			@cmp_misc1,
			@varchar2000 load_pin,
			oh.ord_miscqty,
			'*' + rtrim(ltrim(oh.ord_number)) + '*' ord_number_barcode,
			--DPH PTS 22528
			oh.ord_hdrnumber,
             @lgh_driver1,  --            '' lgh_driver1, 
        	@mfh_number,   --	0  lgh_mfh_number, 
        	@lgh_startdate,  --	'' lgh_startdate ,
            @stp_lghnumber --     0  lgh_number   
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
	select 	@tank_sizes_lul = not_text
	FROM 	notes, stops
	WHERE	not_type = 'TANKSZ' AND
		ntb_table = 'company' AND
		nre_tablekey = stops.cmp_id AND
		stops.stp_number = @lul_stp_number

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

	--Update Notes
	UPDATE	#trips
	SET	tank_sizes = @tank_sizes + '' + @tank_sizes_lul,
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
/*
--PTS# 32164 ILB 06/02/2006
INSERT INTO #lgh
    SELECT lgh.lgh_driver1,
           isnull(lgh.mfh_number,999), --35028  
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
       #trips.lgh_mfh_number = #lgh.lgh_mfh_number, 
       #trips.lgh_startdate  = #lgh.lgh_startdate,
       #trips.lgh_number     = #lgh.lgh_number
  from #trips, #lgh
 where #trips.ord_hdrnumber = #lgh.ord_hdrnumber and
       #trips.drv_id = #lgh.lgh_driver1
--PTS# 32164 ILB 06/02/2006
*/
/* 37517 customer wants order by restored , was commented out*/
SELECT * FROM #trips ORDER BY tractor,driver,ord_startdate

DROP TABLE #trips
GO
GRANT EXECUTE ON  [dbo].[d_drvdelticket_format02_sp] TO [public]
GO
