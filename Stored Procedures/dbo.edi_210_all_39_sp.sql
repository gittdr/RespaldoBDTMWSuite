SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_210_all_39_sp] 
	@invoice_number VARCHAR( 12 )

 as
/*   MODIFICATION LOG
  2/28/00 
  5/10/00 pts7974 add numeric version of invoice #
  5/26/00 ps8085 to add ship date misc record to output
  dpete 7/21/00 pts 7651 substitute trp-210id for trp_id
  jyang 2/14/01 pts 9979 add opt_trctype4 in orderheader misc record to output
  dpete 3/28/01 1-356 if trailer is not specified, use tractor in equipment ID field
	dpete pts 12235 place trailer type (or its EDI code if specied in labelfile) on the #1 record, use generalinfo setting to SELECT which one
		Code places tractor in equipment field if trailer is UNKNOW, code then uses trailer type fields instead
 		of tractor if tariler is unknown - could be extnded to carrier
  dpete 3/13/02 pts 13615 When there are multiple trailers with the same trl_number the procs gets an
      error on multiple rows coming back on subquery with =, etc.  Change to match to trl_id
  DPETE PTS 14524 pass billto to rec id 4 sp
	DPETE PTS 13854 move eqpt type over 7 positions and insert weight per spec
  nkres 22963 implement credit reason aka correction indicator
  DPETE 24684 add THR to list of third party terms and use edicode fro terms if specified
  DMEEK 12/15/04 PTS 25868 - create 'Audit Data' 539 records for Splitbill Milkrun Invoices
  AROSS 4/26/05 PTS 27890 Fix for 05_CLSRV records being created when the opt_trc_type4 value is stored in the DB as the empty string
  AROSS 5/02/05 PTS 27930 Corrected logic to retrieve BOL and PO numbers.  Take the BOL or PO with the lowest sequence attached to the orderheader.
  AROSS 6/16/05 PTS 28435 Added time to 0539_DTSDT record to match specs.  Should contain ship date & time.
  AROSS 6/20/05 PTS 28511 Addded support for miscellaneous records of type _EQ for Driver/Tractor/Trailer information
  AROSS 7/14/05 PTS 28928 Correct BOL/PO logic for miscellaneous invoices.  Need to use reference numbers attached to the invoiceheader.
  AROSS 8/25/05 PTS 29483 Added option to add revtypeX value to 1 record based on generalinfo setting.
  DPETE PTS29672 9/2/5 Look for MAX(ref_number) for PO and BL to avoid problem when more than one record exists for the
        same type and same sequence number (added by customer using SQL)
  DMEEK 10/06/05 PTS 29999 Carter's splitbill process doesn't permit the ordernumber to also be used as the invoicenumber
		because of this a provision was made using a 539 record to pass the Ord_Number through to the 210  
  AROSS 12/06/05 PTS 38034 Add the miscellaneous 539_DTDRT record for the delivery date/time based on generalinfo setting		    
  DMEEK 12/28/05 PTS 30257 Change 539 record's total splitbill weight to use new ivd_shared_wgt field
  DMEEK 07/12/06 SR33750 Create new 539 record with calculated invoice total less GST tax
  DMEEK 08/18/06 SR34172 Create new 539 recored with custom Carter splitbill "Contracted Route Mileage"
  AROSS 10/12/2006 PTS34202 - Additional handling for Null values in the ivh_terms field.
  AROSS 03.21.2007  PTS 36774 - Replace carriage return and line feed characters in the invoice remarks field.
  AROSS 05/23/2007 PTS 36995 - Add misc type record to header containing the sum of all pickup weights for an order.
  AROSS 08/07/2007 PTS 38457 - Add Misc type record to header containing the Carter's system BOL ID
  AROSS 12/13/2007 PTS 40651 - Expand reference types for BOL to include BM abbr value
  AROSS 3/19/2009   PTS  46552 - Corrected MISC record output.
  AROSS 2/26.2010  PTS 49961 - Add Team Single indicator;Support stops before charges switch
  AROSS 2.26.2010  PTS 50029 - Restrict EDI 210 Creation based on credit terms and TP Configuration.
  AROSS 4.16.2010  PTS 52038 - Add unique transaction ID to output as Misc record.
  AROSS 9.29.2010  PTS 51364 - Add correction indicator of CR for Credit memo.
  AROSS	4.12.2013  PTS 68669 - Update for negative quantities in header record of credit memo. pad left after minus sign
  AROSS 5.16.2013  PTS 67721 - correction for dedicated bill invoices.
  AROSS 5.28.2014 PTS 76263 - fix unfiltered select in splitbill section
  NQIAO	5.05.2015 PTS 79371 - add LB Number column to the end of the invoice header record for the dedicated bill
 */
 
DECLARE	@ord_hdrnumber		INTEGER,
		@datacol 			VARCHAR(255),
		@TPNumber 			VARCHAR(20),
		@cmp_id 			VARCHAR(8), 
		@SCAC 				VARCHAR(15),
		@qualifier 			VARCHAR(3),
		@billto 			VARCHAR(8),
		@shipdate 			VARCHAR(12),
		@revtype 			VARCHAR(8), 
		@ivhrevtype 		VARCHAR(6),
		@revstart 			SMALLINT,
		@docid   			VARCHAR(30),
		@getdate 			DATETIME,
		@opttrctype4 		VARCHAR(6),
		@eqpttype 			VARCHAR(30),
		@varchar6 			VARCHAR(6),
		@ivh_hdrnumber		INT,
		@210ExportNotes		char(1),
		@ivh_remark			varchar(255),
		@SplitbillMilkrun 	VARCHAR(1),
		@InvoiceTotalType 	VARCHAR(1), --SR33750
		@TotalFSC 			VARCHAR(12),
		@TotalWeight 		VARCHAR(12),
		@TotalCharge 		VARCHAR(12),
		@RawCharge			VARCHAR(12),
		@CentPerMile		VARCHAR(3),
		@TotalChargeLessFuel	VARCHAR(12),
		@ChargeLessFuel		VARCHAR(12),
		@DetailRawCharge	VARCHAR(12),
		@RouteMiles 		VARCHAR(12),
		@TotalGrandRate		VARCHAR(12),
		@equiplist			VARCHAR(25),		--PTS 28511 start
		@startpos			INT,
		@nextpos			INT,
		@NextEqType			VARCHAR(6),
		@driver				VARCHAR(10),
		@tractor			VARCHAR(10),
		@trailer			VARCHAR(15),		--PTS 28511 End
		@v_UseRevType		VARCHAR(8),
		@v_RevValue			VARCHAR(6),			--PTS 29483
		@Ord_Number			VARCHAR (12),		--PTS 29999
		@Rate_Type			VARCHAR (10) ,   	--PTS DAN MEEK
		@v_add_pupwgt		char(1),			--36995
		@v_pupweight		varchar(12), 		--AROSS PTS 36995
		@system_bolid		INT,				--38457 Aross
		@v_teamSingle		CHAR(1),			--49961
		@v_driver1			VARCHAR(8),
		@v_driver2			VARCHAR(8),
		@v_GIstopsBeforeCharges CHAR(1),
		@v_RestrictByTerms	CHAR(1),@ivh_terms VARCHAR(6),@v_restrictTermsLevel CHAR(1),	--50029
		@vc_totWeight5		VARCHAR(5),
		@vc_totWeight7		VARCHAR(7),
		@vc_totCharge		VARCHAR(9),
		@dbh_id				INT,				-- 79371
		@dbsd_id_createbill	INT					-- 79371	
		
