SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_1_39_sp]
	@ord_number char(12), @cancel_flag char(1),
	@docid varchar(30),
-- PTS 16223 -- BL
	@Company_id varchar(8),
	@sourceApp nvarchar(128) ='',
	@sourceUser varchar(255) = ''
 as
/**
 * 
 * NAME:
 * dbo.edi_214_record_id_1_39_sp
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
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
-- dpete use generalinfo to determine which ref numbers go into output
-- pts7276 put out orderheader ref numbers speciIFed by process requirements for orderheader
-- dpete 7/12/00 add ref id misc record to output for B1001 for CTX
-- dpete 7/14/00 add cancel flag  parm for CTX to add indicator
-- dpete 9/8/00 add docid to edi_214 to hold recs together by document
-- nkres 16428 handle long weights and pieces
-- nkres 17482 add cancel reference after order header references condition
-- BLEVON -- PTS 16223 -- allow for 'All' option on 'ref_table' and 'ref_type' on EDI_214_profile table
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 08/25/2005.02 PTS29483 - aross - Add revtypeX value to position 127 based on generalinfo setting.
 * 09/27/2005.03 PTS29961 - Aross - Add scheduled Earliest and latest dates to shipper and consignee base on GI Setting.
 *08/06/2007.04 PTS37691 - A. Rossman - add miscellaneous records for ACE trip information records.
 * 12/13/2007.05 PTS40651 - A. Rossman - Expand bill of lading reference types to include BM
 * 10/15/2008.06 PTS44817 - A. Rossman - Add miscellaneous record for delivery date
 * 04.16.2009.07 PTS45230 - A. Rossman - add pickup totalweight to output.
 * 01.14.2014.08 PTS74227 0 AR - Include source of status on 214.
 *
 **/

DECLARE @TPNumber varchar(20)
DECLARE @BLRef varchar(30), @PORef varchar(30)
DECLARE @cmp_id varchar(8), @n101code varchar(2), @SCAC varchar(20)
DECLARE @n1shipper varchar(8), @n1consignee varchar(8), @n1billto varchar(8)
DECLARE @ordterms char(2),@ordtotalweight varchar(15),@ordtotalpieces varchar(10)
DECLARE @ordhdrnumber int,@storeplantnbr varchar(12),@totalcharge varchar(9)
DECLARE @ordtotalcharge varchar(9), @totalmiles varchar(4)
DECLARE @calctotalcharge money
DECLARE @ordstartdate varchar(12),@ordcompletiondate varchar(12)--44817
DECLARE @revtype varchar(8), @ordrevtype varchar(6)
DECLARE @revstart smallint
DECLARE @revtype1 varchar(6),@revtype2 varchar(6),@revtype3 varchar(6),@revtype4 varchar(6)
DECLARE @getdate datetime
DECLARE @Movnumber varchar(8)
DECLARE @214ExportNotes char(1), @CancelRefAfterOrderRefs char(1)
DECLARE @v_UseRevType varchar(8)		--29483 Aross
DECLARE @v_RevValue varchar(6)		--29483 Aross,
DECLARE @v_ShowSchedDates char(1)
DECLARE @v_SchedEarliest_sh datetime, @v_SchedLatest_sh datetime, @v_SchedEarliest_cn datetime, @v_SchedLatest_cn datetime
--PTS 37691
DECLARE @output_ace char(1),@trailerID varchar(8),@tractorID varchar(8),@driverID varchar(8),@lgh_number int
DECLARE @v_add_pupwgt CHAR(1),@v_pupweight varchar(12)	--45230
DECLARE @v_RestrictByTerms CHAR(1),@ord_terms VARCHAR(6),@v_restrictTermsLevel CHAR(1)
DECLARE @v_GISourceofStatus CHAR(1)



 
 
SELECT @v_add_pupwgt = 'N'	--45230
 SELECT @storeplantnbr = '   '
 SELECT @cancel_flag = ISNULL(@cancel_flag,'N')

--50029
Select @v_RestrictByTerms =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI_RestrictByTerms'

