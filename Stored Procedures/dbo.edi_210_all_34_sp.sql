SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_210_all_34_sp] 
	@invoice_number varchar( 12 )

 as

-- dpete 3/8/00 limit length on trailer, BL, PO
-- dpete tps7651 change trp_id to trp_210id

--begin transaction EDI210
declare	@ord_hdrnumber integer
declare @TPNumber varchar(20)
declare @cmp_id varchar(8), @SCAC varchar(4)
DECLARE @datacol varchar(250)
declare @docid   varchar(30)
declare @getdate datetime


select @SCAC=gi_string1
from generalinfo where gi_name='SCAC'
SELECT @SCAC = ISNULL(@SCAC,'SCAC')

SELECT @getdate = getdate()
/* doc id is ddhhmmssmssoooooooooo where oooooooooo is a 10 pos ord_hdr, dd is day, hh = hour etc */
SELECT @docid = 
	replicate('0',2-datalength(convert(varchar(2),datepart(month,@getdate))))
	+ convert(varchar(2),datepart(month,@getdate))
	+ replicate('0',2-datalength(convert(varchar(2),datepart(day,@getdate))))
	+ convert(varchar(2),datepart(day,@getdate))
	+replicate('0',2-datalength(convert(varchar(2),datepart(hour,@getdate))))
	+ convert(varchar(2),datepart(hour,@getdate))
	+replicate('0',2-datalength(convert(varchar(2),datepart(minute,@getdate))))
	+ convert(varchar(2),datepart(minute,@getdate))
	+replicate('0',2-datalength(convert(varchar(2),datepart(second,@getdate))))
	+ convert(varchar(2),datepart(second,@getdate))
	+replicate('0',3-datalength(convert(varchar(3),datepart(millisecond,@getdate))))
	+ convert(varchar(3),datepart(millisecond,@getdate))
	+ REPLICATE('0',10-DATALENGTH(RIGHT(CONVERT(varchar(20),@invoice_number),10)))
	+ RIGHT(CONVERT(varchar(20),@invoice_number),10)


-- create a temp table with most of the data..
SELECT 
ISNULL(invoiceheader.ivh_order_by,'MISSING') ivh_order_by,
ISNULL(invoiceheader.ivh_billto,'MISSING') ivh_billto,
ISNULL(invoiceheader.ivh_shipper,'MISSing') ivh_shipper,
ISNULL(invoiceheader.ivh_consignee,'MISSING') ivh_consignee,
ISNULL(invoiceheader.ivh_invoicenumber,@invoice_number) ivh_invoicenumber, 
ISNULL(invoiceheader.ord_hdrnumber,0) ord_hdrnumber,
ivh_terms = 
	case invoiceheader.ivh_terms
	   when 'COL' then 'CC'
	   when '3RD' then 'TP'
           when 'TBP' then 'TP'
	   else 'PP'
	end, 
right(CONVERT(varchar(12),Convert(int,(ISNULL(invoiceheader.ivh_totalcharge,0.00) * 100))),9) ivh_totalcharge, 
ISNULL(invoiceheader.ivh_currency,' ') ivh_currency, 
ivh_trailer = 
	Case ivh_trailer
	  when null then ' '
	  when 'UNKNOWN' then ' '
	  else LEFT(ivh_trailer,13)
	end, 
right(CONVERT( varchar(12),ISNULL(invoiceheader.ivh_totalweight,0.0)),5) ivh_totalweight, 
right(convert(varchar(12),ISNULL(invoiceheader.ivh_totalpieces,0.0) ),6) ivh_totalpieces,
BOL = (SELECT LEFT(ISNULL(max(ref_Number),' '),30) FROM referencenumber 
	WHERE ref_table = 'orderheader'
	and ref_tablekey = invoiceheader.ord_hdrnumber
	and ref_type in ('BOL','BL#')),
PO = (SELECT LEFT(ISNULL(max(ref_Number),' '),15) FROM referencenumber 
	WHERE ref_table = 'orderheader'
	and ref_tablekey = invoiceheader.ord_hdrnumber
	and ref_type = 'PO'),
ISNULL(convert(char(10),ivh_shipdate,20),'19500101') shipdate,
ISNULL(convert(char(10),ivh_deliverydate,20),'20491231') deliverydate

