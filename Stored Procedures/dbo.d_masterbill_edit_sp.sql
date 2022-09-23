SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[d_masterbill_edit_sp] (@stringparm  varchar(12))    
AS    

select ivh_invoicenumber,
	ivh_totalcharge,
	ivh_invoicestatus,
	ivh_mbstatus,
	ivh_billto,
	ivh_mbnumber,
	ivh_shipper,
	ivh_consignee
from invoiceheader
where ivh_mbnumber=@stringparm
order by ivh_invoicenumber
    

GO
GRANT EXECUTE ON  [dbo].[d_masterbill_edit_sp] TO [public]
GO
