SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_prnt_waybill_sp    Script Date: 6/1/99 11:54:53 AM ******/
create proc [dbo].[d_prnt_waybill_sp] (@ordnumber char(12))

as

--Declaration and initialization of variables
DECLARE @char18  VarChar(20),
	@char11  datetime,
	@char10  VarChar(15),
	@char9	 varChar(40),
        @char6   Varchar(50),
	@char15  real,
        @char12  int,
	@char13  varchar(255),
	@char14  Varchar(100),
	@char16  Varchar(50),
        @char17  varChar(50),
        @char8   Varchar(10),
        @char1   float,
        @char2   varchar(6),
	@maxnum  int,
	@minord  int,
        @minstp  int,
        @minnote int,
        @minfgt  int,
        @loop_cnt int,
        @total_miles real,
        @origin_date datetime,
       	@num	 int,
        @drp_bill int,
        @bills int,
        @tmp_hours real,
        @test  varchar(255),
        @test1 varchar(255),
        @test2 varchar(255),
        @test3 varchar(255),
        @cmd   varchar(15),  /*COMMODITY CODE VARIABLE*/
        @cmd1  varchar(50),  /*COMMODITY DESCRIPTION VARIABLE*/
        @cmd2  float,        /*COMMODITY QUANTITY VARIABLE*/
        @cmd3  varchar(6),   /*COMMODITY UNIT OF MEASURE VARIABLE*/
        @load_date datetime     

-- Create temporary waybill table for Printing of waybills process*/
SELECT @char10 tractor,
       @char10 trailer, 
       @char10 trailer2,
       @char12 origin_id,
       @char17 origin_st,
       @char9  origin,
       @char9  final_destination,
       orderheader.ord_revtype1  branch,       
       @char11 arrival,       
       orderheader.ord_revtype1  control_br,
       @char15 miles_km,       
       @char15 hours,
       orderheader.ord_number way_no,
       @char8 waybill_no,
       orderheader.ord_shipper shipper_id,
       @char9  shipper_name,
       @char6  shipper_address,
       @char9  shipper_city_state,
       stops.cmp_id consignee_id,
       stops.cmp_name  consignee_name,
       @char6  consignee_address,
       @char9  consignee_city_state,
       orderheader.ord_billto freight_paid_by_id,
       @char9  freight_paid_by,       @char9  origin_pt,
       @char12 freight_load_id,
       @char17 freight_load_state,
       @char9  load_pt,
       @char12 freight_unld_id,
       @char17 freight_unld_state,
       @char9  freight_unld_pt, 
       @char12 final_dest_id,       @char17 final_dest_state,
       @char9  final_dest,
       orderheader.ord_hdrnumber ord_hdrnumber,
       @char8 shipper_order_number_po,
       @char8 shipper_order_number_pick,
       @char8 shipper_bl_number,
       @char10 no_bills_this_load,
       stops.stp_number stp_number,
       @char18 driver_id,
       @char18 driver_alt_id,
       @char13 driver_instructions,
       @char13 delivery_instructions,
       @load_date load_date,
       @char10  cmd_code1,
       @char10  cmd_code2,
       @char10  cmd_code3,
       @char10  cmd_code4,
       @char9   cmd_desc1,
       @char9   cmd_desc2,
       @char9   cmd_desc3,
       @char9   cmd_desc4,
       @char1   cmd_qty1,
       @char1   cmd_qty2,
       @char1   cmd_qty3,
       @char1   cmd_qty4,
       @char2   cmd_rate1,
       @char2   cmd_rate2,
       @char2   cmd_rate3,
       @char2   cmd_rate4,
       orderheader.tar_tarriffnumber rate_quote
 INTO #waybill
 FROM  stops,orderheader
 WHERE  (orderheader.ord_number = @ordnumber)
 AND (stops.ord_hdrnumber = orderheader.ord_hdrnumber)
 AND (stops.stp_type = 'DRP')      

-- DRIVER INSTRUCTIONS
DECLARE note cursor for 

SELECT notes.not_text
FROM notes
WHERE notes.nre_tablekey = @ordnumber
AND notes.ntb_table = 'orderheader'
AND (notes.not_type ='D' OR notes.not_type ='LOAD') 

open note

while 1 = 1
begin

-- &&STARTMSSQL
fetch note into @test
if @@fetch_status < 0 
break
-- &&ENDMSSQL

