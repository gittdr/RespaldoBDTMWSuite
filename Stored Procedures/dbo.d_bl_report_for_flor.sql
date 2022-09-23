SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_bl_report_for_flor]
@v_ord_hdrnumber int AS

/*	-- PTS 37425 5/30/2007 jds; Add cmp_address3
*/

DECLARE
@v_counter int,
@v_stop int,
@v_stop_cmpname varchar(30),
@v_stop_cmpaddress1 varchar(40),
@v_stop_cmpaddress2 varchar(40),
@v_stop_cmpcity int,
@v_stop_cmpstate char(2),
@v_stop_cmpzip varchar(10),
@v_stop_ctynmstct varchar(25),
@v_ref_type varchar(6), 
@v_ref_number varchar(30),
@v_driver1 varchar(8),
@v_driver2 varchar(8),
@v_tractor varchar(8),
@v_trailer varchar(13),
@varchar8 varchar(8),
@varchar13 varchar(13),
@varchar60 varchar(60),
@stp_comment1 varchar(60),
@stp_comment2 varchar(60),
@stp_comment3 varchar(60),
@datetime datetime,
@stp_enddatetime datetime,
@stp_startdatetime datetime 

Select @varchar8 = '       '
Select @varchar13 = '             '
Select @varchar60 = '                                                            '

SELECT		ord_hdrnumber,
		mov_number,
		@varchar8 'ord_tractor',
		@varchar8 'ord_driver1',
		@varchar8 'ord_driver2',
		@varchar13 'ord_trailer',
		0 stop1_sequence,
		0 stop2_sequence,
		@v_stop_cmpname stop1_cmp_name,   
		@v_stop_cmpaddress1 stop1_cmp_address1,   
        	@v_stop_cmpaddress2 stop1_cmp_address2,   
		0 stop1_cmp_city,
		@v_stop_cmpstate stop1_cmp_state,
		@v_stop_cmpzip stop1_cmp_zip,
		@v_stop_ctynmstct stop1_cty_nmstct,
		@v_stop_cmpname stop2_cmp_name,   
		@v_stop_cmpaddress1 stop2_cmp_address1,   
        	@v_stop_cmpaddress2 stop2_cmp_address2,   
		0 stop2_cmp_city,
		@v_stop_cmpstate stop2_cmp_state,
		@v_stop_cmpzip stop2_cmp_zip,
		@v_stop_ctynmstct stop2_cty_nmstct,
		@v_ref_type load_number_ref_type,
		@v_ref_number load_number,
		@v_ref_type shiptk_ref_type,
		@v_ref_number shiptk_number,
		@v_ref_type supp_ref_type,
		@v_ref_number supp_number,
		@v_ref_type term_ref_type,
		@v_ref_number term_number,
		@v_ref_type ref_type1,
		@v_ref_number ref_number1,
		@v_ref_type ref_type2,
		@v_ref_number ref_number2,
		@v_ref_type ref_type3,
		@v_ref_number ref_number3,
		@v_ref_type shiptk_type2,
		@v_ref_number shiptk_number2,
		@v_ref_type shiptk_type3,
		@v_ref_number shiptk_number3,
		@v_ref_type ref_type6,
		@v_ref_number ref_number6,
		@datetime 'lgh_enddate',
		@datetime 'lgh_startdate',
		@varchar60 'stp_comment1', 		
		@varchar60 'stp_comment2', 
		@varchar60 'stp_comment3'
INTO		#stop_infotemp
FROM		orderheader
WHERE		ord_hdrnumber = @v_ord_hdrnumber

SELECT 		orderheader.ord_hdrnumber, 
		stops.stp_sequence 
INTO		#stops_percriteria
FROM		orderheader,
		legheader,
		stops
WHERE		(orderheader.ord_hdrnumber = @v_ord_hdrnumber) AND 
		(orderheader.ord_hdrnumber = stops.ord_hdrnumber) AND
		(orderheader.mov_number = legheader.mov_number) AND
		(stops.stp_event IN ('LUL', 'DUL')) AND
		(stops.stp_number <> legheader.stp_number_start) AND
		(stops.stp_number <> legheader.stp_number_end)
ORDER BY	stops.stp_sequence


