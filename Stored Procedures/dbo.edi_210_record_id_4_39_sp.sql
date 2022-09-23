SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_record_id_4_39_sp]
	@invoice_number varchar(12), 
	@ord_hdrnumber integer,
	@trpid varchar(20),
	@docid varchar(30),
   @billto varchar(8)
 as
 /**
 * 
 * NAME:
 * dbo.edi_210_record_id_4_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates company and cargo records for the current invoice in the
 *  EDI_210 table.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @invoice_number, varchar(12), input, null;
 *       This parameter indicates the current invoice number 
 * 002 - @ord_hdrnumber, integer, input, null;
 *       This parameter indicates the order header number for the current invoice 
 * 003 - @trp_id, varchar(20), input, null;
 *       This parameter indicates thetrading partner ID 
 * 004 - @docid varchar(30) 
 *		 This parameter indicates the current EDI document ID
 * 005 - @billt0 varchar(8)
 *		 Indicates the company for which the current record is being processed.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? edi_210_record_id_5_39_sp
 * CalledBy001 ? edi_210_all_39_sp 
  * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 *
 * modified 3/6/00 to truncate overlong fields: correct problem with using 
 * stp_number to sequence the output (used stp_sequence)
 * pts 11689 state field on database changed to 6 char, must truncate for flat file
 * pts13379 jyang add street address in teh flat file
 * PTS 13365 add the company id and store number 4/18/2 DPETe
 * PTS 13459 Add edicode to eventcode table and place in #4 record if present DPETE 5/22/02
 * DPETE PTS 14524 Add #7 cargo recs for freightdetail if generalinfo table indicates.
 * DPETE PTS13854 8/9/2 Add miles to record
 * AROSS Added code to handle EDI210EXPORTSTCC general info setting.
 * 9/19/2005.01 - PTS29839 - A. Rossman -  Corrected conversion error on weights and quantities.
 * 01/02/07.02  - PTS34717 - A. Rossman -  Allow for option to add stop arrival and departure dates to the 4 records.
 * 02/14/2007.06  PTS36039 - A.Rossman - Allow for use of full location codes from cmpcmp table
 * 02/20/07  PTS 36318 - D Petersen - do not create records for non billable stops
 * 09/28/07  PTS 39645 - A. Rossman -  Include Address Line 2 for stopoff records.
 * 03/13/08 PTS 41247 - A, Rossman - Add FgtSupplier to cargo records
 * 07/01/08 PTS 42883 - A. Rossman - Add city splc identifier.
 * 02/26/10 PTS 49961 - A. Rossman - Added count2 and count2 units to cargo detail.
 * 02/26/10 PTS 50029 - A. Rossman - add appt. and eta date misc records.
 * 01/10/11 PTS 55339 - D. Wilks - Added volume2 and volume2 units to cargo detail.
 **/
 
DECLARE @emptystring varchar(30),@minstopsequence smallint, @curstopnumber int
DECLARE @nextfgtnumber int
DECLARE @data  varchar(200),
@volume 	VARCHAR(12),	
@volumeunit	VARCHAR(6) ,
@count	VARCHAR(12),	
@countunit	VARCHAR(6),
@weight 	VARCHAR(12),
@weightunit varchar(6),
@cmdcode varchar(8),
@cmdname varchar(50),
@edicmdcode varchar(30),
@ExportSTCC varchar(1), 
@stcccode varchar(8),
@stp_arrivaldate varchar(16),			--PTS 34717
@stp_departuredate varchar(16),		--PTS 34717
@add_stopdates	 char(1),			--PTS 34717
@trp_uselongcodes char(1)
,@v_GI_EDI210OutputStops varchar(20)  -- 36138 switch change
,@v_stopoff_details char(1),	--39645
@v_trp_supplier char(1),
@v_supplier_id varchar(8),
@v_supplier_name varchar(30),
@v_supplier_loc varchar(30),	--PSL PTS 55792 30 character supplier location code
@v_splc_flag char(1),
@v_addAppt char(1),
@v_addEta  char(1),
@v_count2 varchar(12),
@v_count2unit varchar(6),
@volume2 	VARCHAR(12),	--55339	
@volume2unit	VARCHAR(6)	--55339 