-- &&STARTSYBASE
-- fetch note into @test
-- if @@sqlstatus != 0
-- break
-- &&ENDSYBASE

select @test1 = @test1 + @test + ","
end

-- &&STARTMSSQL
deallocate note
-- &&ENDMSSQL

-- &&STARTSYBASE
-- deallocate cursor note
-- &&ENDSYBASE

UPDATE #waybill
	SET driver_instructions = @test1

-- DELIVERY INSTRUCTIONS

declare note1 cursor for 

SELECT notes.not_text
FROM notes
WHERE notes.nre_tablekey = @ordnumber
AND notes.ntb_table = 'orderheader'
AND notes.not_type = 'DEL'

open note1

while 1 = 1

-- &&STARTMSSQL
begin
fetch note1 into @test2
if @@fetch_status < 0 
break
-- &&ENDMSSQL

-- &&STARTSYBASE
-- begin
-- fetch note1 into @test2
-- if @@sqlstatus != 0
-- break
-- &&ENDSYBASE

select @test3 = @test3 + @test2 + ","
end

-- &&STARTMSSQL
deallocate note1
-- &&ENDMSSQL

-- &&STARTSYBASE
-- deallocate cursor note1
-- &&ENDSYBASE

UPDATE #waybill
SET delivery_instructions = @test3 

SELECT @minord = 0

WHILE (SELECT COUNT(distinct ord_hdrnumber) FROM #waybill
	   WHERE ord_hdrnumber > @minord) > 0

 BEGIN

	SELECT @minord = min (ord_hdrnumber)
	FROM #waybill
	WHERE ord_hdrnumber > @minord

-- total stop miles per order
	UPDATE #waybill
	SET miles_km = orderheader.ord_totalmiles
	FROM orderheader,#waybill
 	WHERE orderheader.ord_hdrnumber = @minord
	AND #waybill.ord_hdrnumber = @minord   	   

-- hours per order
	SELECT @tmp_hours = sum(ord_loadtime + ord_unloadtime + ord_drivetime)
	FROM orderheader
	WHERE orderheader.ord_hdrnumber = @minord 
		
	UPDATE #waybill	SET hours = @tmp_hours
	FROM /*orderheader,*/ #waybill
	WHERE #waybill.ord_hdrnumber = @minord
	
-- order reference numbers from the orderheader table (ex. Reference# or B/L# or PO#)
	UPDATE #waybill
	SET shipper_order_number_po = referencenumber.ref_number
	FROM referencenumber, #waybill
	WHERE referencenumber.ref_tablekey = @minord
	AND referencenumber.ref_type = 'PO'
	AND referencenumber.ref_table = 'orderheader'
	AND #waybill.ord_hdrnumber = @minord

	UPDATE #waybill
	SET shipper_order_number_pick = referencenumber.ref_number
	FROM referencenumber, #waybill
	WHERE referencenumber.ref_tablekey = @minord
	AND referencenumber.ref_type = 'SO'
	AND referencenumber.ref_table = 'orderheader'
	AND #waybill.ord_hdrnumber = @minord

	UPDATE #waybill
	SET shipper_bl_number = referencenumber.ref_number
	FROM referencenumber, #waybill
	WHERE referencenumber.ref_tablekey = @minord
	AND referencenumber.ref_type = 'REF'
	AND referencenumber.ref_table = 'orderheader'
	AND #waybill.ord_hdrnumber = @minord

 -- shipper address for the order
	UPDATE #waybill
	SET shipper_name = company.cmp_name
	FROM company
	WHERE #waybill.shipper_id = company.cmp_id
	AND #waybill.ord_hdrnumber = @minord
      
	UPDATE #waybill
	SET shipper_address = company.cmp_address1
	FROM company,#waybill
	WHERE #waybill.shipper_id = company.cmp_id
	AND #waybill.ord_hdrnumber = @minord

	UPDATE #waybill
	SET shipper_city_state = company.cty_nmstct + ' ,' + company.cmp_zip
	FROM company,#waybill
	WHERE #waybill.shipper_id = company.cmp_id
	AND #waybill.ord_hdrnumber = @minord	
       
-- find first freight stop
	UPDATE #waybill
	SET freight_load_id = stops.stp_city,
		freight_load_state = stops.stp_state,
		load_date = stops.stp_arrivaldate
	FROM stops
	WHERE stops.ord_hdrnumber = @minord
	AND #waybill.ord_hdrnumber = @minord
	AND stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
					FROM stops, eventcodetable
					WHERE stops.ord_hdrnumber = @minord
					AND stops.stp_type = "PUP"
					AND stops.stp_event = eventcodetable.abbr
					AND eventcodetable.ect_billable = "Y")

	UPDATE #waybill
	SET load_pt = city.cty_name + "," + #waybill.freight_load_state,
		arrival = load_date
	FROM city, #waybill
	WHERE #waybill.ord_hdrnumber = @minord
	AND #waybill.freight_load_id = city.cty_code
     
