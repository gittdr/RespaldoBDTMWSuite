SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE    PROCEDURE [dbo].[d_drvdelticket_format01_sp]
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
DECLARE	@varchar2000	VARCHAR(2000),
		@not_number		INTEGER,
		@driver			VARCHAR(90),
		@ord_number		VARCHAR(12),
		@not_text		VARCHAR(254),
		@loading_instr	VARCHAR(2000),
		@delivery_instr	VARCHAR(2000),
		@tank_sizes		VARCHAR(2000),
		@drv_id         VARCHAR(8),
		@bill_to        VARCHAR(8),
		@directions     Varchar(2000),
		@cmp_directions Varchar(2000)
/* 35028 did not work
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
	header				VARCHAR(40)		NOT NULL,
	corp_address1		VARCHAR(30)		NOT NULL,
	corp_ctstzip		VARCHAR(30) 	NOT NULL,
	remit_address1		VARCHAR(30) 	NOT NULL,
	remit_ctstzip		VARCHAR(30)		NOT NULL,
	disp1				VARCHAR(30) 	NOT NULL,
	disp1_phone			VARCHAR(30) 	NOT NULL,
	disp1_fax			VARCHAR(30) 	NOT NULL,
	disp2				VARCHAR(30) 	NOT NULL,
	disp2_phone			VARCHAR(30) 	NOT NULL,
	disp2_fax			VARCHAR(30) 	NOT NULL,
	dispatch_date		DATETIME		NOT NULL,
	ord_number			VARCHAR(12) 	NOT NULL,
	release_pickup		VARCHAR(30) 	NULL,
	supplier			VARCHAR(20) 	NULL,
	shipper_bl			VARCHAR(30) 	NULL,
	tractor				VARCHAR(8)		NULL,
	trailer				VARCHAR(13) 	NULL,
	driver				VARCHAR(90)		NULL,
	bill_to				VARCHAR(8)		NULL,
	rack_name			VARCHAR(100)	NULL,
	rack_address1		VARCHAR(50)		NULL,
	rack_ctstzip		VARCHAR(40)		NULL,
	rack_phone			VARCHAR(20)		NULL,
	consignee_name		VARCHAR(100)	NULL,
	consignee_address1	VARCHAR(50)		NULL,
	consignee_ctstzip	VARCHAR(40)		NULL,
	consignee_phone		VARCHAR(20)		NULL,
	product1			VARCHAR(60)		NULL,
	quantity1			INTEGER			NULL,
	product2			VARCHAR(60)		NULL,
	quantity2			INTEGER			NULL,
	product3			VARCHAR(60)		NULL,
	quantity3			INTEGER			NULL,
	product4			VARCHAR(60)		NULL,
	quantity4			INTEGER			NULL,
	product5			VARCHAR(60)		NULL,
	quantity5			INTEGER			NULL,
	delivery_date		VARCHAR(254)	NULL,
	loading_instr		VARCHAR(2000)	NULL,
	delivery_instr		VARCHAR(2000)	NULL,
	tank_sizes			VARCHAR(2000)		NULL,
	ord_heading			VARCHAR(30)		NOT NULL,
	ord_revtype2            VARCHAR(6)	NULL ,
	ord_revtype_name        varchar(20)     null ,
	ord_startdate           datetime        null ,
	cmp_directions          VARCHAR(2000)   NULL,
	drv_id                  VARCHAR(8)      NULL,
	box1title		VARCHAR(25)     NULL,
	box2title		VARChAR(25)     NULL,
	ord_hdrnumber           INT		NULL,
        lgh_driver1             VARCHAR(8)      NULL, 
        lgh_mfh_number          INT             NULL, 
        lgh_startdate           DATETIME        NULL,
        lgh_number              INT             NULL)

--JYANG create a temp table to hold the ord_hdrnumber based on event and stop.
--so could handle split trips
select distinct event.ord_hdrnumber,evt_driver1,lgh_number
into   #temp_ord
from   event
join stops s on event.stp_number = s.stp_number
where  @drv in ('UNKNOWN',  event.evt_driver1) and
	evt_startdate  >= @startdate AND
	evt_enddate <= @enddate and
	event.ord_hdrnumber <> 0 
group by event.ord_hdrnumber,evt_driver1,lgh_number

	
SELECT @status = ',' + LTRIM(RTRIM(ISNULL(@status, ''))) + ','

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
			/*(SELECT cmd.cmd_code
			   FROM	freightdetail fd,
					commodity cmd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 1) AND
					fd.cmd_code = cmd.cmd_code) product1,
			(SELECT	fgt_quantity
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 1)) quantity1,
			(SELECT	cmd.cmd_name
			   FROM	freightdetail fd,
					commodity cmd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2) AND
					fd.cmd_code = cmd.cmd_code) product2,
			(SELECT	fgt_quantity
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2)) quantity2,
			(SELECT	cmd.cmd_name
			   FROM	freightdetail fd,
					commodity cmd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3) AND
					fd.cmd_code = cmd.cmd_code) product3,
			(SELECT	fgt_quantity
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) quantity3,
			(SELECT	cmd.cmd_name
			   FROM	freightdetail fd,
					commodity cmd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4) AND
					fd.cmd_code = cmd.cmd_code) product4,
			(SELECT	fgt_quantity
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4)) quantity4,
			(SELECT	cmd.cmd_name
			   FROM	freightdetail fd,
					commodity cmd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 5) AND
					fd.cmd_code = cmd.cmd_code) product5,
			(SELECT	fgt_quantity
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT	MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = (SELECT	MIN(stp_number)
									   						FROM	stops
														   WHERE	ord_hdrnumber = oh.ord_hdrnumber AND
																	stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 5)) quantity5,*/