SELECT 		@stp_comment1 = stp_comment
FROM		stops  
WHERE		stops.ord_hdrnumber = @v_ord_hdrnumber AND
		stops.stp_mfh_sequence = (	SELECT 	MAX(stp_mfh_sequence)
						FROM	stops
						WHERE	ord_hdrnumber = @v_ord_hdrnumber AND
							stp_type = 'DRP')

SELECT 		@v_ord_hdrnumber = ord_hdrnumber, 
		@v_stop = MIN(stp_sequence)
FROM		#stops_percriteria
GROUP BY	ord_hdrnumber

SELECT 		@v_stop_cmpname = company.cmp_name,
		@v_stop_cmpaddress1 = company.cmp_address1,
		@v_stop_cmpaddress2 = company.cmp_address2,
		@v_stop_cmpcity = company.cmp_city,
		@v_stop_cmpstate = company.cmp_state,
		@v_stop_cmpzip = company.cmp_zip, 
		@v_stop_ctynmstct = company.cty_nmstct,
		@stp_comment2 = stops.stp_comment
FROM		orderheader,
		stops,
		company
WHERE		(orderheader.ord_hdrnumber = @v_ord_hdrnumber) AND
		(orderheader.ord_hdrnumber = stops.ord_hdrnumber) AND
		(stops.cmp_id = company.cmp_id) AND
		(stops.stp_sequence = @v_stop) 


-- Set the driver tractor and trailer fields
SELECT	@v_driver1 = IsNull(lh.lgh_driver1, ''),
	@v_driver2 = IsNull(lh.lgh_driver2, ''),
	@v_tractor = IsNull(lh.lgh_tractor, ''),
	@v_trailer = IsNull(lh.lgh_primary_trailer, ''),
	@stp_enddatetime  = IsNull(oh.ord_dest_latestdate, '')
FROM	legheader lh, orderheader oh
WHERE	oh.ord_hdrnumber = @v_ord_hdrnumber AND
	oh.mov_number = lh.mov_number AND
	lh.lgh_number = (SELECT	MIN(lh2.lgh_number)
			 FROM	legheader lh2
			 WHERE	lh2.mov_number = oh.mov_number)

-- Set the Scheduled delivery time earliest value
SELECT	@stp_startdatetime  = MIN(IsNull(stops.stp_schdtearliest , '19500101 00:00'))
FROM	stops
WHERE	stops.ord_hdrnumber = @v_ord_hdrnumber AND
	stops.stp_type = 'DRP'
					

-- Update the work table with the driver/tractor/trailer info
UPDATE	  	#stop_infotemp
SET		ord_driver1 = ISNULL(@v_driver1, ''),
		ord_driver2 = ISNULL(@v_driver2, ''),
		ord_tractor = ISNULL(@v_tractor, ''),
		ord_trailer = ISNULL(@v_trailer, ''),
		lgh_startdate = @stp_startdatetime, 
		lgh_enddate = @stp_enddatetime,
		stp_comment1 = @stp_comment1,
		stp_comment2 = @stp_comment2 
WHERE		ord_hdrnumber = @v_ord_hdrnumber

	
-- Set the additional stop off information
UPDATE	  	#stop_infotemp
SET		stop1_sequence = ISNULL(@v_stop, 0),
		stop1_cmp_name = ISNULL(@v_stop_cmpname, ''),
		stop1_cmp_address1 = ISNULL(@v_stop_cmpaddress1, ''),
		stop1_cmp_address2 = ISNULL(@v_stop_cmpaddress2, ''),
		stop1_cmp_city = ISNULL(@v_stop_cmpcity, 0),
		stop1_cmp_state = ISNULL(@v_stop_cmpstate, ''),
		stop1_cmp_zip = ISNULL(@v_stop_cmpzip, ''),
		stop1_cty_nmstct = ISNULL(@v_stop_ctynmstct, '')
WHERE		ord_hdrnumber = @v_ord_hdrnumber


SELECT @v_stop = -1

SELECT 		@v_ord_hdrnumber = #stops_percriteria.ord_hdrnumber, 
		@v_stop = MIN(stp_sequence)
