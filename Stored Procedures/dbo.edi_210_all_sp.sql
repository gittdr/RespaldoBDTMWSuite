SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- dpete 7/21/00 pts7651 substitute trp_210id for trp_id

CREATE PROCEDURE [dbo].[edi_210_all_sp] 
	@invoice_number varchar( 12 )

 as
declare	@ord_hdrnumber integer
declare @bug varchar(255)
declare @TPNumber varchar(20)
declare @bol varchar(30), @po varchar(30)
declare @cmp_id varchar(8), @n101code varchar(2), @SCAC varchar(4)
declare @yyyy varchar(4), @mm varchar(2), @dd varchar(2), @dateformat varchar(8)

select 	@ord_hdrnumber=ord_hdrnumber from invoiceheader
WHERE ( invoiceheader.ivh_invoicenumber = @invoice_number )

select @SCAC=gi_string1
from generalinfo where gi_name='SCAC'
select @dateformat=''

-- Retrieve BOL and PO
select @bol = max(ref_number) from referencenumber where ref_type='BL#' and ref_table='orderheader' and ref_tablekey=@ord_hdrnumber
select @po=max(ref_number) from referencenumber where ref_type='PO' and ref_table='orderheader' and ref_tablekey=@ord_hdrnumber
select @bol = isnull(@bol,'')
select @po = isnull(@po,'')


-- create a temp table with most of the data..
SELECT 
invoiceheader.ivh_order_by,
invoiceheader.ivh_billto,
invoiceheader.ivh_shipper,
invoiceheader.ivh_consignee,
invoiceheader.ivh_invoicenumber, 
invoiceheader.ivh_terms, 
invoiceheader.ivh_totalcharge,
invoiceheader.ivh_deliverydate,
invoiceheader.ivh_shipdate, 
invoiceheader.ivh_currency, 
invoiceheader.ivh_trailer, 
invoiceheader.ivh_totalweight, 
invoiceheader.ivh_totalpieces,
BOL = @bol,
PO = @po,
shipdateformat=@dateformat,
deliverydateformat=@dateformat,
invoiceheader.ivh_hdrnumber

INTO #210_hdr_temp
FROM invoiceheader
WHERE ( invoiceheader.ivh_invoicenumber = @invoice_number )

