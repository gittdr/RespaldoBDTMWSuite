SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_1_34_sp]
	@ord_number char(12), @cancel_flag char(1),
	@docid varchar(30)
 as
/**
 * 
 * NAME:
 * dbo.edi_214_record_id_1_34_sp
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
 * 10311 dpete 6/25/01 Make v34 manual 214 work in PS V2001 (and 2002)
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

DECLARE @TPNumber varchar(20)
DECLARE @BLRef varchar(30), @PORef varchar(30)
DECLARE @cmp_id varchar(8), @n101code varchar(2), @SCAC varchar(20)
DECLARE @n1shipper varchar(8), @n1consignee varchar(8), @n1billto varchar(8)
DECLARE @ordterms char(2),@ordtotalweight varchar(7),@ordtotalpieces varchar(7)
DECLARE @ordhdrnumber int,@storeplantnbr varchar(12),@totalcharge varchar(9)
DECLARE @ordtotalcharge varchar(9), @totalmiles varchar(4)
DECLARE @calctotalcharge money
DECLARE @ordstartdate varchar(12)
DECLARE @revtype varchar(8), @ordrevtype varchar(6)
DECLARE @revstart smallint
DECLARE @revtype1 varchar(6),@revtype2 varchar(6),@revtype3 varchar(6),@revtype4 varchar(6)
DECLARE @getdate datetime


 SELECT @storeplantnbr = '   '
 SELECT @cancel_flag = ISNULL(@cancel_flag,'N')

-- collect order header information.
 SELECT 
	@ordhdrnumber=ord_hdrnumber,
	@n1shipper=ord_shipper,
	@n1consignee=ord_consignee, 
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
	@ordtotalweight=CONVERT(varchar(7),ISNULL(orderheader.ord_totalweight,0)), 
	@ordtotalpieces=CONVERT(varchar(7),ISNULL(orderheader.ord_totalpieces,0)),
	@ordtotalcharge=CONVERT(varchar(9),CONVERT(int,ISNULL(ord_totalcharge,0.0) * 100)),
        @ordstartdate = CONVERT(varchar(8),ord_startdate,112)+
	SUBSTRING(CONVERT(varchar(8),ord_startdate,8),1,2) + 
	SUBSTRING(CONVERT(varchar(8),ord_startdate,8),4,2),
        @revtype1 = ord_revtype1,
	@revtype2 = ord_revtype2,
	@revtype3 = ord_revtype3,
	@revtype4 = ord_revtype4
 FROM orderheader
 WHERE ( orderheader.ord_number = @ord_number )


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


-- dpete for Trilex

 SELECT @BLRef = ISNULL(max(ref_number),'  ')
 FROM referencenumber
 WHERE ref_table = 'orderheader'
 AND   ref_tablekey = @ordhdrnumber
 AND   ref_type in ('BL#','BL')

 SELECT @BLRef = ISNULL(@BLRef,'')
 
 SELECT @PORef = ISNULL(max(ref_number),'  ')
 FROM referencenumber
 WHERE ref_table = 'orderheader'
 AND   ref_tablekey = @ordhdrnumber
 AND   ref_type in ('PO','PO#')

SELECT @PORef = ISNULL(@PORef,'')

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
 SELECT @TPNumber = trp_id
 FROM edi_trading_partner
 WHERE cmp_id=@n1billto

 SELECT @TPNumber = ISNULL(@TPNumber,@n1BillTo)


-- create edi 214 record 1 from collected data
INSERT edi_214 (data_col, trp_id, doc_id) 
SELECT 

data_col = '1' +				-- Record ID
 	'34' +						-- Record Version
	@scac +				-- SCAC
	replicate(' ',4-datalength(@scac)) +
	CONVERT(varchar(15),@ord_number) +				-- OrderNumber
	replicate(' ',15-datalength(CONVERT(varchar(15),@ord_number))) +
	@BLRef +				-- BOL
	replicate(' ',30-datalength(@BLRef)) +
	@PORef +				-- PO
	replicate(' ',15-datalength(@PORef)) +
	@storeplantnbr +				-- storeplantnumber
	replicate(' ',12-datalength(@storeplantnbr)) +
	replicate('0',6-datalength(@ordtotalweight )) +
	@ordtotalweight +			-- Weight
	replicate('0',9-datalength(@totalcharge)) + -- AMount
	@totalcharge +
	replicate('0',6-datalength(@ordtotalpieces )) +

	@ordtotalpieces +			-- Count
	@ordterms +				-- terms
	replicate(' ',12) +			-- Not used signature
	replicate ('0',4-datalength(@totalmiles)) +
	@totalmiles +					-- miles
	'00000000' +					-- Not used TTS TO
	replicate(' ',20) +				-- Not used userdef
	replicate(' ',30),				-- Not used shipment number
	trp_id = @TPNumber,
	doc_id = @docid

-- pts7738 need misc record for shipdate 4/12/00
 INSERT edi_214 (data_col,trp_id,doc_id)
 SELECT 
       data_col = '434_DTSDT' +	@ordstartdate + REPLICATE(' ',64),trp_id = @TPNumber, doc_id = @docid

 -- PTS7962 add a unique id for this trans  = doc#-ord#-YYMMDDHHMM
  SELECT @getdate = getdate()
 
  INSERT edi_214 (data_col,trp_id,doc_id)
  SELECT 
      data_col = '434_IDRID214-' +RTRIM(@ord_number)+ '-' +
      CONVERT(varchar(8),@getdate,12) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),1,2) + 
      SUBSTRING(CONVERT(varchar(8),@getdate,8),4,2) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),7,2),
     trp_id = @TPNumber, doc_id = @docid

 -- If an indication of a cancel must be passed	
 IF @cancel_flag = 'Y' 
    INSERT edi_214 (data_col,trp_id,doc_id)
     SELECT 
      data_col = '434_XXCANCEL',
      trp_id = @TPNumber, doc_id = @docid

-- add on #4 ref numbers for the orderheader

EXEC edi_214_record_id_4_34_sp @ordhdrnumber,'orderheader',@ordhdrnumber,@TPNumber,@docid


EXEC edi_214_record_id_2_34_sp @n1shipper,'SH',@TPNumber,@n1billto,@docid
 EXEC edi_214_record_id_2_34_sp @n1consignee,'CN',@TPNumber,@n1billto,@docid
 EXEC edi_214_record_id_2_34_sp @n1billto,'BT',@TPNumber,@n1billto,@docid




GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_1_34_sp] TO [public]
GO