-- find last freight stop
	UPDATE #waybill
	SET freight_unld_id = stops.stp_city,
		freight_unld_state = stops.stp_state
	FROM stops
 	WHERE stops.ord_hdrnumber = @minord
	AND #waybill.ord_hdrnumber = @minord
	AND stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
					FROM stops, eventcodetable
					WHERE stops.ord_hdrnumber = @minord
					AND stops.stp_type = "DRP"
					AND stops.stp_event = eventcodetable.abbr
					AND eventcodetable.ect_billable = "Y")

	UPDATE #waybill
	SET freight_unld_pt = city.cty_name + "," + #waybill.freight_unld_state
	FROM city, #waybill
	WHERE #waybill.ord_hdrnumber = @minord
	AND #waybill.freight_unld_id = city.cty_code

-- find origin stop	
IF (SELECT COUNT(*)
		FROM stops
		WHERE stops.ord_hdrnumber = @minord
		AND stops.stp_mfh_sequence = 1
		AND stops.stp_type = "NONE") > 0

		BEGIN
		UPDATE #waybill
		SET origin_id = stops.stp_city,
			origin_st = stops.stp_state
		FROM stops
		WHERE stops.ord_hdrnumber = @minord
		AND #waybill.ord_hdrnumber = @minord
		AND stops.stp_mfh_sequence = 1
		AND stops.stp_type = "NONE"

		UPDATE #waybill
		SET origin_pt = city.cty_name + "," + #waybill.origin_st,
			origin = city.cty_name
		FROM city, #waybill
		WHERE #waybill.ord_hdrnumber = @minord
		AND #waybill.origin_id = city.cty_code

		END

	ELSE

	BEGIN

	UPDATE #waybill
	SET #waybill.origin_pt = #waybill.load_pt

	UPDATE #waybill
	SET #waybill.origin = city.cty_name
	FROM city,#waybill
	WHERE #waybill.ord_hdrnumber = @minord
	AND #waybill.freight_load_id = city.cty_code

	END
  
  -- find destination stop  
	SELECT @maxnum = max(stp_mfh_sequence)
	FROM stops
	WHERE stops.ord_hdrnumber = @minord
	AND stops.stp_type = "NONE"

       IF (SELECT COUNT(*)
		FROM stops
		WHERE stops.ord_hdrnumber = @minord
		AND stops.stp_mfh_sequence = @maxnum
		AND stops.stp_type = "NONE") > 0

		BEGIN

		UPDATE #waybill
		SET final_dest_id = stops.stp_city,
			final_dest_state = stops.stp_state
		FROM stops
		WHERE stops.ord_hdrnumber = @minord
		AND #waybill.ord_hdrnumber = @minord
		AND stops.stp_mfh_sequence = @maxnum
		AND stops.stp_type = "NONE"

		UPDATE #waybill
		SET final_dest = city.cty_name + "," + #waybill.final_dest_state,
			origin = city.cty_name
		FROM city, #waybill
		WHERE #waybill.ord_hdrnumber = @minord
		AND #waybill.final_dest_id = city.cty_code
		
		END

	ELSE

	BEGIN

	UPDATE #waybill
	SET #waybill.final_dest = #waybill.freight_unld_pt

	UPDATE #waybill
	SET #waybill.final_destination = city.cty_name
	FROM city,#waybill
	WHERE #waybill.ord_hdrnumber = @minord
	AND #waybill.freight_unld_id = city.cty_code

	END		   

END

-- Update specific fields based on the stop number
   SELECT @minstp = 0
   select @bills = 0

   WHILE (SELECT COUNT(stp_number)
		FROM #waybill
		WHERE stp_number > @minstp) > 0

	BEGIN

	SELECT @minstp = min(stp_number)
	FROM #waybill
	WHERE stp_number > @minstp

	SELECT @bills = @bills + 1