CREATE TABLE #210_hdr_temp (
	ivh_order_by		VARCHAR(8) NULL,
	ivh_billto			VARCHAR(8) NULL,
	ivh_shipper			VARCHAR(8) NULL,
	ivh_consignee		VARCHAR(8) NULL,
	ivh_invoicenumber	VARCHAR(12) NULL,
	ivh_terms			VARCHAR(2) NULL,
	ord_hdrnumber		INTEGER NULL,
	ivh_totalcharge		VARCHAR(12) NULL,
	ivh_deliverydate	DATETIME NULL,
	ivh_shipdate		DATETIME NULL,
	ivh_currency		VARCHAR(6) NULL,
	ivh_trailer			VARCHAR(13) NULL,
	ivh_tractor			VARCHAR(8) NULL,
	equipment			VARCHAR(13) NULL,
	ivh_totalweight		VARCHAR(12) NULL,
	ivh_totalpieces		VARCHAR(12) NULL,
	bol					VARCHAR(30) NULL,
	po					VARCHAR(15) NULL,
	shipdate			CHAR(8) NULL,
	deliverydate		CHAR(8) NULL,
	numeric_invoice		VARCHAR(12) NULL,
	ivh_revtype1		VARCHAR(6) NULL,
	ivh_revtype2		VARCHAR(6) NULL,
	ivh_revtype3		VARCHAR(6) NULL,
	ivh_revtype4		VARCHAR(6) NULL,
	equipmenttype		VARCHAR(6) NULL,
	edieqpttype			VARCHAR(6) NULL,
	cmr_reason		varchar(6) null)

SELECT @qualifier = ' '

SELECT @ivh_hdrnumber = ivh_hdrnumber,@billto = ivh_billto, @dbh_id = dbh_id	-- 79371 add dbh_id
	from invoiceheader where ivh_invoicenumber = @invoice_number	-- AROSS PTS 28928

-- 79371
if	@dbh_id > 0 
	select	@dbsd_id_createbill = dbsd_id_createbill
	from	dedbillingheader 
	where	dbh_id = @dbh_id

--get driver information for team/single 
--PTS 49961
select @v_driver1 = isnull(ivh_driver,'UNKNOWN'),@v_driver2 = isnull(ivh_driver2,'UNKNOWN')
	from invoiceheader
	where ivh_hdrnumber = @ivh_hdrnumber
	
--PTS 49961 Get GI Value
Select @v_GIstopsBeforeCharges =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI210_StopsBeforeCharges'
--PTS49961 END
--50029
Select @v_RestrictByTerms =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI_RestrictByTerms'
--END 50029

SELECT @eqpttype = gi_string1 
  FROM generalinfo
 WHERE gi_name = 'EDI210EqptTypeSource'

SELECT @eqpttype = UPPER(ISNULL(@eqpttype,''))

IF @v_RestrictByTerms = 'Y' 
BEGIN	 --50029  Check Terms
	 select @ivh_terms  = isnull(ivh_terms,'UNK') from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber
	 
	 --get terms restriction
	 select @v_restrictTermsLevel = isnull(trp_210_restrictTerms,'B') 
		from edi_trading_partner
		where cmp_id = @billto

	--allow PPD only 
	if (@v_restrictTermsLevel = 'P' and @ivh_terms <> 'PPD')
		RETURN
	--allow COL only
	if (@v_restrictTermsLevel = 'C' and @ivh_terms <> 'COL')
		RETURN	
END	--50029 

SELECT @getdate = getdate()
/* doc id is ddhhmmssmssoooooooooo where oooooooooo is a 10 pos ord_hdr, dd is day, hh = hour etc */
SELECT @docid = 
	replicate('0',2-datalength(convert(VARCHAR(2),datepart(month,@getdate))))
	+ convert(VARCHAR(2),datepart(month,@getdate))
	+ replicate('0',2-datalength(convert(VARCHAR(2),datepart(day,@getdate))))
	+ convert(VARCHAR(2),datepart(day,@getdate))
	+replicate('0',2-datalength(convert(VARCHAR(2),datepart(hour,@getdate))))
	+ convert(VARCHAR(2),datepart(hour,@getdate))
	+replicate('0',2-datalength(convert(VARCHAR(2),datepart(minute,@getdate))))
	+ convert(VARCHAR(2),datepart(minute,@getdate))
	+replicate('0',2-datalength(convert(VARCHAR(2),datepart(second,@getdate))))
	+ convert(VARCHAR(2),datepart(second,@getdate))
	+replicate('0',3-datalength(convert(VARCHAR(3),datepart(millisecond,@getdate))))
	+ convert(VARCHAR(3),datepart(millisecond,@getdate))
	+ REPLICATE('0',10-DATALENGTH(RIGHT(CONVERT(VARCHAR(20),@invoice_number),10)))
	+ RIGHT(CONVERT(VARCHAR(20),@invoice_number),10)
		