--PTS74227
SELECT @v_GISourceofStatus =  ISNULL(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI214_SourceofStatus'

 
--PTS 29961
Select @v_ShowSchedDates =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI214_EarliestLatest'

-- 17482 select from generalinfo
select @CancelRefAfterOrderRefs = upper(left(gi_string1,1)) from generalinfo where gi_name = 'EDI214CancelRefAfterOrderRefs'

-- collect order header information.
 SELECT 
	@ordhdrnumber=ord_hdrnumber,
	--@n1shipper=ord_shipper,
	--@n1consignee=ord_consignee, 
	@n1billto=ord_billto,
	@ordterms=
		CASE ord_terms
			WHEN 'PPD' THEN 'PP'
			WHEN 'UNK' THEN 'PP'
			WHEN 'COL' THEN 'CC'
			WHEN '3RD' THEN 'TP'
			WHEN NULL THEN 'PP'
			ELSE 'PP'
		END , 
	@ordtotalweight=CONVERT(varchar(15),CONVERT(int,ISNULL(orderheader.ord_totalweight,0))), 
	@ordtotalpieces=CONVERT(varchar(10),CONVERT(int,ISNULL(orderheader.ord_totalpieces,0))),
	@ordtotalcharge=CONVERT(varchar(9),CONVERT(int,ISNULL(ord_totalcharge,0.0) * 100)),
        @ordstartdate = CONVERT(varchar(8),ord_startdate,112)+
	SUBSTRING(CONVERT(varchar(8),ord_startdate,8),1,2) + 
	SUBSTRING(CONVERT(varchar(8),ord_startdate,8),4,2),
	@ordcompletiondate = CONVERT(varchar(8),ord_completiondate,112) +
	SUBSTRING(CONVERT(varchar(8),ord_completiondate,8),1,2) +
	SUBSTRING(CONVERT(varchar(8),ord_completiondate,8),4,2),
    @revtype1 = ord_revtype1,
	@revtype2 = ord_revtype2,
	@revtype3 = ord_revtype3,
	@revtype4 = ord_revtype4,
	@movnumber = RIGHT(CONVERT(varchar(8),mov_number),8)
 FROM orderheader
 WHERE ( orderheader.ord_number = @ord_number )
 
IF @v_RestrictByTerms = 'Y' 
BEGIN	 --50029  Check Terms
	 select @ord_terms  = isnull(ord_terms,'UNK') from orderheader where ord_hdrnumber = @ordhdrnumber
	 
	 --get terms restriction
	 select @v_restrictTermsLevel = isnull(trp_214_restrictTerms,'B') 
		from edi_trading_partner
		where cmp_id = @company_id

	--allow PPD only 
	if (@v_restrictTermsLevel = 'P' and @ord_terms <> 'PPD')
		RETURN
	--allow COL only
	if (@v_restrictTermsLevel = 'C' and @ord_terms <> 'COL')
		RETURN	
END	--50029 

--DPH PTS 24322 (ord_shipper is not reliable in certain situations) (and PTS 24797 -DPH)
 --If (Select ord_shipper from orderheader where ord_hdrnumber = @ordhdrnumber) = 'UNKNOWN'
-- BEGIN
SELECT @n1shipper = cmp_id, @v_SchedEarliest_sh = stp_schdtearliest, @v_SchedLatest_sh = stp_schdtlatest
FROM 	stops
WHERE  stp_type = 'PUP'
	and stp_sequence = (select min(stp_sequence)
				from stops
				where ord_hdrnumber = @ordhdrnumber
				and stp_type = 'PUP')
	and ord_hdrnumber = @ordhdrnumber
--END
/* ELSE
 BEGIN
	SELECT @n1shipper = ord_shipper from orderheader where ord_hdrnumber = @ordhdrnumber
 END   */
--DPH PTS 24322 (ord_shipper is not reliable in certain situations) (and PTS 24797 -DPH) 

--DPH PTS 23860 (ord_consignee is not reliable in certain situations)
 SELECT @n1consignee = cmp_id  ,@v_SchedEarliest_cn = stp_schdtearliest, @v_SchedLatest_cn = stp_schdtlatest
 FROM 	stops
 WHERE  stp_type = 'DRP'
	and stp_sequence = (select max(stp_sequence)
			from stops
			where ord_hdrnumber = @ordhdrnumber
			and stp_type = 'DRP')
	and ord_hdrnumber = @ordhdrnumber
--DPH PTS 23860 (ord_consignee is not reliable in certain situations)

-- pts16428
 IF DATALENGTH(@ordtotalpieces) > 6
 	SELECT @ordtotalpieces = LEFT(@ordtotalpieces, 6)
 IF DATALENGTH(@ordtotalweight) > 6
 	SELECT @ordtotalweight = LEFT(@ordtotalweight, 6)



-- pts8230
 SELECT  @SCAC=UPPER(gi_string1)
 FROM generalinfo where gi_name='SCAC'

 SELECT @SCAC=ISNULL(@SCAC,'SCAC')

-- Is SCAC based on RevType? get from labelfile
 SELECT  @revstart = CHARINDEX('REVTYPE',@SCAC,1)

 IF @revstart  = 0 
   SELECT @SCAC=SUBSTRING(@SCAC,1,4)
 ELSE
  BEGIN
   SELECT @revtype = SUBSTRING(@SCAC,@revstart,8)

   SELECT @ordrevtype = 
     Case @revtype
       When 'REVTYPE1' Then @revtype1
       When 'REVTYPE2' Then @revtype2
       When 'REVTYPE3' Then @revtype3
       When 'REVTYPE4' Then @revtype4
       Else @revtype1
     End
   
 
   SELECT @SCAC = isnull(UPPER(edicode),abbr)
   FROM labelfile
   WHERE labeldefinition = @revtype
   AND    abbr = @ordrevtype

   -- handle spaces in edicode field
   IF LEN(RTRIM(@SCAC)) = 0 
      -- SELECT @SCAC = 'ERRL' 
	SELECT @SCAC = @ordrevtype

   SELECT @SCAC = SUBSTRING(@SCAC,1,4)

  END

--PTS 29483 Start  Aross
Select @v_UseRevType =  IsNull(UPPER(LEFT(gi_string1,8)),'UNKNOWN') FROM generalinfo WHERE gi_name = 'EDI_AddRevType'
SELECT @v_RevValue = CASE @v_UseRevType
							When 'REVTYPE1' Then @revtype1
							When 'REVTYPE2' Then @revtype2
							When 'REVTYPE3' Then @revtype3
							When 'REVTYPE4' Then @revtype4
							Else ' '
						End
--End 29483						
-- dpete for Trilex

 SELECT top 1 @BLRef = ISNULL(ref_number,'  ')
   FROM referencenumber
  WHERE ref_table = 'orderheader'
    AND ref_tablekey = @ordhdrnumber
    AND ref_type in ('BL#','BL','BOL','BM')
  ORDER by ref_sequence

 SELECT @BLRef = ISNULL(@BLRef,'')
 
 SELECT @PORef = ISNULL(max(ref_number),'  ')
 FROM referencenumber
 WHERE ref_table = 'orderheader'
 AND   ref_tablekey = @ordhdrnumber
 AND   ref_type in ('PO','PO#')

-- pts18223 POs might be too long for the replicate later on.
SELECT @PORef = LEFT(ISNULL(@PORef,''),15)

 -- Get total order miles from stops
 SELECT @totalmiles=CONVERT(varchar(4),SUM(stp_ord_mileage))
 FROM   stops
 WHERE  ord_hdrnumber = @ordhdrnumber
 AND    stp_ord_mileage IS NOT NULL

 SELECT  @totalmiles = ISNULL( @totalmiles,0)
 

 -- Retrieve invoice total charge IF any
 SELECT @calctotalcharge=ISNULL(ivh_totalcharge,0.0)
 FROM   invoiceheader
 WHERE  ord_hdrnumber = @ordhdrnumber
 IF @calctotalcharge > 9999999.99
	SELECT @totalcharge='999999999'
 ELSE
	SELECT @totalcharge = CONVERT(varchar(9),CONVERT( int,@calctotalcharge * 100) )

 -- Substitute pre rate IF no invoice charge
 SELECT @totalcharge=ISNULL(@totalcharge,@ordtotalcharge)

 -- retrieve Trading Partner number
 SELECT @TPNumber = trp_id, @214ExportNotes = Isnull(trp_214ExportNotes, 'N'),@output_ace = UPPER(ISNULL(trp_214_aceinfo,'N'))
 FROM edi_trading_partner
-- PTS 24107 -- BL (start)
-- WHERE cmp_id=@n1billto
 WHERE cmp_id=@Company_id
-- PTS 24107 -- BL (end)

 SELECT @TPNumber = ISNULL(@TPNumber,@n1BillTo)


 -- create edi 214 record 1 from collected data
 INSERT edi_214 (data_col,trp_id,doc_id,e214_source, e214_user)
 SELECT 
 data_col = '1' +				-- Record ID
 	'39' +						-- Record Version
	@scac +				-- SCAC
	replicate(' ',4-datalength(ISNULL(@scac,''))) +
	CONVERT(varchar(15),ISNULL(@ord_number,'')) +				-- OrderNumber
	replicate(' ',15-datalength(CONVERT(varchar(15),ISNULL(@ord_number,'')))) +
	ISNULL(@BLRef,'') +				-- BOL
	replicate(' ',30-datalength(ISNULL(@BLRef,''))) +
	ISNULL(@PORef,'') +				-- PO
	replicate(' ',15-datalength(ISNULL(@PORef,''))) +
	ISNULL(@storeplantnbr,'') +				-- storeplantnumber
	replicate(' ',12-datalength(ISNULL(@storeplantnbr,''))) +
	replicate('0',6-datalength(ISNULL(@ordtotalweight,''))) +
	ISNULL(@ordtotalweight,'') +			-- Weight
	replicate('0',9-datalength(ISNULL(@totalcharge,''))) + -- AMount
	ISNULL(@totalcharge,'') +
	replicate('0',6-datalength(ISNULL(@ordtotalpieces,''))) +

	ISNULL(@ordtotalpieces,'') +			-- Count
	ISNULL(@ordterms,'') +				-- terms
	replicate(' ',12) +			-- Not used signature
	replicate ('0',4-datalength(ISNULL(@totalmiles,''))) +
	ISNULL(@totalmiles,'') +					-- miles
	replicate('0',8-datalength(ISNULL(@movnumber,'')))+ ISNULL(@movnumber,'') + 					-- Not used TTS TO
	@v_RevValue + replicate(' ',20) +				-- Not used userdef		 PTS 29483 added revtype value
	replicate(' ',30), 				-- Not used shipment number
	trp_id = ISNULL(@TPNumber,''),
	doc_id = ISNULL(@docid,''),
	@sourceApp,
	@sourceUser

 -- pts7738 need misc record for shipdate 4/12/00
 INSERT edi_214 (data_col,trp_id,doc_id,e214_source, e214_user)
 SELECT 
       data_col = '439_DTSDT' +	isnull(@ordstartdate,'') + REPLICATE(' ',64),trp_id = isnull(@TPNumber,''), doc_id = isnull(@docid,''), @sourceApp, @sourceUser
       
 --pts44817 add deliverydate if enabled
 IF(SELECT UPPER(LEFT(ISNULL(gi_string1,'N'),1)) FROM generalinfo WHERE gi_name = 'EDI214_DeliveryDateTime') = 'Y'
	INSERT edi_214(data_col,trp_id,doc_id,e214_source, e214_user)
	SELECT
		 data_col  = '439_DTRDT' + isnull(@ordcompletiondate,'') ,trp_id = isnull(@TPNumber,''), doc_id = isnull(@docid,''), @sourceApp, @sourceUser
--end 44817		       

 -- PTS7962 add a unique id for this trans  = doc#-ord#-YYMMDDHHMM
  SELECT @getdate = getdate()
 
  INSERT edi_214 (data_col,trp_id,doc_id,e214_source, e214_user)
  SELECT 
      data_col = '439_IDRID214-' +RTRIM(@ord_number)+ '-' +
      CONVERT(varchar(8),@getdate,12) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),1,2) + 
      SUBSTRING(CONVERT(varchar(8),@getdate,8),4,2) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),7,2),
     trp_id = @TPNumber, doc_id = @docid, @sourceApp, @sourceUser
 -- PTS 17482
 -- If an indication of a cancel must be passed	
 IF @cancel_flag = 'Y' and @CancelRefAfterOrderRefs <> 'Y'
    INSERT edi_214 (data_col,trp_id,doc_id,e214_source, e214_user)
     SELECT 
      data_col = '439_XXCANCEL',
      trp_id = @TPNumber, doc_id = @docid, @sourceApp, @sourceUser
	