Create table #210_stops_temp (
stp_sequence int null,
stp_number int NULL,
edicode char(2) NULL,
weight varchar(6) NULL,
weight_qualifier varchar(6) Null,
quantity varchar(6) NULL,
quantity_qualifier varchar(6) null,
city_name varchar(18) NULL,
state char(2) nULL,
zip varchar(9) Null,
cmp_name varchar(30) Null,
cmp_address1 varchar(30) Null,
cmp_id varchar(8) Null,
storeloc varchar(30) Null  ,		--updated to 30
miles varchar(4) Null,
arrival	datetime NULL,
departure datetime NULL,
cmp_address2 varchar(30) NULL,	--39645
splc varchar(9) NULL,
appt_early datetime NULL,	--50029
appt_late  datetime NULL,
eta		   datetime NULL,
podname		varchar(20) NULL
)
-- 36238 unless GI tells you not to, do not include order stops for non billable  events in output
select @v_GI_EDI210OutputStops = isnull(gi_string1,'BILLABLE') from generalinfo
where gi_name = 'EDI210OutputStops'
select  IsNull(@v_GI_EDI210OutputStops,'BILLABLE')

--AROSS PTS 28894
SELECT @ExportSTCC = left(upper(isnull(gi_string1,'N')),1) FROM generalinfo WHERE gi_name = 'EDI210ExportSTCC'

/*PTS 36039 Aross */
SELECT 	@trp_uselongcodes = ISNULL(trp_long_storecodes,'N') ,
		   	@v_stopoff_details = ISNULL(trp_210_stopoff_details,'N')	--PTS 39645
 FROM 		edi_trading_partner WHERE trp_210id  = @trpid		--PTS 36039




  
SELECT @trpid = ISNULL(@trpid,'NOVALUE')

SELECT @emptystring=' '

--PTS 34717 check stopdates setting
SELECT @add_stopdates =  ISNULL(trp_export_210_stopdates,'N'),
		  @v_trp_supplier = ISNULL(trp_210_fgt_supplier,'N'),
		  @v_splc_flag = ISNULL(trp_210_splc,'N')--,
		  --@v_addAppt =  isnull(trp_210_apptDates,'N'),		--50029
		  --@v_addEta =  isnull(trp_210_etaDate,'N')			--50029
FROM	edi_trading_partner
WHERE	trp_210id=  @trpid

-- put data into temp table for massaging
INSERT INTO #210_stops_temp 
SELECT  stp_sequence = ISNULL(s.stp_sequence,0),
	s.stp_number,
	edicode =
      Case Rtrim(IsNull(ev.edicode,''))
        When '' Then
         Case stp_type
           When 'PUP' Then 'PU'
           When 'DRP' Then 'DR'
           Else 'MT'
         End
        Else ev.edicode
       End,
	weight=(Select RIGHT(CONVERT(varchar(12),CONVERT(int,SUM(ISNULL(f.fgt_weight,0)))),6) from 
		freightdetail f where s.stp_number = f.stp_number group by f.stp_number),
	weight_qualifier = stp_weightunit,
	quantity=(Select RIGHT(CONVERT(varchar(12),CONVERT(int,SUM(ISNULL(f.fgt_count,0)))),6) from 
		freightdetail f where s.stp_number = f.stp_number group by f.stp_number),
	quantity_qualifier = stp_countunit,
	city_name=SUBSTRING(ISNULL(ci.cty_name,' '),1,18),
	state=SUBSTRING(ISNULL(ci.cty_state,'  '),1,2), --changed to pull from city table DPH PTS 25278
	zip= SUBSTRING(ISNULL(isnull(co.cmp_zip,ci.cty_zip),' '),1,9),
	cmp_name = SUBSTRING(ISNULL(co.cmp_name,' '),1,30),
	cmp_address1 = SUBSTRING(ISNULL(co.cmp_address1,' '),1,30), 
	s.cmp_id,
	--DPH PTS 23606 6/23/04