-- consignee name and address
--	UPDATE #waybill
--	SET consignee_name = company.cmp_name
--	FROM company
--	WHERE #waybill.consignee_id = company.cmp_id
--	AND #waybill.stp_number = @minstp
	   
	UPDATE #waybill
	SET consignee_address = company.cmp_address1
	FROM company,#waybill
	WHERE #waybill.consignee_id = company.cmp_id
	AND #waybill.stp_number = @minstp

	UPDATE #waybill
	SET consignee_city_state = company.cty_nmstct + ' ,' + company.cmp_zip
	FROM company,#waybill	WHERE #waybill.consignee_id = company.cmp_id
	AND #waybill.stp_number = @minstp
	
-- driver id per stop from event
	UPDATE #waybill
	SET driver_id = event.evt_driver1
	FROM event, #waybill
	WHERE #waybill.stp_number = @minstp
	AND event.stp_number = @minstp

-- driver alt id per stop from manpowerprofile
	UPDATE #waybill
	SET driver_alt_id = manpowerprofile.mpp_otherid
	FROM manpowerprofile, #waybill
	WHERE #waybill.stp_number = @minstp
	AND manpowerprofile.mpp_id = #waybill.driver_id   			
 
-- freight paid by per stop
	UPDATE #waybill
	SET freight_paid_by = company.cmp_name
	FROM stops,company,#waybill
	WHERE stops.stp_number = @minstp
	AND #waybill.stp_number = @minstp
	AND #waybill.freight_paid_by_id = company.cmp_id

-- pup_id,tractor,trailer per stop from the event table
	UPDATE #waybill
	SET trailer = event.evt_trailer1,
		trailer2 = event.evt_trailer2,
		tractor = event.evt_tractor
	FROM event, #waybill
	WHERE event.stp_number = @minstp
	AND #waybill.stp_number = @minstp

-- find no. of bills this load
	SELECT @drp_bill = COUNT(distinct stp_number)                   
	FROM #waybill

	IF @drp_bill > 1

		BEGIN

		UPDATE #waybill
		SET no_bills_this_load = convert(varchar(10), @bills) + "of" + convert(varchar(10), @drp_bill),
			waybill_no = convert(varchar(10), @bills) + "-" + #waybill.way_no
		FROM #waybill
		WHERE #waybill.stp_number = @minstp

		END

	IF @drp_bill = 1

		BEGIN

		UPDATE #waybill
		SET no_bills_this_load = convert(varchar(10), @bills) + "of" + convert(varchar(10), @drp_bill),
			waybill_no = convert(varchar(10), @bills) + "-" + #waybill.way_no
		FROM #waybill
		WHERE #waybill.stp_number = @minstp

		END
	
-- COMMODITY CURSOR
declare cmd cursor for 

SELECT freightdetail.cmd_code
FROM freightdetail
WHERE freightdetail.stp_number = @minstp

open cmd

SELECT @loop_cnt = 0

WHILE 1 = 1
BEGIN

-- &&STARTMSSQL
fetch cmd into @cmd
if @@fetch_status < 0 
 break
-- &&ENDMSSQL

-- &&STARTSYBASE
-- fetch cmd into @cmd
-- if @@sqlstatus != 0
-- break
-- &&ENDSYBASE

SELECT @loop_cnt = @loop_cnt + 1

IF @loop_cnt = 1
	UPDATE #waybill
	SET cmd_code1 = @cmd
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 2
	UPDATE #waybill
	SET cmd_code2 = @cmd
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 3
	UPDATE #waybill
	SET cmd_code3 = @cmd
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 4
	UPDATE #waybill
	SET cmd_code4 = @cmd
	WHERE #waybill.stp_number = @minstp

END

-- &&STARTMSSQL
deallocate cmd
-- &&ENDMSSQL

-- &&STARTSYBASE
-- deallocate cursor cmd
-- &&ENDSYBASE

-- DESCRIPTION CURSOR
declare cmd1 cursor for 

SELECT freightdetail.fgt_description
FROM freightdetail
WHERE freightdetail.stp_number = @minstp

open cmd1

SELECT @loop_cnt = 0

WHILE 1 = 1
BEGIN

-- &&STARTMSSQL
fetch cmd1 into @cmd1
if @@fetch_status < 0 
 break
-- &&ENDMSSQL

-- &&STARTSYBASE
-- fetch cmd1 into @cmd1
-- if @@sqlstatus != 0
-- break
-- &&ENDSYBASE

SELECT @loop_cnt = @loop_cnt + 1