-- For FLorida ROck pTS 7235
Update #210_hdr_temp
Set ivh_totalcharge = (SELECT ROUND(sum(ivd_charge),2)
                       FROM invoicedetail
			WHERE invoicedetail.ivh_hdrnumber = #210_hdr_temp.ivh_hdrnumber)
-- retrieve Trading Partner number
select @TPNumber = edi_trading_partner.trp_210id from edi_trading_partner,#210_hdr_temp where cmp_id=#210_hdr_temp.ivh_billto
select @TPNumber = isnull(@TPNumber,'NOVALUE')

-- condition terms
update #210_hdr_temp set ivh_terms = 'PP' where ivh_terms = 'PPD'
update #210_hdr_temp set ivh_terms = 'PP' where ivh_terms = 'UNK'
update #210_hdr_temp set ivh_terms = 'CC' where ivh_terms = 'COL'
update #210_hdr_temp set ivh_terms = 'TP' where ivh_terms = '3RD'

-- condition nulls
update #210_hdr_temp set ivh_totalpieces = isnull(ivh_totalpieces,0),
	ivh_totalweight = isnull(ivh_totalweight,0),
	ivh_trailer = isnull(ivh_trailer,''),
	ivh_currency = isnull(ivh_currency,'')

-- condition ship date
select @yyyy=convert( varchar(4),datepart(yy,#210_hdr_temp.ivh_shipdate)),
@mm=convert( varchar(2),datepart(mm,#210_hdr_temp.ivh_shipdate)),
@dd=convert( varchar(2),datepart(dd,#210_hdr_temp.ivh_shipdate))
from #210_hdr_temp
update #210_hdr_temp set shipdateformat=
replicate('0',4-datalength(@yyyy)) + @yyyy +
replicate('0',2-datalength(@mm)) + @mm +
replicate('0',2-datalength(@dd)) + @dd

-- condition delivery date
select @yyyy=convert( varchar(4),datepart(yy,#210_hdr_temp.ivh_deliverydate)),
@mm=convert( varchar(2),datepart(mm,#210_hdr_temp.ivh_deliverydate)),
@dd=convert( varchar(2),datepart(dd,#210_hdr_temp.ivh_deliverydate))
from #210_hdr_temp
update #210_hdr_temp set deliverydateformat=
replicate('0',4-datalength(@yyyy)) + @yyyy +
replicate('0',2-datalength(@mm)) + @mm +
replicate('0',2-datalength(@dd)) + @dd

-- return the row from the temp table 
INSERT edi_210
SELECT 
data_col = '1' +				-- Record ID
'10' +						-- Record Version
#210_hdr_temp.ivh_invoicenumber +		-- InvoiceNumber
	replicate(' ',15-datalength(#210_hdr_temp.ivh_invoicenumber)) +
#210_hdr_temp.BOL +				-- BOL
	replicate(' ',30-datalength(#210_hdr_temp.BOL)) +
shipdateformat +				-- ShipDate
deliverydateformat +				-- DeliveryDate
#210_hdr_temp.PO +				-- PO
	replicate(' ',15-datalength(#210_hdr_temp.PO)) +
#210_hdr_temp.ivh_terms +			-- Terms
	replicate(' ',2-datalength(#210_hdr_temp.ivh_terms)) +
	replicate('0',6-datalength(convert( varchar( 12 ), #210_hdr_temp.ivh_totalpieces ))) +
convert( varchar( 12 ), #210_hdr_temp.ivh_totalpieces ) +	-- Count
	replicate('0',5-datalength(convert( varchar( 12 ), #210_hdr_temp.ivh_totalweight ))) +
convert( varchar( 12 ), #210_hdr_temp.ivh_totalweight ) +	-- Weight
	replicate('0',7-datalength(convert( varchar( 12 ), #210_hdr_temp.ivh_totalcharge ))) +
convert( varchar( 12 ), #210_hdr_temp.ivh_totalcharge ) +	-- TotalCharge
'XX' +						-- CorrectionIndicator
#210_hdr_temp.ivh_trailer +			-- EquipmentNumber
	replicate(' ',13-datalength(#210_hdr_temp.ivh_trailer)) +
substring(#210_hdr_temp.ivh_currency,1,1),	-- Currency U or C
tpr_id=@TPNumber

FROM #210_hdr_temp
WHERE #210_hdr_temp.ivh_invoicenumber = @invoice_number 


-- add any misc records associated with the header
exec edi_210_record_id_5_sp @invoice_number,@TPNumber,1

-- put out the 3 record ID 2 records (N1 loop)
select @cmp_id=#210_hdr_temp.ivh_shipper from #210_hdr_temp
select @n101code='SH'
exec edi_210_record_id_2_sp @cmp_id,@n101code,@TPNumber
select @cmp_id=#210_hdr_temp.ivh_consignee from #210_hdr_temp
select @n101code='CN'
exec edi_210_record_id_2_sp @cmp_id,@n101code,@TPNumber
select @cmp_id=#210_hdr_temp.ivh_billto from #210_hdr_temp
select @n101code='BT'
exec edi_210_record_id_2_sp @cmp_id,@n101code,@TPNumber

-- add any misc records associated with the name and address (2) recs
exec edi_210_record_id_5_sp @invoice_number,@TPNumber,2

-- invoice details
exec edi_210_record_id_3_sp @invoice_number,@TPNumber

-- add any misc records associated with the #3 invoice details
exec edi_210_record_id_5_sp @invoice_number,@TPNumber,3

-- stops
exec edi_210_record_id_4_sp @ord_hdrnumber,@TPNumber

-- misc records associated with stops
exec edi_210_record_id_5_sp @invoice_number,@TPNumber,4

GO
GRANT EXECUTE ON  [dbo].[edi_210_all_sp] TO [public]
GO