--  	Storeloc = (Select Substring(IsNUll(ediloc_code,''),1,10) 
--  	FROM cmpcmp, orderheader  WHERE orderheader.ord_hdrnumber = s.ord_hdrnumber
--  	and cmpcmp.billto_cmp_id = ord_billto and cmpcmp.cmp_id = s.cmp_id),
	 Storeloc = ISNULL((Select  IsNUll(ediloc_code,' ')
 	FROM cmpcmp, orderheader  WHERE orderheader.ord_hdrnumber = s.ord_hdrnumber
 	and cmpcmp.billto_cmp_id = @billto and cmpcmp.cmp_id = s.cmp_id),''),
	miles = RIGHT(Convert(varchar(4),Isnull(stp_ord_mileage,0)),4),
	arrival = stp_arrivaldate,
	departure = stp_departuredate,
	cmp_address2 = SUBSTRING(ISNULL(co.cmp_address2,' '),1,30),
	splc = ISNULL(CAST(ci.cty_splc as VARCHAR(9)),'000000000'),
	appt_early = stp_schdtearliest,	--50029
	appt_late = stp_schdtlatest,	--50029
	eta = isnull(stp_eta,'12/31/2049 23:59'),					--50029
	podname = isnull(s.stp_podname,'')
FROM stops s
join company co on s.cmp_id = co.cmp_id
join city ci on s.stp_city = ci.cty_code
join eventcodetable ev on stp_event = ev.abbr
	WHERE @ord_hdrnumber > 0 AND
   s.ord_hdrnumber=@ord_hdrnumber 
   and ev.ect_billable = case @v_GI_EDI210OutputStops when 'BILLABLE' then 'Y' else ev.ect_billable end
--	co.cmp_id=*s.cmp_id AND
--	ci.cty_code=s.stp_city and
--   ev.abbr = stp_event
   
 


-- Get edi code for weight qualifier through labelfile
  UPDATE #210_stops_temp
  SET weight_qualifier= UPPER(convert(char(3),UPPER(SUBSTRING(ISNULL(labelfile.edicode,' '),1,3))))
  FROM #210_stops_temp,labelfile
  WHERE labeldefinition='WeightUnits' AND abbr= weight_qualifier

UPDATE #210_stops_temp
  SET quantity_qualifier= UPPER(convert(char(3),UPPER(SUBSTRING(ISNULL(labelfile.edicode,' '),1,3))))
  FROM #210_stops_temp,labelfile
  WHERE labeldefinition='CountUnits' AND abbr=quantity_qualifier
-- get total weight and count from freightdetail, truncate to whole number

-- return the rows FROM the temp table following each with related ref#s
SELECT @minstopsequence = min(stp_sequence)
FROM #210_stops_temp


While @minstopsequence is NOT NULL
BEGIN
	
	--PTS 34717  add the stop arrival and departure dates when setting is active for trading partner
	IF @add_stopdates =  'Y'
		SELECT @stp_arrivaldate =  CONVERT(varchar(8),arrival,112) + SUBSTRING(CONVERT(varchar(8),arrival,8),1,2) +SUBSTRING(CONVERT(varchar(8),arrival,8),4,2),
				@stp_departuredate =  CONVERT(varchar(8),departure,112) + SUBSTRING(CONVERT(varchar(8),departure,8),1,2) +SUBSTRING(CONVERT(varchar(8),departure,8),4,2)
		FROM	#210_stops_temp
		WHERE	stp_sequence =  @minstopsequence
	ELSE
		SELECT @stp_arrivaldate=  @emptystring,
				@stp_departuredate  =@emptystring
	--END PTS 34717			
	
	
	INSERT INTO edi_210(data_col,doc_id,trp_id)
	SELECT 
	 '4' +		-- Record ID
	'39' +				-- Record Version
	edicode  +
		replicate('0',6-datalength(weight)) +
	weight +
		replicate('0',6-datalength(quantity)) +
	quantity +
	city_name +
		replicate(' ',18-datalength(city_name)) +
	state +
		replicate(' ',2-datalength(state)) +
	zip +
		replicate(' ',9-datalength(zip)) +
	cmp_name +
		replicate(' ',30-datalength(cmp_name)) +
	SUBSTRING(ISNULL(weight_qualifier,' '),1,3) + replicate(' ',3-datalength(SUBSTRING(ISNULL(weight_qualifier,' '),1,3))) +
	SUBSTRING(ISNULL(quantity_qualifier,' '),1,3) + replicate(' ',3-datalength(SUBSTRING(ISNULL(quantity_qualifier,' '),1,3))) +
	replicate('0',4-datalength(miles))+ miles +
	cmp_id + replicate(' ',20 - datalength(cmp_id)) +
	IsNull(SUBSTRING(storeloc,1,10),' ')  + replicate(' ',10 - datalength(Isnull(SUBSTRING(storeloc,1,10),' '))) +
	replicate (' ',2) +
	cmp_address1 + replicate(' ',30-datalength(cmp_address1)) +
	@stp_arrivaldate + replicate(CHAR(32), 12 - datalength(@stp_arrivaldate)) +
	@stp_departuredate + replicate(CHAR(32), 12 - datalength(@stp_departuredate)) +
		CASE @trp_uselongcodes
			WHEN 'Y' THEN isnull(storeloc, ' ') + replicate(CHAR(32),30 - datalength(storeloc))
			ELSE   REPLICATE(CHAR(32),30)				
	END +
	CASE @v_stopoff_details
			WHEN 'Y' THEN cmp_address2 + REPLICATE(CHAR(32),30 - DATALENGTH(cmp_address2))
			ELSE REPLICATE(CHAR(32),30)				--PTS39645 ****
	END +
	CASE @v_splc_flag
			WHEN 'Y' THEN  splc + replicate(CHAR(48),9-datalength(splc))
			ELSE replicate(CHAR(32),9)
	END +
	podname + replicate(char(32),20-datalength(podname)),			
	@docid,
	@trpid
	FROM #210_stops_temp
	WHERE stp_sequence = @minstopsequence
	
	
	--insert into edi_210(data_col,doc_id,trp_id) values(@data,@docid,@trpid)