IF @loop_cnt = 1
	UPDATE #waybill
	SET cmd_desc1 = @cmd1
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 2
	UPDATE #waybill
	SET cmd_desc2 = @cmd1
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 3
	UPDATE #waybill
	SET cmd_desc3 = @cmd1
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 4
	UPDATE #waybill
	SET cmd_desc4 = @cmd1
	WHERE #waybill.stp_number = @minstp

END

-- &&STARTMSSQL
deallocate cmd1
-- &&ENDMSSQL

-- &&STARTSYBASE
-- deallocate cursor cmd1
-- &&ENDSYBASE

-- QUANTITY CURSOR
declare cmd2 cursor for 

SELECT freightdetail.fgt_quantity
FROM freightdetail
WHERE freightdetail.stp_number = @minstp

open cmd2

SELECT @loop_cnt = 0

WHILE 1 = 1

BEGIN

-- &&STARTMSSQL
fetch cmd2 into @cmd2
if @@fetch_status < 0 
 break
-- &&ENDMSSQL

-- &&STARTSYBASE
-- fetch cmd2 into @cmd2
-- if @@sqlstatus != 0
-- break
-- &&ENDSYBASE

SELECT @loop_cnt = @loop_cnt + 1

IF @loop_cnt = 1
	UPDATE #waybill
	SET cmd_qty1 = @cmd2
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 2
	UPDATE #waybill
	SET cmd_qty2 = @cmd2
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 3
	UPDATE #waybill
	SET cmd_qty3 = @cmd2
	WHERE #waybill.stp_number = @minstp
IF @loop_cnt = 4
	UPDATE #waybill
	SET cmd_qty4 = @cmd2
	WHERE #waybill.stp_number = @minstp

END

-- &&STARTMSSQL
deallocate cmd2
-- &&ENDMSSQL

-- &&STARTSYBASE
-- deallocate cursor cmd2
-- &&ENDSYBASE

-- UNIT OF MEASURE CURSOR
declare cmd3 cursor for

SELECT freightdetail.fgt_unit
FROM freightdetail
where freightdetail.stp_number = @minstp

open cmd3

select @loop_cnt = 0

WHILE 1 = 1

BEGIN

-- &&STARTMSSQL
fetch cmd3 into @cmd3
if @@fetch_status < 0
 break
-- &&ENDMSSQL

-- &&STARTSYBASE
-- fetch cmd3 into @cmd3
-- if @@sqlstatus != 0
-- break
-- &&ENDSYBASE

SELECT @loop_cnt= @loop_cnt + 1

IF @loop_cnt = 1
	UPDATE #waybill
	SET cmd_rate1 = @cmd3
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 2
	UPDATE #waybill
	SET cmd_rate2 = @cmd3
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 3
	UPDATE #waybill
	SET cmd_rate3 = @cmd3
	WHERE #waybill.stp_number = @minstp

IF @loop_cnt = 4
	UPDATE #waybill
	SET cmd_rate4 = @cmd3
	WHERE #waybill.stp_number = @minstp

END

-- &&STARTMSSQL
deallocate cmd3
-- &&ENDMSSQL

-- &&STARTSYBASE
-- deallocate cursor cmd3
-- &&ENDSYBASE

END

SELECT tractor,
       trailer,
       trailer2,
       origin,
       final_destination,
       branch,
       arrival,
       control_br,
       miles_km,
       hours,
       waybill_no,
       shipper_name,
       shipper_address,
       shipper_city_state,
       consignee_name,
       consignee_address,
       consignee_city_state,
       freight_paid_by,
       origin_pt,
       load_pt,
       final_dest,
       shipper_order_number_po,
       shipper_order_number_pick,
       shipper_bl_number,
       no_bills_this_load,
       ord_hdrnumber,
       stp_number,       driver_id,
       driver_alt_id,
       driver_instructions,
       delivery_instructions,
       cmd_code1,
       cmd_code2,
       cmd_code3,
       cmd_code4,
       cmd_desc1,
       cmd_desc2,
       cmd_desc3,
       cmd_desc4,
       cmd_qty1,
       cmd_qty2,
       cmd_qty3,
       cmd_qty4,
       cmd_rate1,
       cmd_rate2,
       cmd_rate3,
       cmd_rate4,
       rate_quote
FROM #waybill
ORDER BY waybill_no

GO
GRANT EXECUTE ON  [dbo].[d_prnt_waybill_sp] TO [public]
GO