-- add on #4 ref numbers for the orderheader
-- PTS 16223 -- BL (start)
-- EXEC edi_214_record_id_4_39_sp @ordhdrnumber,'orderheader',@ordhdrnumber,@TPNumber,@docid
 EXEC edi_214_record_id_4_39_sp @ordhdrnumber,'orderheader',@ordhdrnumber,@TPNumber,@docid,@Company_id
-- PTS 16223 -- BL (end)
IF @cancel_flag = 'Y' and @CancelRefAfterOrderRefs = 'Y'
    INSERT edi_214 (data_col,trp_id,doc_id,e214_source, e214_user)
     SELECT 
      data_col = '439_XXCANCEL',
      trp_id = @TPNumber, doc_id = @docid, @sourceApp, @sourceUser
      
  -- 16786 Write Notes Regarding EDI As _RMs
 If @214ExportNotes = 'Y'
 	INSERT edi_214 (data_col, trp_id, doc_id,e214_source, e214_user)
 	select '439_RM' +not_text,trp_id = @TPNumber, doc_id = @docid, @sourceApp, @sourceUser from notes 
 		where (nre_tablekey = @ordhdrnumber and ntb_table ='orderheader') and 
			not_type ='E'
	
/*PTS 45230 - ARoss; add 5 misc record w/ total pup weight */
    SELECT @v_add_pupwgt =  UPPER(ISNULL(trp_214_pupwgt,'N'))
    FROM	edi_trading_partner
    WHERE	  cmp_id = @Company_ID	--trp_id = @TPNumber 
    
    IF @v_add_pupwgt = 'Y'
    BEGIN
    	SELECT @v_pupweight =  CONVERT(int,SUM(ISNULL(fgt_weight,0))) FROM freightdetail f
    		 INNER JOIN stops s
			ON s.stp_number =  f.stp_number
			WHERE s.ord_hdrnumber = @ordhdrnumber
			and s.stp_type = 'PUP'
    
    --output the misc record
    	    INSERT edi_214(data_col,doc_id,trp_id,e214_source, e214_user)
    		SELECT data_col = '439REFTOW' + isnull(@v_pupweight,''),
    			doc_id = @docid,
			trp_id = @tpnumber, @sourceApp, @sourceUser 
			
    END			   
 /* PTS 45230 - END */	