-- create a temp table with most of the data..
INSERT INTO #210_hdr_temp
	SELECT 
	ISNULL(invoiceheader.ivh_order_by,'MISSING') ivh_order_by,
	ISNULL(invoiceheader.ivh_billto,'MISSING') ivh_billto,
	--DPH PTS 24778 9/20/04
	--ISNULL(invoiceheader.ivh_shipper,'MISSING') ivh_shipper,
	--ISNULL(invoiceheader.ivh_consignee,'MISSING') ivh_consignee,
	ISNULL(invoiceheader.ivh_originpoint,'MISSING') ivh_shipper,
	ISNULL(invoiceheader.ivh_destpoint,'MISSING') ivh_consignee,
	--DPH PTS 24778 9/20/04
	invoiceheader.ivh_invoicenumber, 
	ivh_terms = Case (Select Rtrim(IsNull(edicode,'')) From labelfile where labeldefinition = 'creditterms' and
         abbr = ISNULL(invoiceheader.ivh_terms,'UNK'))
      When '' Then
		    Case invoiceheader.ivh_terms
		      When 'COL' then 'CC'
		      When '3RD' then 'TP'
		      When 'TBP' then 'TP'
		      When 'TPB' then 'TP'
	        When 'THR' Then 'TP'
		      ELSE 'PP'
		    End
      ELse Left((Select Rtrim(IsNull(edicode,'')) From labelfile where labeldefinition = 'creditterms' and
         abbr = invoiceheader.ivh_terms),2) + Replicate (' ',2 - Len(Left((Select Rtrim(IsNull(edicode,'')) From labelfile where labeldefinition = 'creditterms' and
         abbr = invoiceheader.ivh_terms),2)))
      End, 
	ISNULL(invoiceheader.ord_hdrnumber,0) ord_hdrnumber,
	RIGHT(Convert(VARCHAR(12),CONVERT(int,(ISNULL(invoiceheader.ivh_totalcharge,0.00)*100))),9) ivh_totalcharge,
	invoiceheader.ivh_deliverydate,
	invoiceheader.ivh_shipdate, 
	ISNULL(invoiceheader.ivh_currency,'U') ivh_currency, 
	ivh_trailer,
	ivh_tractor,
	equipment = 
	    Case ISNULL(invoiceheader.ivh_trailer,'UNKNOWN')
	      When 'UNKNOWN' then CASE ISNULL(ivh_tractor,'UNKNOWN')
				WHEN 'UNKNOWN' then ivh_carrier
				ELSE ivh_tractor
				END
	      Else ivh_trailer
	    End , 
	CONVERT(VARCHAR(12),CONVERT(int,ISNULL(invoiceheader.ivh_totalweight,0.0))) ivh_totalweight,	   --28666
	RIGHT(CONVERT(VARCHAR(12),CONVERT(int,ISNULL(invoiceheader.ivh_totalpieces,0.0))),6)  ivh_totalpieces,	  --28666
	BOL = CASE invoiceheader.ord_hdrnumber
			WHEN 0 THEN	  ISNULL((SELECT SUBSTRING(MAX(ISNULL(ref_number,' ')),1,30) FROM referencenumber  --misc & supplemental invoices
						 WHERE ref_table = 'invoiceheader'
							 AND ref_tablekey = invoiceheader.ivh_hdrnumber
							 AND ref_type in ('BL#','BOL','BL','BM')
							 AND ref_sequence = (Select min(ref_sequence) FROM referencenumber,invoiceheader
								WHERE ref_table = 'invoiceheader'
									AND ref_tablekey = invoiceheader.ivh_hdrnumber
									AND ref_type in ('BL#','BOL','BL','BM')
									AND invoiceheader.ivh_invoicenumber = @invoice_number)),' ')
			ELSE	ISNULL((SELECT SUBSTRING(MAX(ISNULL(ref_number,' ')),1,30) FROM referencenumber	  --regular order based invoice
						 WHERE ref_table = 'orderheader'
							 AND ref_tablekey = invoiceheader.ord_hdrnumber
							 AND ref_type in ('BL#','BOL','BL','BM')
							 AND ref_sequence = (Select min(ref_sequence) FROM referencenumber,invoiceheader
								WHERE ref_table = 'orderheader'
									AND ref_tablekey = invoiceheader.ord_hdrnumber
									AND ref_type in ('BL#','BOL','BL','BM')
									AND invoiceheader.ivh_invoicenumber = @invoice_number)),' ')
		END,	  --PTS 27930 AROSS Select first BOL attached to orderheader
	PO =  CASE invoiceheader.ord_hdrnumber
				WHEN 0 THEN	 ISNULL((SELECT SUBSTRING(MAX(ISNULL(ref_number,' ')),1,30) FROM referencenumber  --misc & supplemental invoices
								WHERE ref_table = 'invoiceheader'
								 AND ref_tablekey = invoiceheader.ivh_hdrnumber
								 AND ref_type in ('PO#','PO')
								 AND ref_sequence = (Select min(ref_sequence) FROM referencenumber,invoiceheader
								WHERE ref_table = 'invoiceheader'
									AND ref_tablekey = invoiceheader.ivh_hdrnumber
									AND ref_type in ('PO#','PO')
									AND invoiceheader.ivh_invoicenumber = @invoice_number)),' ')
				ELSE ISNULL((SELECT SUBSTRING(MAX(ISNULL(ref_number,' ')),1,15) FROM referencenumber		--regular order based invoice
						 WHERE ref_table = 'orderheader'
							AND ref_tablekey = invoiceheader.ord_hdrnumber
							AND ref_type in ('PO','PO#')
							AND ref_sequence = (SELECT MIN(ref_sequence) FROM referencenumber, invoiceheader
								WHERE ref_table = 'orderheader'
								AND ref_tablekey = invoiceheader.ord_hdrnumber
								AND ref_type in ('PO','PO#')
								AND invoiceheader.ivh_invoicenumber = @invoice_number)),' ')
			END,		 --PTS 27930 AROSS Select first PO attached to orderheader
	ISNULL(convert(char(8),ivh_shipdate,112),'19500101') shipdate,
	ISNULL(convert(char(8),ivh_deliverydate,112),'20491231') deliverydate,
	numeric_invoice = 
	   CASE 
	     WHEN substring(invoiceheader.ivh_invoicenumber,1,1)  > '9' then substring(invoiceheader.ivh_invoicenumber,2,len(invoiceheader.ivh_invoicenumber) - 1)
	     WHEN substring(invoiceheader.ivh_invoicenumber,len(invoiceheader.ivh_invoicenumber),1) > '9' then  substring(invoiceheader.ivh_invoicenumber,1,len(invoiceheader.ivh_invoicenumber) - 1)
	     ELSE invoiceheader.ivh_invoicenumber
	  END,
	ivh_revtype1,
	ivh_revtype2,
	ivh_revtype3,
	ivh_revtype4,
	equipmenttype = 
		Case ISNULL(invoiceheader.ivh_trailer,'UNKNOWN')
	      WHEN 'UNKNOWN' THEN
				CASE @eqpttype
					WHEN 'TYPE1' THEN (SELECT ISNULL(Trc_type1,'') from tractorprofile where trc_number = ivh_tractor)
					WHEN 'TYPE2' THEN  (SELECT ISNULL(Trc_type2,'') from tractorprofile where trc_number = ivh_tractor)
					WHEN 'TYPE3' THEN  (SELECT ISNULL(Trc_type3,'') from tractorprofile where trc_number = ivh_tractor)
					WHEN 'TYPE4' THEN  (SELECT ISNULL(Trc_type4,'') from tractorprofile where trc_number = ivh_tractor)
					WHEN 'OPTTYPE4' THEN  (SELECT ISNULL(opt_trc_type4,'') from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
					ELSE (SELECT ISNULL(Trc_type1,'') from tractorprofile where trc_number = ivh_trailer)
				END
			 ELSE 
				CASE @eqpttype
					WHEN 'TYPE1' THEN (SELECT ISNULL(Trl_type1,'') from trailerprofile where trl_id = ivh_trailer)
					WHEN 'TYPE2' THEN  (SELECT ISNULL(Trl_type2,'') from trailerprofile where trl_id = ivh_trailer)
					WHEN 'TYPE3' THEN  (SELECT ISNULL(Trl_type3,'') from trailerprofile where trl_id = ivh_trailer)
					WHEN 'TYPE4' THEN  (SELECT ISNULL(Trl_type4,'') from trailerprofile where trl_id = ivh_trailer)
					WHEN 'OPTTYPE4' THEN  (SELECT ISNULL(opt_trl_type4,'') from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
					WHEN 'ORDTYPE1' THEN  (SELECT ISNULL(trl_type1,'') from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
					WHEN 'ORDTYPE2' THEN  (SELECT ISNULL(ord_Trl_type2,'') from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
					WHEN 'ORDTYPE3' THEN  (SELECT ISNULL(ord_Trl_type3,'') from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
					WHEN 'ORDTYPE4' THEN  (SELECT ISNULL(ord_Trl_type4,'') from orderheader where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
					ELSE (SELECT ISNULL(Trl_type1,'') from trailerprofile where trl_id = ivh_trailer)
				END
			END,
	edieqpttype = @varchar6,
	cmr_reason = case when isnull(ivh_definition,'LH') = 'LH' then 'XX'
			when ivh_definition = 'RBIL' then 'RB'
			when ivh_definition = 'CRD'  then 'CR'			--51364
			else 'MB'
		     end
	FROM invoiceheader 
	WHERE ( invoiceheader.ivh_invoicenumber = @invoice_number )

/* Get the EDI CODE (if specified) for the equipment type. If no EDI code specfied, use equipement type */
UPDATE	#210_hdr_temp
   SET	edieqpttype = ISNULL((SELECT edicode FROM labelfile 
					   WHERE labeldefinition = CASE @eqpttype 
							WHEN 'TYPE1' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType1' ELSE 'TrlType1' END
							WHEN 'TYPE2' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType2' ELSE 'TrlType2' END 
							WHEN 'TYPE3' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType3' ELSE 'TrlType3' END
							WHEN 'TYPE4' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType4' ELSE 'TrlType4' END
							WHEN 'ORDTYPE1' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType1' ELSE 'TrlType1' END 
							WHEN 'ORDTYPE2' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType2' ELSE 'TrlType2' END  
							WHEN 'ORDTYPE3' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType3' ELSE 'TrlType3' END 
							WHEN 'ORDTYPE4' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType4' ELSE 'TrlType4' END  
							WHEN 'OPTTYPE4' THEN CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType4' ELSE 'TrlType4' END
							ELSE CASE ivh_trailer WHEN 'UNKNOWN' THEN 'TrcType1' ELSE 'TrlType1' END
						END AND
						abbr = equipmenttype AND
						edicode IS NOT NULL AND
						LEN(RTRIM(edicode)) > 0),equipmenttype)

SELECT @billto = ivh_billto
  FROM #210_hdr_temp

SELECT  @SCAC=UPPER(ISNULL(gi_string1, 'SCAC'))
  FROM	generalinfo 
 WHERE	gi_name='SCAC'

-- Is SCAC based on RevType? get from labelfile
SELECT  @revstart = CHARINDEX('REVTYPE',@SCAC,1)

IF @revstart  = 0 
   SELECT @SCAC=substring(@SCAC,1,4)
ELSE
  BEGIN
   SELECT @revtype = SUBSTRING(@SCAC,@revstart,8)

   SELECT @ivhrevtype = 
     Case @revtype
       When 'REVTYPE1' Then ivh_revtype1
       When 'REVTYPE2' Then ivh_revtype2
       When 'REVTYPE3' Then ivh_revtype3
       When 'REVTYPE4' Then ivh_revtype4
       Else ivh_revtype1
     End
   FROM #210_hdr_temp

  
   SELECT @SCAC = isnull(UPPER(edicode),abbr)
   FROM labelfile
   WHERE labeldefinition = @revtype
   AND    abbr = @ivhrevtype

   -- handle spaces in edicode field
   IF LEN(RTRIM(@SCAC)) = 0 
	--SELECT @SCAC = @ivhrevtype
       SELECT @SCAC = 'ERRL' 

   SELECT @SCAC = SUBSTRING(@SCAC,1,4)

END

--pts 29483 aross moved section up
SELECT @ord_hdrnumber = ord_hdrnumber
FROM #210_hdr_temp

--PTS 29483 Start Aross for MW Logistics
Select @v_UseRevType =  IsNull(UPPER(LEFT(gi_string1,8)),'UNKNOWN') FROM generalinfo WHERE gi_name = 'EDI_AddRevType'
	   SELECT @v_RevValue =  Case @v_UseRevType
								when 'REVTYPE1' then ord_revtype1
								when 'REVTYPE2' then ord_revtype2
								when 'REVTYPE3' then ord_revtype3
								when 'REVTYPE4' then ord_revtype4
								else ' '
							 End	
		FROM orderheader
		WHERE	ord_hdrnumber = @ord_hdrnumber					 
		
--PTS49961 set team/single status
	if (@v_driver1 <> 'UNKNOWN' and @v_driver2 <> 'UNKNOWN')
		set @v_teamSingle = 'T'
	if (@v_driver1 = 'UNKNOWN' and @v_driver2 = 'UNKNOWN')
		set @v_teamSingle = 'X'
	if (@v_driver1 <> 'UNKNOWN' and @v_driver2 = 'UNKNOWN')
		set @v_teamSingle = 'S'		
--END 49961 		

--PTS 68669 Condition quantities for output
UPDATE #210_hdr_temp
SET ivh_totalpieces =    CASE SUBSTRING(ivh_totalpieces,1,1)
							WHEN '-' Then '-' + REPLICATE('0',6 - datalength(ivh_totalpieces)) + SUBSTRING(ivh_totalpieces,2,datalength(ivh_totalpieces) - 1) 
							 Else REPLICATE('0',6 - datalength(ivh_totalpieces)) + ivh_totalpieces
						 END,
	ivh_totalweight = 	CASE SUBSTRING(ivh_totalweight,1,1)
							WHEN '-' Then '-' + REPLICATE('0',7 - datalength(ivh_totalweight)) + SUBSTRING(ivh_totalweight,2,datalength(ivh_totalweight) - 1) 
							 Else REPLICATE('0',7 - datalength(ivh_totalweight)) + ivh_totalweight
						 END,
	ivh_totalcharge = 	CASE SUBSTRING(ivh_totalcharge,1,1)
							WHEN '-' Then '-' + REPLICATE('0',9 - datalength(ivh_totalcharge)) + SUBSTRING(ivh_totalcharge,2,datalength(ivh_totalcharge) - 1) 
							 Else REPLICATE('0',9 - datalength(ivh_totalcharge)) + ivh_totalcharge
						 END					 					 


--END 68669

--67721
SELECT @v_RevValue = ISNULL(@v_revValue,'')

-- retrieve Trading Partner number
SELECT  @TPNumber = edi_trading_partner.trp_210id, @210ExportNotes = Isnull(trp_210ExportNotes, 'N')
FROM edi_trading_partner,#210_hdr_temp 
WHERE cmp_id=#210_hdr_temp.ivh_billto
SELECT @TPNumber = ISNULL(@TPNumber,'NOVALUE')

SELECT @datacol = 
 '1' +				-- Record ID
'39' +						-- Record Version
#210_hdr_temp.ivh_invoicenumber +		-- InvoiceNumber
	replicate(' ',15-datalength(#210_hdr_temp.ivh_invoicenumber)) +
#210_hdr_temp.BOL +				-- BOL
	replicate(' ',30-datalength(#210_hdr_temp.BOL)) +
#210_hdr_temp.shipdate +				-- ShipDate
#210_hdr_temp.deliverydate +				-- DeliveryDate
#210_hdr_temp.PO +				-- PO
	replicate(' ',15-datalength(#210_hdr_temp.PO)) +
#210_hdr_temp.ivh_terms +			-- Terms
	replicate(' ',2-datalength(#210_hdr_temp.ivh_terms)) + --DPM 01/26/05 PTS26612
	replicate('0',6-datalength(#210_hdr_temp.ivh_totalpieces )) +
#210_hdr_temp.ivh_totalpieces  +	-- Count
	replicate('0',5-datalength(Substring(CONVERT(VARCHAR(5),ABS(CONVERT(int,#210_hdr_temp.ivh_totalweight))),1,5) )) +
	Substring(CONVERT(VARCHAR(5),ABS(CONVERT(int,#210_hdr_temp.ivh_totalweight))),1,5) + --weight
--Substring(#210_hdr_temp.ivh_totalweight,1,5)  +	-- Weight
	replicate('0',9-datalength(ivh_totalcharge)) +
#210_hdr_temp.ivh_totalcharge +	-- TotalCharge
isnull(#210_hdr_temp.cmr_reason,'XX') +		-- CorrectionIndicator
#210_hdr_temp.equipment +			-- EquipmentNumber
	replicate(' ',13-datalength(#210_hdr_temp.equipment)) +
substring(#210_hdr_temp.ivh_currency,1,1) +	-- Currency U or C
'   ' +  -- weight qualifier Erin leaves blank
'   ' +  -- qty qualifier Erin leaves blank
'   ' +  -- charge qualifier Erin leaves blank
'000000000' +  -- rate Ering leaves empty
@SCAC + replicate(' ',4-datalength(@SCAC))+                                          -- SCAC added 11/22/99
replicate('0',14-datalength(numeric_invoice)) + numeric_invoice +  --added 5/10/00 
replicate('0',7-datalength(SUBSTRING(#210_hdr_temp.ivh_totalweight,1,7) )) +
SUBSTRING(#210_hdr_temp.ivh_totalweight,1,7)  +	-- Weight
SUBSTRING(edieqpttype,1,6) + replicate(' ',6 - datalength(SUBSTRING(edieqpttype,1,6))) +  -- added 10/15/01
@v_RevValue + replicate(' ',6 - datalength(@v_RevValue)) +
isnull(@v_teamSingle,'X') +
replicate('0', 10-datalength(convert(varchar(10), isnull(@dbsd_id_createbill, 0)))) + convert(varchar(10), isnull(@dbsd_id_createbill, 0))		-- 79371
FROM #210_hdr_temp

INSERT Into EDI_210 (data_col,doc_id,trp_id)
VALUES (@datacol,@docid,@TPNumber)					


--AROSS PTS 52038 Add document ID record
  INSERT edi_210 (data_col,trp_id,doc_id)
  SELECT 
      data_col = '539_IDRID210-' +RTRIM(@invoice_number)+ '-' +
      CONVERT(varchar(8),@getdate,12) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),1,2) + 
      SUBSTRING(CONVERT(varchar(8),@getdate,8),4,2) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),7,2) +
      CONVERT(varchar(3),DATEPART(Ms,@getdate)),
     trp_id = @TPNumber, doc_id = @docid

--PTS 28435 ARoss. Section commented out.
-- pts8085 need misc record for shipdate 5/26/00	   
--SELECT @shipdate =  convert(VARCHAR(8),ivh_shipdate,112)
--  FROM #210_hdr_temp

--DMEEK 12/15/04 PTS 25868 
SELECT @SplitbillMilkrun = gi_string1 FROM generalinfo WHERE gi_name = 'SplitbillMilkrun'

IF @SplitbillMilkrun = 'Y' 
 BEGIN
 /* SELECT @Rate_Type = ivd_splitbillratetype from invoiceheader, invoicedetail where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber and ivh_invoicenumber = @invoice_number
  SELECT @Ord_Number = RIGHT(convert(varchar(12),CONVERT(int,@ord_hdrnumber)),12) --PTS76263(removed from)	from orderheader --PTS 29999
  SELECT @TotalFSC = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_fsc),0.00)*100)),9) from invoicedetail where ord_hdrnumber = @ord_hdrnumber
  SELECT @TotalCharge = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_charge),0.00)*100)),9) from invoicedetail where ord_hdrnumber = @ord_hdrnumber
   SELECT @RawCharge = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_rawcharge)-SUM(ivd_fsc)-SUM(ivd_cbadjustment)- SUM(ivd_oradjustment),0.00)*100)),9) from invoicedetail where ord_hdrnumber = @ord_hdrnumber
  SELECT @RouteMiles = RIGHT(convert(varchar(12),CONVERT(dec(9,2),b.ord_quantity)),6) from orderheader a, orderheader b where a.ord_fromorder = b.ord_number and a.ord_hdrnumber = @ord_hdrnumber
  SELECT @CentPerMile = convert(varchar(12), convert(int,Round(ISNULL(convert(dec,@TotalFSC)*100/convert(dec,@RouteMiles),0),0))) from invoiceheader where ord_hdrnumber = @ord_hdrnumber 
  SELECT @TotalChargeLessFuel = RIGHT(convert( varchar(12),convert(int,(ISNULL(SUM(ivd_charge),0.00) - ISNULL(SUM(ivd_fsc),0.00))* 100)),9) from invoicedetail where ord_hdrnumber = @ord_hdrnumber
  SELECT @ChargeLessFuel = RIGHT(convert( varchar(12),convert(int,ISNULL(ivd_charge - ivd_fsc,0.00)*100)),9) from invoiceheader, invoicedetail where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber and ivh_invoicenumber = @invoice_number
  SELECT @DetailRawCharge = RIGHT(convert( varchar(12),convert(int,ISNULL((ivd_rawcharge)-(ivd_fsc)-(ivd_cbadjustment)-(ivd_oradjustment),0.00)*100)),9) from invoiceheader, invoicedetail where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber and ivh_invoicenumber = @invoice_number
  SELECT @TotalGrandRate = RIGHT(convert( varchar(12), (convert(dec(9,2),@TotalFSC)*.01) + ivd_rate),9) from invoiceheader, invoicedetail where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber and ivh_invoicenumber = @invoice_number
  --AROSS 8.7.07 PTS 38457
  SELECT @system_bolid =  ivd_bolid FROM invoicedetail INNER JOIN invoiceheader ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber  WHERE	invoiceheader.ivh_invoicenumber = @invoice_number AND invoicedetail.ivd_sequence = 1
	PTS76263		*/
  --Begin 76263	Mods
	SELECT 
	@Rate_Type = ivd_splitbillratetype, 
	@ChargeLessFuel = RIGHT(convert( varchar(12),convert(int,ISNULL(ivd_charge - ivd_fsc,0.00)*100)),9), 
	@DetailRawCharge = RIGHT(convert( varchar(12),convert(int,ISNULL((ivd_rawcharge)-(ivd_fsc)-(ivd_cbadjustment)-(ivd_oradjustment),0.00)*100)),9),
	@TotalGrandRate = RIGHT(convert( varchar(12), (convert(dec(9,2),@TotalFSC)*.01) + ivd_rate),9) 
	from invoiceheader inner join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
	where ivh_invoicenumber = @invoice_number

	SELECT @Ord_Number = RIGHT(convert(varchar(12),CONVERT(int,@ord_hdrnumber)),12) --PTS76263(removed from)  from orderheader --PTS 29999

	SELECT 
	@TotalFSC = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_fsc),0.00)*100)),9),
	@TotalCharge = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_charge),0.00)*100)),9), 
	@RawCharge = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_rawcharge)-SUM(ivd_fsc)-SUM(ivd_cbadjustment)- SUM(ivd_oradjustment),0.00)*100)),9),
	@TotalChargeLessFuel = RIGHT(convert( varchar(12),convert(int,(ISNULL(SUM(ivd_charge),0.00) - ISNULL(SUM(ivd_fsc),0.00))* 100)),9) 
	from invoicedetail where ord_hdrnumber = @ord_hdrnumber

	SELECT @RouteMiles = RIGHT(convert(varchar(12),CONVERT(dec(9,2),b.ord_quantity)),6) 
	from orderheader a inner join orderheader b on a.ord_fromorder = b.ord_number
	where a.ord_hdrnumber = @ord_hdrnumber

	SELECT @CentPerMile = convert(varchar(12), convert(int,Round(ISNULL(convert(dec,@TotalFSC)*100/convert(dec,@RouteMiles),0),0))) 
	from invoiceheader where ord_hdrnumber = @ord_hdrnumber 

	--AROSS 8.7.07 PTS 38457
	SELECT @system_bolid =  ivd_bolid 
	FROM invoicedetail INNER JOIN invoiceheader ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber  
	WHERE      invoiceheader.ivh_invoicenumber = @invoice_number AND invoicedetail.ivd_sequence = 1
	--END 76263 Mods		
	
	
	
  IF @Rate_Type in ('fixedcost', 'fixedcwt')
    BEGIN
	SELECT @TotalWeight = (select sum(id.ivd_wgt)
	from invoicedetail id, invoiceheader ih
	where id.ivh_hdrnumber = ih.ivh_hdrnumber
	and ih.ivh_billto = ih2.ivh_billto
	and ih2.ord_hdrnumber = ih.ord_hdrnumber)
	from invoiceheader ih2, invoicedetail id2
	where ih2.ivh_hdrnumber = id2.ivh_hdrnumber
	and id2.ivd_splitbillratetype in ('fixedcost', 'fixedcwt')
	and ih2.ivh_invoicenumber = @invoice_number
    END
  ELSE
    BEGIN
      	SELECT @TotalWeight = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_shared_wgt),0.00))),9) from invoicedetail where ord_hdrnumber = @ord_hdrnumber --DMEEK 12/28/05 PTS 30257 
    END

  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFORD' + convert(char(12),@Ord_Number) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber --PTS 29999
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFFSC' + convert(char(12),@TotalFSC) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFTOC' + convert(char(12),@TotalCharge) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFTOW' + convert(char(12),@TotalWeight) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFTRC' + convert(char(12),@RawCharge) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFCPM' + convert(char(3),@CentPerMile) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFTLF' + convert(char(12),@TotalChargeLessFuel) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFCLF' + REPLICATE('0',9 - DATALENGTH( @ChargeLessFuel)) + convert(char(12),@ChargeLessFuel)+ REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber	--PTS 46552
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFDRC' + convert(char(12),@DetailRawCharge) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFTGR' + convert(char(12),@TotalGrandRate) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210 (data_col,doc_id,trp_id)--DMEEKD 08/18/06 SR34172
      SELECT	data_col = '539REFDRM' + convert(varchar(12),@RouteMiles) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
  INSERT edi_210(data_col,doc_id,trp_id) --AROSS  8.7.07 PTS 38457
  	SELECT data_col = '539REFSBL' + convert(varchar(12),@system_bolid) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber

END
--DMEEK 12/15/04 PTS 25868 

--DMEEK 07/12/06 SR33750 
SELECT @InvoiceTotalType = gi_string1 FROM generalinfo WHERE gi_name = 'EDI210InvoiceTotalLessGST'

If @InvoiceTotalType = 'Y'
 BEGIN
  SELECT @TotalCharge = RIGHT(convert( varchar(12),convert(int,ISNULL(SUM(ivd_charge),0.00)*100)),9) from invoiceheader, invoicedetail where invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber and ivh_invoicenumber = @invoice_number and invoicedetail.cht_itemcode <> 'GST'

  INSERT edi_210 (data_col,doc_id,trp_id)
      SELECT	data_col = '539REFNET' + convert(char(12),@TotalCharge) + REPLICATE(' ',64),doc_id = @docid,trp_id = @TPNumber
END
--DMEEK 07/12/06 SR33750 


--AROSS 6/16/05 PTS 28435.  Corrected to pull ship date & time.
INSERT edi_210 (data_col,doc_id,trp_id)
	SELECT	data_col = '539_DTSDT' + CONVERT(varchar(8),ivh_shipdate,112) +
		SUBSTRING(CONVERT(varchar(8),ivh_shipdate,8),1,2) +
		SUBSTRING(CONVERT(varchar(8),ivh_shipdate,8),4,2)+ REPLICATE(' ',60),
			doc_id = @docid,
			trp_id = @TPNumber
	FROM #210_hdr_temp

--AROSS 12/6/05 PTS 38304 Added Delivery date and time to invoice as a misc type record.	
IF (SELECT UPPER(LEFT(ISNULL(gi_string1,'N'),1)) FROM generalinfo WHERE gi_name = 'EDI210_DeliveryDateTime') = 'Y'
	INSERT edi_210(data_col,doc_id,trp_id)
		SELECT data_col = '539_DTDRT' + CONVERT(varchar(8),ivh_deliverydate,112) + 
			SUBSTRING(CONVERT(varchar(8),ivh_deliverydate,8),1,2) +
			SUBSTRING(CONVERT(varchar(8),ivh_deliverydate,8),4,2) ,
			doc_id = @docid,
			trp_id = @TPNumber
		FROM #210_hdr_temp	


-- pts9979 add opt_trctype4 misc record
INSERT edi_210 (data_col,doc_id,trp_id)
	SELECT	data_col = '539_CLSRV' + opt_trc_type4 + REPLICATE(' ',64 - len(opt_trc_type4)),
			doc_id = @docid,
			trp_id = @TPNumber
	  FROM  orderheader
	 WHERE	ord_hdrnumber = @ord_hdrnumber AND 
			(opt_trc_type4 IS NOT NULL AND 
			 opt_trc_type4 <> 'UNK'
			 AND opt_trc_type4 <> '')	--AROSS Fix for PTS 27890 
			 
-- ntk 20731+ write ivh_billdate if gi setting is on
if (select UPPER(LEFT(ISNULL(gi_string1,'N'),1)) from generalinfo where gi_name = 'EDI210WriteInvDate') = 'Y'
	insert edi_210 (data_col,doc_id,trp_id)
		select data_col = '539_DTIDT' + convert(varchar(8),isnull(ivh_billdate,getdate()),112) + convert(varchar(2),isnull(ivh_billdate,getdate()),108) + right(convert(varchar(5),isnull(ivh_billdate,getdate()),108),2),
			doc_id = @docid,
			trp_id = @tpnumber
		from invoiceheader
		where ivh_invoicenumber = @invoice_number
-- 20731-
--AROSS PTS 28407 add total miles record
if (select ISNULL(left(gi_string1,1),'N') from generalinfo where gi_name = 'EDI210_TotalMiles') = 'Y'
	BEGIN
	    --SELECT @TotalMiles = CONVERT(varchar(8),ivh_totalmiles) FROM invoiceheader WHERE ivh_invoicenumber = @invoice_number	
	    INSERT edi_210(data_col,doc_id,trp_id)
		SELECT data_col = '539_MSTMI' + CONVERT(varchar(8),ISNULL(ivh_totalmiles,000)),
			doc_id = @docid,
			trp_id = @tpnumber
		FROM invoiceheader
		WHERE ivh_invoicenumber = @invoice_number

	END
--28407	
-- 18940 Check

-- 18940 Check to see if the orderheader number is null.
-- This is the case whenever the invoice is supplemental or ,miscellaneous.
if @ord_hdrnumber <> 0
	exec edi_210_record_id_5_39_sp @invoice_number,'orderheader',@ord_hdrnumber,@TPNumber,@docid
else
begin 
	select @ivh_hdrnumber = ivh_hdrnumber from invoiceheader where ivh_invoicenumber = @invoice_number
	exec edi_210_record_id_5_39_sp @invoice_number,'invoiceheader',@ivh_hdrnumber,@TPNumber,@docid
end

-- 22963 Write header remarks Regarding EDI As _RMs
If @210ExportNotes = 'Y'
begin
	select @ivh_remark = ivh_remark from invoiceheader where ivh_invoicenumber = @invoice_number
	if @ivh_remark is not null and @ivh_remark <> '' 
	BEGIN
		--PTS 36774 Replace CrLf characters in the message
		SELECT @ivh_remark =  REPLACE(@ivh_remark,CHAR(13),'|')
		SELECT @ivh_remark = REPLACE(@ivh_remark,CHAR(10),'')	
		SELECT @ivh_remark = REPLACE(@ivh_remark,CHAR(34),'')
		--END PTS 36774
	
		INSERT edi_210 (data_col, trp_id, doc_id)
			select '539_RM' + @ivh_remark,@TPNumber,@docid 
	END		
end

--PTS 28511 AROSS Add misc records for equipment types defined in generalinfo setting.
select @equiplist = gi_string1, @startpos = 1, @nextpos = 1 from generalinfo where gi_name = 'EDI210_EquipmentRef'
If Len(@equiplist) > 2
    BEGIN   
			Select @driver = ivh_driver, @tractor = ivh_tractor, @trailer = ivh_trailer		 --get equipment data
			from	invoiceheader where ivh_invoicenumber = @invoice_number
		while @nextpos > 0
			begin   
				select @nextpos = charindex(',',@equiplist,@startpos)
					if @nextpos > 0
					begin   
						select @NextEqType = substring(@equiplist,@startpos,@nextpos - @startpos), @startpos = @nextpos + 1
							If Len(@NextEqType) > 2
								INSERT edi_210(data_col,doc_id,trp_id)
								SELECT data_col = '5' +		--record_id
								'39' +			--version_id
								'_EQ' +			--Type identifier
								@NextEqType +		--Equipment_type
								CASE	@nextEqType
									When 'TRC' Then @tractor
									When 'DRV' Then	@Driver
									When 'TRL' Then @trailer
									Else 'UNK '
								End,
								doc_id = @docid,
								trp_id = @tpnumber	
			
					end	
			else
				begin	 
					select @NextEqType = substring(@equiplist,@startpos,len(@equiplist) +1 - @startpos), @startpos = @nextpos + 1
						If Len(@NextEqType) > 2
							INSERT edi_210(data_col,doc_id,trp_id)
							SELECT data_col = '5' +		--record_id
							'39' +			--version_id
							'_EQ' +			--Type identifier
							@NextEqType +		--Equipment_type
							CASE	@nextEqType
								When 'TRC' Then @tractor
								When 'DRV' Then	@Driver
								When 'TRL' Then @trailer
								Else 'UNK '
							End,
							doc_id = @docid,
							trp_id = @tpnumber
				
				end	 
			end	
    	 
    END			  --END PTS28511 AROSS 
    
    /*PTS 36995 - ARoss; add 5 misc record w/ total pup weight */
    SELECT @v_add_pupwgt =  UPPER(ISNULL(trp_210_pupwgt,'N'))
    FROM	edi_trading_partner
    WHERE	trp_210id = @TPNumber 
    
    IF @v_add_pupwgt = 'Y' AND @ord_hdrnumber > 0
    BEGIN
    	SELECT @v_pupweight =  SUM(ISNULL(fgt_weight,0)) FROM freightdetail f
    		 INNER JOIN stops s
			ON s.stp_number =  f.stp_number
	WHERE s.ord_hdrnumber = @ord_hdrnumber
			and s.stp_type = 'PUP'
    
    --output the misc record
    	    INSERT edi_210(data_col,doc_id,trp_id)
    		SELECT data_col = '539REFTOW' + @v_pupweight,
    			doc_id = @docid,
			trp_id = @tpnumber
			
    END			   
    
    /* PTS 36995 - END */
    

SELECT 	@ord_hdrnumber=ord_hdrnumber from #210_hdr_temp
-- put out the 3 record ID 2 records (N1 loop)

SELECT @cmp_id=#210_hdr_temp.ivh_shipper from #210_hdr_temp
exec edi_210_record_id_2_39_sp @cmp_id,'SH',@TPNumber,@billto,@docid, @ord_hdrnumber

SELECT @cmp_id=#210_hdr_temp.ivh_consignee from #210_hdr_temp
exec edi_210_record_id_2_39_sp @cmp_id,'CN',@TPNumber,@billto,@docid, @ord_hdrnumber

exec edi_210_record_id_2_39_sp @billto,'BT',@TPNumber,@billto,@docid, @ord_hdrnumber

-- invoice details

--PTS 49961 reverse output of stopoff and charge detail records
IF @v_GIstopsBeforeCharges = 'Y'
	begin
		--stopoffs
		exec edi_210_record_id_4_39_sp @invoice_number,@ord_hdrnumber,@TPNumber,@docid,@billto
		--charges
		exec edi_210_record_id_3_39_sp @invoice_number,@TPNumber,@docid

	end
ELSE
	begin
		--charges
		exec edi_210_record_id_3_39_sp @invoice_number,@TPNumber,@docid

		-- stops
		exec edi_210_record_id_4_39_sp @invoice_number,@ord_hdrnumber,@TPNumber,@docid,@billto
	end
--PTS49961 END

INSERT edi_210 (data_col,trp_id,doc_id)
     SELECT 
      data_col = 'END',
      trp_id = @TPNumber, doc_id = @docid	

GO
GRANT EXECUTE ON  [dbo].[edi_210_all_39_sp] TO [public]
GO