INTO #210_hdr_temp
FROM invoiceheader
WHERE ( invoiceheader.ivh_invoicenumber = @invoice_number )



if @@rowcount = 0 
  begin
	PRINT 'edi_210_all_34_sp argument Invoice '+@invoice_number+' returns no data'
        RETURN 1
  end
-- retrieve Trading Partner number
-- pts7651 was trp_id
select @TPNumber = edi_trading_partner.trp_210id 
from edi_trading_partner,#210_hdr_temp 
where cmp_id=#210_hdr_temp.ivh_billto
select @TPNumber = isnull(@TPNumber,'NOVALUE')


-- return the row from the temp table 

SELECT @datacol =  
 '1' +				-- Record ID
'34' +						-- Record Version
#210_hdr_temp.ivh_invoicenumber +		-- InvoiceNumber
	replicate(' ',15-datalength(#210_hdr_temp.ivh_invoicenumber)) +
#210_hdr_temp.BOL +				-- BOL
	replicate(' ',30-datalength(#210_hdr_temp.BOL)) +
left(shipdate,4) +	substring(shipdate,6,2) + right(shipdate,2)	+		-- ShipDate
left(deliverydate,4) +	substring(deliverydate,6,2) + right(deliverydate,2)	 +				-- DeliveryDate
#210_hdr_temp.PO +				-- PO
	replicate(' ',15-datalength(#210_hdr_temp.PO)) +
#210_hdr_temp.ivh_terms +			-- Terms
	replicate('0',6-datalength(#210_hdr_temp.ivh_totalpieces)) +
#210_hdr_temp.ivh_totalpieces  +	-- Count
	replicate('0',5-datalength(#210_hdr_temp.ivh_totalweight )) +
#210_hdr_temp.ivh_totalweight + 	-- Weight
	replicate('0',9-datalength(#210_hdr_temp.ivh_totalcharge)) +
#210_hdr_temp.ivh_totalcharge +	 -- TotalCharge
'XX' +						-- CorrectionIndicator
#210_hdr_temp.ivh_trailer +			-- EquipmentNumber
	replicate(' ',13-datalength(#210_hdr_temp.ivh_trailer)) +
substring(#210_hdr_temp.ivh_currency,1,1)
FROM #210_hdr_temp

If @datacol IS NULL
   BEGIN
	PRINT 'Data col for '+@invoice_number+' contains null data see following'
        SELECT * from #210_hdr_temp
	RETURN 2
   END
  
   
INSERT edi_210 (data_col, doc_id,trp_id)
VALUES ( @datacol,@docid,
   @TPNumber )


-- add any misc records associated with the header
exec edi_210_record_id_5_34_sp @invoice_number,@TPNumber,1,@docid

-- put out the 3 record ID 2 records (N1 loop)
select @cmp_id=#210_hdr_temp.ivh_shipper from #210_hdr_temp

exec edi_210_record_id_2_34_sp  @cmp_id,'SH',@TPNumber,@docid
select @cmp_id=#210_hdr_temp.ivh_consignee from #210_hdr_temp
--select @n101code='CN'

exec edi_210_record_id_2_34_sp  @cmp_id,'CN',@TPNumber,@docid
select @cmp_id=#210_hdr_temp.ivh_billto from #210_hdr_temp
--select @n101code='BT'

exec edi_210_record_id_2_34_sp  @cmp_id,'BT',@TPNumber,@docid

-- add any misc records associated with the name and address (2) recs
exec edi_210_record_id_5_34_sp @invoice_number,@TPNumber,2,@docid

-- invoice details
exec edi_210_record_id_3_34_sp @invoice_number,@TPNumber,@docid

-- add any misc records associated with the #3 invoice details
exec edi_210_record_id_5_34_sp @invoice_number,@TPNumber,3,@docid

-- stops
SELECT @ord_hdrnumber = ord_hdrnumber
FROM #210_hdr_temp
exec edi_210_record_id_4_34_sp @ord_hdrnumber,@TPNumber,@docid

-- misc records associated with stops
exec edi_210_record_id_5_34_sp @invoice_number,@TPNumber,4,@docid


--COMMIT TRANSACTION EDI210




GO
GRANT EXECUTE ON  [dbo].[edi_210_all_34_sp] TO [public]
GO