--PTS74227 Output Source of Status
IF @v_GISourceofStatus = 'Y'
BEGIN
	INSERT INTO edi_214(data_col,doc_id,trp_id,e214_source, e214_user)
	SELECT data_col = '439REFUID' + LEFT(UPPER(@sourceUser),76),
			doc_id = @docid,
			trp_id = @tpnumber, @sourceApp, @sourceUser 
	
	INSERT INTO edi_214(data_col,doc_id,trp_id,e214_source, e214_user)
	SELECT data_col = '439REFAPP' + LEFT(UPPER(@sourceApp),76),
			doc_id = @docid,
			trp_id = @tpnumber, @sourceApp, @sourceUser 

END	--74227 
    
    
--BEGIN 37691			
IF @output_ace = 'Y'
BEGIN
	--Get the legheader for the first border crossing event
	SELECT 	@lgh_number = lgh_number
	FROM	stops
	WHERE	mov_number = @movnumber
		AND stp_event in ('BCST','NBCST')
		and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops 
					WHERE mov_number = @movnumber AND stp_event in ('BCST','NBCST')
							AND stp_state IN (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA'))
	
	SELECT @driverID =  ISNULL(lgh_driver1,'UNKNOWN'),@tractorID =ISNULL( lgh_tractor,'UNKNOWN'),@trailerID = ISNULL(lgh_primary_trailer,'UNKNOWN')
	FROM		legheader
	WHERE	lgh_number = @lgh_number
	
	IF @driverID <> 'UNKNOWN'
	     INSERT INTO edi_214 (data_col,doc_id,trp_id,e214_source, e214_user)
	     		SELECT data_col = '439ACEDRV' +
	     				  ISNULL(mpp_aceid,'NO NUMBER'),
	     				  doc_id = isnull(@docid,''),trp_id = isnull(@TPNumber,''),e214_source=@sourceApp, e214_user = @sourceUser 
	     		FROM	manpowerprofile
	     		WHERE mpp_id =  @driverID
	
	IF @tractorID <> 'UNKNOWN'
		INSERT INTO edi_214 (data_col,doc_id,trp_id,e214_source, e214_user)
			SELECT	data_col = '439ACETRC' +
						UPPER(ISNULL(LEFT(trc_licstate,2),'  ')) +
						UPPER(ISNULL(trc_licnum,'NO NUMBER')),
						doc_id = @docid,trp_id = @TPNumber,
						e214_source=@sourceApp, e214_user = @sourceUser 
			FROM		tractorprofile
			WHERE  	trc_number = @tractorID

	IF @trailerID <> 'UNKNOWN'
		INSERT INTO edi_214 (data_col,doc_id,trp_id,e214_source, e214_user)
			SELECT 	data_col = '439ACETRL' +
						UPPER(ISNULL(LEFT(trl_licstate,2),'  ')) +
						UPPER(ISNULL(trl_licnum,'NO NUMBER')),
						doc_id = @docid,trp_id = @TPNumber,
						e214_source=@sourceApp, e214_user = @sourceUser 
			FROM		trailerprofile
			WHERE  	trl_id = @trailerID							
							
END		--37691					

 EXEC edi_214_record_id_2_39_sp @n1shipper,'SH',@TPNumber,@Company_id,@docid    --@n1billto,@docid

 --PTS 29961 Earliest/Latest Dates
	IF @v_ShowSchedDates = 'Y'
		INSERT INTO edi_214(data_col,doc_id,trp_id,e214_source, e214_user)
			SELECT data_col = '439_DTEL ' +
					CONVERT(varchar(8),isnull(@v_SchedEarliest_sh,''),112)	 +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedEarliest_sh,''),8),1,2)  +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedEarliest_sh,''),8),4,2)  +
					CONVERT(varchar(8),isnull(@v_SchedLatest_sh,''),112)	 +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedLatest_sh,''),8),1,2)  +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedLatest_sh,''),8),4,2),
					doc_id = isnull(@docid,''),trp_id = isnull(@TPNumber,''), e214_source=@sourceApp, e214_user = @sourceUser 

 EXEC edi_214_record_id_2_39_sp @n1consignee,'CN',@TPNumber,@Company_id,@docid  --@n1billto,@docid
  --PTS 29961 Earliest/Latest Dates
	IF @v_ShowSchedDates = 'Y'
		INSERT INTO edi_214(data_col,doc_id,trp_id,e214_source, e214_user)
			SELECT data_col = '439_DTEL ' +
					CONVERT(varchar(8),isnull(@v_SchedEarliest_cn,''),112)	 +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedEarliest_cn,''),8),1,2)  +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedEarliest_cn,''),8),4,2)  +
					CONVERT(varchar(8),isnull(@v_SchedLatest_cn,''),112)	 +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedLatest_cn,''),8),1,2)  +
					SUBSTRING(CONVERT(varchar(8),isnull(@v_SchedLatest_cn,''),8),4,2),
					doc_id = isnull(@docid,''), trp_id = isnull(@TPNumber,''), e214_source=@sourceApp, e214_user = @sourceUser 
 EXEC edi_214_record_id_2_39_sp @n1billto,'BT',@TPNumber,@Company_id,@docid     --@n1billto,@docid

GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_1_39_sp] TO [public]
GO