-- put out any stop level ref numbers
	SELECT @curstopnumber = stp_number
        FROM #210_stops_temp
	WHERE stp_sequence = @minstopsequence

	--PTS 50029 Add Stop ETA and APPT Date Misc Records.
	IF @v_addETA = 'Y'
		INSERT edi_210 (data_col,doc_id,trp_id)
			SELECT	data_col = '539_DTETA' + CONVERT(varchar(8),eta,112) +
				SUBSTRING(CONVERT(varchar(8),eta,8),1,2) +
				SUBSTRING(CONVERT(varchar(8),eta,8),4,2),
				doc_id = @docid,
				trp_id = @trpid
			FROM #210_stops_temp
			WHERE stp_sequence = @minstopsequence
	--Add Appt Date records
	IF @v_addAppt = 'Y'
	begin
			INSERT edi_210 (data_col,doc_id,trp_id)
			SELECT	data_col = '539_DTAPE' + CONVERT(varchar(8),appt_early,112) +
				SUBSTRING(CONVERT(varchar(8),appt_early,8),1,2) +
				SUBSTRING(CONVERT(varchar(8),appt_early,8),4,2),
				doc_id = @docid,
				trp_id = @trpid
			FROM #210_stops_temp
			WHERE stp_sequence = @minstopsequence
			
					INSERT edi_210 (data_col,doc_id,trp_id)
			SELECT	data_col = '539_DTAPL' + CONVERT(varchar(8),appt_late,112) +
				SUBSTRING(CONVERT(varchar(8),appt_late,8),1,2) +
				SUBSTRING(CONVERT(varchar(8),appt_late,8),4,2),
				doc_id = @docid,
				trp_id = @trpid
			FROM #210_stops_temp
			WHERE stp_sequence = @minstopsequence
	end
