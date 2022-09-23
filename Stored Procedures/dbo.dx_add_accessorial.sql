SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  This procedure will insert an accessorial charge in the invoicedetail table IFF no invoice currently
	exists for the order number passed.  

	Arguments
		ordnumber varchar(12) the PowerSuite order number the the accessorial is to be attached to
		chargetype varchar(6)
		Quantity float

	Return codes
		1   success
		-1	 database error
		-2	 invalid order number or order status  is not available, or planned or dispatched or started or complete
		-3	 invalid charge type, or retired chargetype
		-4  invoice exists, cannot add charge type
*/

CREATE PROCEDURE [dbo].[dx_add_accessorial] @ordnumber varchar(12),@chargetype varchar(6),@quantity float
AS

DECLARE @@ivdnumber int, @ordhdrnumber int, @ordstatus varchar(6), @sum float, @retcode int

SELECT @ordhdrnumber = ord_hdrnumber, @ordstatus = ord_status from orderheader where ord_number = @ordnumber
  
  IF @ordhdrnumber IS NULL or @ordstatus NOT IN ('AVL','PLN','DSP','STD','CMP') 
		RETURN -2

  IF (SELECT COUNT(1) FROM invoiceheader where ord_hdrnumber = @ordhdrnumber) > 0 
		RETURN -4
  
  IF (SELECT COUNT(1) FROM chargetype where cht_itemcode = @chargetype and ISNULL(cht_retired,'N') = 'N')  = 0
		RETURN -3

 EXEC @@ivdnumber = dbo.getsystemnumber 'INVDET',NULL 
 IF @@error <> 0 RETURN -1

 INSERT INTO invoicedetail (ivh_hdrnumber,ivd_number,ivd_description,    						 -- 1
	cht_itemcode,ivd_quantity,ivd_rate,ivd_charge,ivd_taxable1,ivd_taxable2,ivd_taxable3,ivd_taxable4,  --2
	ivd_unit,cur_code,ivd_currencydate,ivd_glnum,ord_hdrnumber,ivd_type,ivd_rateunit,ivd_billto,			--3
	ivd_sequence,cmd_code,cmp_id,		--4
	ivd_sign,cht_basisunit,ivd_fromord,cht_class,ivd_invoicestatus)			--5
 SELECT 0,@@ivdnumber,cht_description,											--1
	cht_itemcode,@quantity,cht_rate,ROUND(@quantity * cht_rate,2),cht_taxtable1,cht_taxtable2,cht_taxtable3,cht_taxtable4, --2
	cht_unit,cht_currunit,getdate(),cht_glnum,@ordhdrnumber,'LI',cht_rateunit,'UNKNOWN',			--3
	999,'UNKNOWN','UNKNOWN',				--4
	cht_sign,cht_basisunit,'Y',cht_class,'HLD'			--5
   FROM chargetype 
  WHERE cht_itemcode = @chargetype

 SELECT @retcode = @@error
 IF @retcode<>0
    BEGIN
		exec dx_log_error 0, 'dx_add_accessorial Failed', @retcode, ''
        RETURN -1
    END

/* reset order totals */
 SELECT @sum = SUM(ivd_charge)
   FROM invoicedetail 
  WHERE ord_hdrnumber = @ordhdrnumber

 UPDATE orderheader 
    SET ord_accessorial_chrg = @sum, ord_totalcharge = (ord_charge + @sum)
  WHERE ord_hdrnumber = @ordhdrnumber 

 RETURN 1
 
GO
GRANT EXECUTE ON  [dbo].[dx_add_accessorial] TO [public]
GO