--jyang client required to return cmd_code instead of cmd_name and request return quantity which is not only from the fgt_quantity
			 (SELECT fd.cmd_code
			   FROM	freightdetail fd
			   WHERE fd.fgt_number = (SELECT MIN(fgt_number)
						  FROM	freightdetail
						  WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								      FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 1)) product1,
			(SELECT	quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
					      FROM	freightdetail
					      WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								      FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 1)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
				        	   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								      FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2) ) product2,
			(SELECT	quantity2 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
									FROM	freightdetail
								   WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								     FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 2)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
						 FROM	freightdetail
						 WHERE	stp_number = (SELECT	MIN(stops.stp_number)
							      		FROM	stops
						                       WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) product3,
			(SELECT	quantity3 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
						FROM	freightdetail
						WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								      FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 3)) ,
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
									   FROM	freightdetail
									  WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								     FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4) ) product4,
			(SELECT	quantity4 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT MIN(fgt_number)
						FROM	freightdetail
					       WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								      FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
											cmd_code <> 'UNKNOWN' AND
											fgt_sequence = 4)) ,
			
			(SELECT	fd.cmd_code
			   FROM	freightdetail fd
			  WHERE	fd.fgt_number = (SELECT MIN(fgt_number)
						 FROM	freightdetail
						 WHERE	stp_number = (SELECT	MIN(stops.stp_number)
						                      FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
							cmd_code <> 'UNKNOWN' AND
							fgt_sequence = 5) ) product5,
			(SELECT	quantity5 = (case when fgt_quantity > 0 then fgt_quantity else 
						case when fgt_volume >0 then fgt_volume else
						     case when fgt_weight > 0 then fgt_weight else
							case when fgt_count >0 then fgt_count else 0 end end end end)
			   FROM	freightdetail
			  WHERE	fgt_number = (SELECT	MIN(fgt_number)
						FROM	freightdetail
						WHERE	stp_number = (SELECT	MIN(stops.stp_number)
								     FROM	stops
								      WHERE	stops.ord_hdrnumber = #temp_ord.ord_hdrnumber AND
										stops.stp_type = 'DRP') AND
										cmd_code <> 'UNKNOWN' AND
										fgt_sequence = 5)),
			oh.ord_remark delivery_date,
			@varchar2000 loading_instr,
			@varchar2000 delivery_instr,
			@varchar2000 tank_sizes,
			@box5title ord_heading,
			oh.ord_revtype2,
			lab2.name,
			oh.ord_startdate,
			--consignee.cmp_directions,
			'',
			#temp_ord.evt_driver1,
			@box1title,
			@box2title,			
			oh.ord_hdrnumber,
             l.lgh_driver1 ,  --           '' lgh_driver1, 
        	l.mfh_number,  --	0  lgh_mfh_number, 
        	l.lgh_startdate,  --	'' lgh_startdate ,
            #temp_ord.lgh_number --            0  lgh_number			
	  FROM	        orderheader oh,
			company rack,
			company consignee,
			city rackcity,
			city consigneecity,
			labelfile lab1,
			labelfile lab2,
			manpowerprofile mpp,
			#temp_ord,
            legheader_active l
	 WHERE	        oh.ord_shipper = rack.cmp_id AND
			oh.ord_consignee = consignee.cmp_id AND
			rack.cmp_city = rackcity.cty_code AND
			consignee.cmp_city = consigneecity.cty_code AND
			lab1.abbr = oh.ord_revtype4 AND
			lab1.labeldefinition = 'revtype4' AND
			mpp.mpp_id =  #temp_ord.evt_driver1 AND
			CHARINDEX(',' + oh.ord_status + ',', @status) > 0 AND
			--(@drv = 'UNKNOWN' OR ord_driver1 = @drv) AND
			@revtype1 in( 'UNK' ,ord_revtype1) AND
			ord_startdate >= @startdate AND
			ord_startdate <= @enddate AND
			lab2.abbr = oh.ord_revtype2 AND
			lab2.labeldefinition = 'revtype2' and
			#temp_ord.ord_hdrnumber = oh.ord_hdrnumber 
            and #temp_ord.lgh_number = l.lgh_number

CREATE INDEX order_ind ON #trips (ord_number)

DECLARE trip_cursor CURSOR FOR 
SELECT	ord_number,drv_id,bill_to
FROM	#trips
 

OPEN trip_cursor

FETCH NEXT FROM trip_cursor INTO @ord_number,@drv_id,@bill_to

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @not_text = ''
	SELECT @loading_instr = ''
	SELECT @delivery_instr = ''
	SELECT @tank_sizes = ''
	SELECT @cmp_directions = ''
--jyang original not_type 'loadpin' is not valid. abbr in labelfile is only char(6)
	DECLARE notes1_cursor CURSOR FOR 
	SELECT	not_text
      	 FROM 	notes 
	 WHERE	not_type IN ('COMB', 'LI') AND
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
	 SELECT	not_text
      	 FROM 	notes,stops,orderheader 
	 WHERE	not_type IN ('COMB', 'LI') AND
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

	DECLARE notes2_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	 WHERE	not_type = 'DI' AND
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
	 SELECT	not_text
      	 FROM 	notes,stops,orderheader 
	 WHERE	not_type = 'DI' AND
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


	DECLARE notes3_cursor CURSOR FOR 
	SELECT	not_text
        FROM 	notes
	 WHERE	not_type = 'TANKSZ' AND
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
	 SELECT	not_text
      	 FROM 	notes,stops,orderheader 
	 WHERE	not_type = 'TANKSZ' AND
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
      	 FROM 	company,stops,orderheader
	 WHERE	stops.ord_hdrnumber = orderheader.ord_hdrnumber and
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

	UPDATE	#trips
	SET	loading_instr = @loading_instr,
		delivery_instr = @delivery_instr,
		tank_sizes = @tank_sizes,
		cmp_directions = @cmp_directions
	 WHERE	ord_number = @ord_number and
		drv_id = @drv_id

	FETCH NEXT FROM trip_cursor INTO @ord_number,@drv_id,@bill_to
END

CLOSE trip_cursor

DEALLOCATE trip_cursor
/*  35028 does not work fixed above
--PTS# 32164 ILB 06/02/2006
INSERT INTO #lgh
    SELECT lgh.lgh_driver1,
           isnull(lgh.mfh_number,999),  --35028
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
SELECT * FROM #trips ORDER BY tractor,driver,ord_startdate

DROP TABLE #trips

GO
GRANT EXECUTE ON  [dbo].[d_drvdelticket_format01_sp] TO [public]
GO