--END PTS 50029

	If (Select count(*) from referencenumber where ref_table = 'stops' and ref_tablekey = @curstopnumber) > 0
		exec edi_210_record_id_5_39_sp @invoice_number,'stops',@curstopnumber,@trpid,@docid


	-- put out any freightdetail ref numbers
	SELECT @nextfgtnumber = MIN(fgt_number)
        FROM freightdetail
        WHERE freightdetail.stp_number = @curstopnumber
	
	While @nextfgtnumber is NOT NULL
          BEGIN
				If (Select count(*) From generalinfo where gi_name = 'EDI210CargoRecs' and LEFT(UPPER(IsNull(gi_string1,'N')),1) = 'Y') > 0
              Begin  /* for #7 records */
               Select @weight = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_weight,0.00)*100)),9),
							@weightunit = Isnull(fgt_weightunit,'UNK'),
                     @volume = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_volume,0.00)*100)),9),
							@volumeunit = Isnull(fgt_volumeunit,'UNK'),
                     @count = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_count,0.00)*100)),9),
							@countunit = Isnull(fgt_countunit,'UNK'),
                     @cmdcode = IsNull(cmd_code,'UNKNOWN'),
                     @cmdname = Substring(IsNull(fgt_description,''),1,50) ,
                     @v_supplier_id = ISNULL(fgt_supplier,'UNKNOWN'),
                     @v_count2 =  RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_count2,0.00)*100)),9),	--49961
					@v_count2unit = isnull(fgt_count2unit,'UNK'),    --49961 
					@volume2 = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_volume2,0.00)*100)),9), --55339
					@volume2unit = Isnull(fgt_volume2unit,'UNK')											--55339

                     From freightdetail 
                     Where fgt_number = @nextfgtnumber

					--PTS CTHOM 55794
					/*IF EXISTS(SELECT edicode FROM labelfile WHERE labeldefinition ='WeightUnits' AND abbr = @weightunit)
						BEGIN
							--SET @weightunit = ISNULL((SELECT edicode FROM labelfile WHERE labeldefinition ='WeightUnits' AND abbr = @weightunit),@weightunit)				
						END
					IF EXISTS(SELECT edicode FROM labelfile WHERE labeldefinition ='VolumeUnits' AND abbr = @volumeunit)
						BEGIN
							--SET @volumeunit = ISNULL((SELECT edicode FROM labelfile WHERE labeldefinition ='VolumeUnits' AND abbr = @volumeunit),@volumeunit)
						END
					IF EXISTS(SELECT edicode FROM labelfile WHERE labeldefinition ='CountUnits' AND abbr = @countunit)
						BEGIN
							--SET @countunit = ISNULL((SELECT edicode FROM labelfile WHERE labeldefinition ='CountUnits' AND abbr = @countunit),@countunit)
						END
                    IF EXISTS(SELECT edicode FROM labelfile WHERE labeldefinition ='CountUnits' AND abbr = @v_count2unit)
						BEGIN
							--SET @v_count2unit = ISNULL((SELECT edicode FROM labelfile WHERE labeldefinition ='CountUnits' AND abbr = @v_count2unit),@v_count2unit)
						END
					IF EXISTS(SELECT edicode FROM labelfile WHERE labeldefinition ='VolumeUnits' AND abbr = @volume2unit)
						BEGIN
							--SET @volume2unit = ISNULL((SELECT edicode FROM labelfile WHERE labeldefinition ='VolumeUnits' AND abbr = @volume2unit),@volume2unit)
						END
						*/
					--PTS 55794 PSL convert abbr unit code to edicode if not blank
					IF (SELECT edicode FROM labelfile WHERE labeldefinition ='WeightUnits' AND abbr = @weightunit) <> ''
						BEGIN
							SELECT @weightunit = edicode from labelfile where labeldefinition = 'WeightUnits' and abbr = @weightunit
						END
					IF (SELECT edicode FROM labelfile WHERE labeldefinition ='VolumeUnits' AND abbr = @volumeunit) <> ''
						BEGIN
							SELECT @volumeunit = edicode from labelfile where labeldefinition = 'VolumeUnits' and abbr = @volumeunit
						END
					IF (SELECT edicode FROM labelfile WHERE labeldefinition ='CountUnits' AND abbr = @countunit) <> ''
						BEGIN
							SELECT @countunit = edicode from labelfile where labeldefinition = 'CountUnits' and abbr = @countunit
						END
					IF (SELECT edicode FROM labelfile WHERE labeldefinition ='CountUnits' AND abbr = @v_count2unit) <> ''
						BEGIN
							SELECT @v_count2unit = edicode from labelfile where labeldefinition = 'CountUnits' and abbr = @v_count2unit
						END
					IF (SELECT edicode FROM labelfile WHERE labeldefinition ='VolumeUnits' AND abbr = @volume2unit) <> ''
						BEGIN
							SELECT @volume2unit = edicode from labelfile where labeldefinition = 'VolumeUnits' and abbr = @volume2unit
						END
                       
                     --PTS  AROSS 28894
                     select @stcccode = cmd_stcc from commodity c, freightdetail f where fgt_number = @nextfgtnumber and f.cmd_code = c.cmd_code
                     
                     IF @v_supplier_id <> 'UNKNOWN'
                     	SELECT @v_supplier_name = RTRIM(LEFT(ISNULL(cmp_name,''),30))
						FROM	company 
                     	WHERE	cmp_id = @v_supplier_id
                     	
                     --PTS CTHOM 55792
                     --IF EXISTS (select gi_name from generalinfo where gi_name = 'EDI210FreightSupplierLocationCode' and gi_string1 = 'Y')
					IF EXISTS (select gi_name from generalinfo where gi_name = 'EDI210FgtSupplierLocationCode' and gi_string1 = 'Y') --PTS 55792 PSL gi_name only allow 30 characters
						BEGIN 
							--SET @v_supplier_id = ISNULL((SELECT ediloc_code FROM cmpcmp WHERE cmp_id = @v_supplier_id and billto_cmp_id = @billto),@v_supplier_id)
							SET @v_supplier_loc = ISNULL((SELECT ediloc_code FROM cmpcmp WHERE cmp_id = @v_supplier_id and billto_cmp_id = @billto),@emptystring)	
							--PTS 55792 PSL Populate 30 character @v_supplier_loc and default to empty string if no location code in cmpcmp
						END
						ELSE
						BEGIN
							SET @v_supplier_loc = ' '
						END
						
                     --condition for output
                     SELECT @v_supplier_name = ISNULL(@v_supplier_name,'')
                     
                     --set the name to emptystring if setting is disabled.
                     IF (SELECT ISNULL(@v_trp_supplier,'N')) = 'N'
                     	SELECT @v_supplier_name = @emptystring
                 	
                     Select  @edicmdcode = e.edi_cmd_code
                     FROM edicommodity e
                     WHERE e.cmp_id = @billto
                     AND    e.cmd_code = @cmdcode

                     Select @edicmdcode =IsNull(@edicmdcode,'')

                     INSERT INTO edi_210 (data_col,doc_id,trp_id)
	             SELECT '739' +
	             @cmdname + replicate(' ',50 - datalength(@cmdname)) +
                      @edicmdcode + replicate(' ',30 - datalength(@edicmdcode)) +
                      replicate(' ',6)+
                      replicate('0',9 - datalength(@weight)) + @weight + @weightunit + replicate(' ',6 - datalength(@weightunit))+
                      replicate('0',9 - datalength(@volume)) + @volume + @volumeunit + replicate(' ',6 - datalength(@volumeunit))+
                      replicate('0',9 - datalength(@count)) + @count + @countunit + replicate(' ',6 - datalength(@countunit)) +
                       @v_supplier_name  +replicate(' ',30 - datalength(@v_supplier_name)) +	--PTS 41247 added freight supplier.
					  replicate('0',9 - datalength(@v_count2)) + @v_count2 + @v_count2unit + replicate(' ',6 - datalength(@v_count2unit)) +	--49961	                   
					  replicate('0',9 - datalength(@volume2)) + @volume2 + @volume2unit + replicate(' ',6 - datalength(@volume2unit))+	--55339
	                  --@v_supplier_id  +replicate(' ',8 - datalength(@v_supplier_id)),	--PTS 55792 CTHOM added freight supplier ID.
					  @v_supplier_loc  +replicate(' ',30 - datalength(@v_supplier_loc)),	--PTS 55792 PSL freight supplier location code to handle long loc code.						
	                  @docid,@trpid 
              End  /* for #7 records */
              
              --PTS 28894 AROSS Add STCC Misc record
              	    if @exportSTCC = 'Y' and @stcccode is not null
	        			insert into edi_210 (data_col,doc_id,trp_id) select '539REFSTC' + @stcccode, @docid, @trpid
	        			
				If (Select count(*) from referencenumber where ref_table = 'freightdetail' and ref_tablekey = @nextfgtnumber) > 0
            exec edi_210_record_id_5_39_sp @invoice_number,'freightdetail',@nextfgtnumber,@trpid,@docid  

            SELECT @nextfgtnumber = MIN(fgt_number)
             FROM freightdetail
             WHERE freightdetail.stp_number = @curstopnumber
             AND fgt_number >  @nextfgtnumber

          END
	
	SELECT @minstopsequence = min(stp_sequence)
	FROM #210_stops_temp
	WHERE stp_sequence > @minstopsequence

END



GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_4_39_sp] TO [public]
GO
