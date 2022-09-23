SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_1_10_sp]
	@ord_number char(12)
 as
/**
 * 
 * NAME:
 * dbo.edi_214_record_id_1_10_sp
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
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

declare @TPNumber varchar(20)
declare @bol varchar(30), @po varchar(30)
declare @cmp_id varchar(8), @n101code varchar(2), @SCAC varchar(4)
declare @n1shipper varchar(8), @n1consignee varchar(8), @n1billto varchar(8)
declare @ordterms char(2),@ordtotalweight varchar(7),@ordtotalpieces varchar(7)
declare @ordhdrnumber int,@storeplantnbr varchar(12),@totalcharge varchar(9)
declare @ordtotalcharge varchar(9), @totalmiles varchar(4)

SELECT @SCAC=UPPER(CONVERT(CHAR(4),gi_string1))
FROM generalinfo where gi_name='SCAC'

SELECT @SCAC=ISNULL(@SCAC,'SCAC')

SELECT @storeplantnbr = '   '

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
	@ordtotalweight=convert(varchar(7),ISNULL(orderheader.ord_totalweight,0)), 
	@ordtotalpieces=convert(varchar(7),ISNULL(orderheader.ord_totalpieces,0)),
	@ordtotalcharge=CONVERT(varchar(9),CONVERT(int,ISNULL(ord_totalcharge,0.0) * 100))
FROM orderheader
WHERE ( orderheader.ord_number = @ord_number )

-- Get total order miles from stops
SELECT @totalmiles=CONVERT(varchar(4),SUM(stp_ord_mileage))
FROM   stops
WHERE  ord_hdrnumber = @ordhdrnumber

-- Retrieve BOL and PO
SELECT @bol = max(ref_number) 
FROM referencenumber 
WHERE ref_type in ('BL#','BOL') 
AND ref_table='orderheader' 
AND ref_tablekey=@ordhdrnumber

SELECT @bol=ISNULL(@bol,'  ')

SELECT @po=max(ref_number) 
FROM referencenumber 
WHERE ref_type='PO' 
AND ref_table='orderheader' 
AND ref_tablekey=@ordhdrnumber

SELECT @po=ISNULL(@po,'  ')


-- Retrieve invoice total charge if any
SELECT @totalcharge = CONVERT(varchar(9),CONVERT( int,ISNULL(ivh_totalcharge,0.0) * 100) )
FROM   invoiceheader
WHERE  ord_hdrnumber = @ordhdrnumber

-- Substitute pre rate if no invoice charge
SELECT @totalcharge=ISNULL(@totalcharge,@ordtotalcharge)

-- retrieve Trading Partner number
SELECT @TPNumber = trp_id
FROM edi_trading_partner
WHERE cmp_id=@n1billto

SELECT @TPNumber = ISNULL(@TPNumber,@n1BillTo)

-- create edi 214 record 1 from collected data
INSERT edi_214 (data_col, trp_id)
SELECT 
data_col = '1' +				-- Record ID
 	'10' +						-- Record Version
	@scac +				-- SCAC
	replicate(' ',4-datalength(@scac)) +
	convert(varchar(15),@ord_number) +				-- OrderNumber
	replicate(' ',15-datalength(convert(varchar(15),@ord_number))) +
	@BOL +				-- BOL
	replicate(' ',30-datalength(@BOL)) +
	@PO +				-- PO
	replicate(' ',15-datalength(@PO)) +
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
	trp_id = @TPNumber



exec edi_214_record_id_2_10_sp @n1shipper,'SH',@TPNumber
exec edi_214_record_id_2_10_sp @n1consignee,'CN',@TPNumber
exec edi_214_record_id_2_10_sp @n1billto,'BT',@TPNumber





GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_1_10_sp] TO [public]
GO