FROM		#stops_percriteria, #stop_infotemp
WHERE		(#stops_percriteria.ord_hdrnumber = #stop_infotemp.ord_hdrnumber) AND
		(#stops_percriteria.ord_hdrnumber = @v_ord_hdrnumber) AND
		(#stops_percriteria.stp_sequence > #stop_infotemp.stop1_sequence)
GROUP BY	#stops_percriteria.ord_hdrnumber
ORDER BY	#stops_percriteria.ord_hdrnumber

SELECT @v_stop_cmpname = ''
SELECT @v_stop_cmpaddress1 = ''
SELECT @v_stop_cmpaddress2 = ''
SELECT @v_stop_cmpcity = -1
SELECT @v_stop_cmpstate = ''
SELECT @v_stop_cmpzip = ''
SELECT @v_stop_ctynmstct = ''

SELECT	 	@v_stop_cmpname = company.cmp_name,
		@v_stop_cmpaddress1 = company.cmp_address1,
		@v_stop_cmpaddress2 = company.cmp_address2,
		@v_stop_cmpcity = company.cmp_city,
		@v_stop_cmpstate = company.cmp_state,
		@v_stop_cmpzip = company.cmp_zip,
		@v_stop_ctynmstct = company.cty_nmstct,
		@stp_comment3 = stops.stp_comment
FROM		orderheader,
		stops,
		company
WHERE		(orderheader.ord_hdrnumber = @v_ord_hdrnumber) AND
		(orderheader.ord_hdrnumber = stops.ord_hdrnumber) AND
		(stops.stp_sequence = @v_stop) AND
		(stops.cmp_id = company.cmp_id)


UPDATE		#stop_infotemp
SET		stop2_sequence = ISNULL(@v_stop, 0),
		stop2_cmp_name = ISNULL(@v_stop_cmpname, ''),
		stop2_cmp_address1 = ISNULL(@v_stop_cmpaddress1, ''),

		stop2_cmp_address2 = ISNULL(@v_stop_cmpaddress2, ''),
		stop2_cmp_city = ISNULL(@v_stop_cmpcity, 0),
		stop2_cmp_state = ISNULL(@v_stop_cmpstate, ''),
		stop2_cmp_zip = ISNULL(@v_stop_cmpzip, ''),
		stop2_cty_nmstct = ISNULL(@v_stop_ctynmstct, '')

WHERE		ord_hdrnumber = @v_ord_hdrnumber

SELECT 	@v_ref_number = ''
-- Load Number
SELECT 	@v_ref_number = ISNULL(ref_number, '')
FROM	referencenumber
WHERE	(ref_tablekey = @v_ord_hdrnumber) AND
	(ref_table = 'orderheader') AND
	(ref_type = 'LOAD#')

UPDATE  #stop_infotemp
SET	load_number_ref_type = 'LOAD#',
	load_number = @v_ref_number
WHERE	ord_hdrnumber = @v_ord_hdrnumber

SELECT 	@v_ref_number = ''
-- Suppliers Number
SELECT 	@v_ref_number = ISNULL(ref_number, '')
FROM	referencenumber
WHERE	(ref_tablekey = @v_ord_hdrnumber) AND
	(ref_table = 'orderheader') AND
	(ref_type = 'SUPP')

UPDATE  #stop_infotemp
SET	supp_ref_type = 'SUPP',
	supp_number = @v_ref_number
WHERE	ord_hdrnumber = @v_ord_hdrnumber

SELECT 	@v_ref_number = ''
-- Terminal
SELECT 	@v_ref_number = ISNULL(ref_number, '')
FROM	referencenumber
WHERE	(ref_tablekey = @v_ord_hdrnumber) AND
	(ref_table = 'orderheader') AND
	(ref_type = 'TERM')

UPDATE  #stop_infotemp
SET	term_ref_type = 'TERM',
	term_number = @v_ref_number
WHERE	ord_hdrnumber = @v_ord_hdrnumber

SELECT 	@v_ref_number = ''
SELECT	@v_counter = 1
DECLARE reference_cur CURSOR FOR
	SELECT 	ISNULL(ref_type, ''),
		ISNULL(ref_number, '')
	FROM	referencenumber
	WHERE	(ref_tablekey = @v_ord_hdrnumber) AND
		(ref_table = 'orderheader') AND
		(ref_type = 'REF')
	ORDER BY ref_sequence

OPEN reference_cur

FETCH reference_cur INTO @v_ref_type, @v_ref_number
WHILE @@fetch_status= 0

	BEGIN
		IF @v_counter = 1 

			UPDATE  #stop_infotemp
			SET	ref_type1 = @v_ref_type,
				ref_number1 = @v_ref_number
			WHERE	ord_hdrnumber = @v_ord_hdrnumber
		Else if @v_counter = 2
			UPDATE  #stop_infotemp
			SET	ref_type2 = @v_ref_type,
				ref_number2 = @v_ref_number


			WHERE	ord_hdrnumber = @v_ord_hdrnumber
		Else if @v_counter = 3
			UPDATE  #stop_infotemp
			SET	ref_type3 = @v_ref_type,
				ref_number3 = @v_ref_number
			WHERE	ord_hdrnumber = @v_ord_hdrnumber
		Else
			BREAK
	
		FETCH reference_cur INTO @v_ref_type, @v_ref_number

		SELECT @v_counter = @v_counter + 1
	END

DEALLOCATE reference_cur


SELECT 	@v_ref_number = ''
SELECT	@v_counter = 1
DECLARE reference_cur CURSOR FOR
	SELECT 	ISNULL(ref_type, ''),
		ISNULL(ref_number, '')
	FROM	referencenumber
	WHERE	(ref_tablekey = @v_ord_hdrnumber) AND
		(ref_table = 'orderheader') AND
		(ref_type = 'SHIPTK')
	ORDER BY ref_sequence

OPEN reference_cur

FETCH reference_cur INTO @v_ref_type, @v_ref_number
WHILE @@fetch_status= 0

	BEGIN
		IF @v_counter = 1 

			UPDATE  #stop_infotemp
			SET	shiptk_ref_type = @v_ref_type,
				shiptk_number = @v_ref_number
			WHERE	ord_hdrnumber = @v_ord_hdrnumber
		Else if @v_counter = 2
			UPDATE  #stop_infotemp
			SET	shiptk_type2 = @v_ref_type,
				shiptk_number2 = @v_ref_number
			WHERE	ord_hdrnumber = @v_ord_hdrnumber
		Else if @v_counter = 3
			UPDATE  #stop_infotemp
			SET	shiptk_type3 = @v_ref_type,
				shiptk_number3 = @v_ref_number
			WHERE	ord_hdrnumber = @v_ord_hdrnumber
		Else
			BREAK
	
		FETCH reference_cur INTO @v_ref_type, @v_ref_number

		SELECT @v_counter = @v_counter + 1
	END

DEALLOCATE reference_cur


SELECT		orderheader.ord_hdrnumber 'ord_hdrnumber',   
	        orderheader.ord_status 'ord_status',   
	        orderheader.ord_originpoint 'ord_originpoint',   
	        orderheader.ord_destpoint 'ord_destpoint',   
	        orderheader.ord_billto 'ord_billto',
		orderheader.ord_revtype1  'rev_type1',
	        #stop_infotemp.ord_tractor 'ord_tractor',   
	        #stop_infotemp.ord_trailer 'ord_trailer',   
	        #stop_infotemp.ord_driver1 'ord_driver1',   
	        #stop_infotemp.ord_driver2 'ord_driver2',
		orderheader.ord_remark 'ord_remark',
		orderheader.ord_reftype 'ord_reftype',
		orderheader.ord_refnum 'ord_refnum',
		orderheader.ord_origin_earliestdate 'ord_startdate',
		#stop_infotemp.load_number_ref_type 'load_type',
		#stop_infotemp.load_number 'load_number',
		#stop_infotemp.shiptk_ref_type 'shiptk_type',
		#stop_infotemp.shiptk_number 'shiptk_number',
		#stop_infotemp.supp_ref_type 'supp_type',
		#stop_infotemp.supp_number 'supp_number',
		#stop_infotemp.term_ref_type 'term_type',
		#stop_infotemp.term_number 'term_number',
		#stop_infotemp.ref_type1 'ref_type1',
		#stop_infotemp.ref_number1 'ref_number1',
		#stop_infotemp.ref_type2 'ref_type2',
		#stop_infotemp.ref_number2 'ref_number2',
		#stop_infotemp.ref_type3 'ref_type3',
		#stop_infotemp.ref_number3 'ref_number3',
		#stop_infotemp.shiptk_type2 'shiptk_type2',
		#stop_infotemp.shiptk_number2 'shiptk_number2',
		#stop_infotemp.shiptk_type3 'shiptk_type3',
		#stop_infotemp.shiptk_number3 'shiptk_number3',
		#stop_infotemp.ref_type6 'ref_type6',
		#stop_infotemp.ref_number6 'ref_number6',
		company_a.cmp_name 'o_name',   
	        company_a.cmp_address1 'o_address1',   
	        company_a.cmp_address2 'o_address2',   
	        company_a.cmp_city 'o_city',   
	        company_a.cmp_state 'o_state',   
	        company_a.cmp_zip 'o_zip',   
	        company_a.cty_nmstct 'o_cty_nmstct',
		company_b.cmp_misc3 'cmp_misc3',
		company_b.cmp_name 'd_name',   
	        company_b.cmp_address1 'd_address1',   
	        company_b.cmp_address2 'd_address2',   
	        company_b.cmp_city 'd_city',   
	        company_b.cmp_state 'd_state',   
	        company_b.cmp_zip 'd_zip',   
	        company_b.cty_nmstct 'd_cty_nmstct',
		company_c.cmp_name 'b_name',   
	        company_c.cmp_address1 'b_address1',   
	        company_c.cmp_address2 'b_address2',   
	        company_c.cmp_city 'b_city',   
	        company_c.cmp_state 'b_state',   
	        company_c.cmp_zip 'b_zip',   
	        company_c.cty_nmstct 'b_cty_nmstct',
		#stop_infotemp.stop1_cmp_name 'stop1_cmp_name',   
		#stop_infotemp.stop1_cmp_address1 'stop1_cmp_address1',   
	        #stop_infotemp.stop1_cmp_address2 'stop1_cmp_address2',   
		#stop_infotemp.stop1_cmp_city 'stop1_cmp_city',
		#stop_infotemp.stop1_cmp_state 'stop1_cmp_state',
		#stop_infotemp.stop1_cmp_zip 'stop1_cmp_zip',
		#stop_infotemp.stop1_cty_nmstct 'stop1_cty_nmstct',
		#stop_infotemp.stop2_cmp_name 'stop2_cmp_name',   
		#stop_infotemp.stop2_cmp_address1 'stop2_cmp_address1',   
	        #stop_infotemp.stop2_cmp_address2 'stop2_cmp_address2',   
		#stop_infotemp.stop2_cmp_city 'stop2_cmp_city',
		#stop_infotemp.stop2_cmp_state 'stop2_cmp_state',
		#stop_infotemp.stop2_cmp_zip 'stop2_cmp_zip',
		#stop_infotemp.stop2_cty_nmstct 'stop2_cty_nmstct',
		commodity.cmd_code 'cmd_code',
		commodity.cmd_name 'cmd_name',
		commodity.cmd_misc4 'cmd_misc4',
		commodity.cmd_misc1 'cmd_misc1', 
		commodity.cmd_misc3 'cmd_misc3',
		commodity.cmd_hazardous 'cmd_hazardous',
		freightdetail.fgt_reftype 'fgt_reftype',
		freightdetail.fgt_refnum 'fgt_refnum',
		freightdetail.fgt_quantity 'fgt_quantity',
		freightdetail.fgt_unit 'fgt_unit',
		freightdetail.fgt_sequence 'fgt_sequence',
		@v_ref_number 'hazmat_ref_number',
		#stop_infotemp.lgh_enddate, 
		#stop_infotemp.lgh_startdate,
		stops.stp_mfh_sequence 'mfh_sequence',
		#stop_infotemp.stp_comment1 'stop_comment1',
		#stop_infotemp.stp_comment2 'stop_comment2',
		#stop_infotemp.stp_comment3 'stop_comment3',
		company_b.cmp_address3 'd_address3' -- PTS 37425
FROM		orderheader,
		#stop_infotemp,
		company company_a, 
		company company_b, 
		company company_c,
		stops,
		freightdetail,
		commodity
WHERE		(orderheader.ord_hdrnumber = @v_ord_hdrnumber) AND 
		(orderheader.ord_hdrnumber = #stop_infotemp.ord_hdrnumber) AND
		(orderheader.ord_originpoint = company_a.cmp_id) AND
		(orderheader.ord_destpoint = company_b.cmp_id) AND
		(orderheader.ord_billto = company_c.cmp_id) AND
		(orderheader.mov_number = stops.mov_number) AND 
		(stops.stp_number = freightdetail.stp_number) AND
		(freightdetail.cmd_code = commodity.cmd_code)
GO
GRANT EXECUTE ON  [dbo].[d_bl_report_for_flor] TO [public]
GO
