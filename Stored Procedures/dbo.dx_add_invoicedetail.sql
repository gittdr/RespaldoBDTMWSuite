SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_add_invoicedetail] @ord_number varchar(12),@chargetype varchar(6),@quantity float,@rate money,@amount money,@reftype varchar(6),@refnumber varchar(30),@@ivdnumber int OUTPUT
AS

 DECLARE @ordhdrnumber int, @ordstatus varchar(6), @sum float

 SELECT @ordhdrnumber = ord_hdrnumber, @ordstatus = ord_status from orderheader where ord_number = @ord_number
  
 IF @ordhdrnumber IS NULL or @ordstatus NOT IN ('PND','AVL','PLN','DSP','STD','CMP') 
	RETURN -2

 IF (SELECT COUNT(1)  FROM invoiceheader where ord_hdrnumber = @ordhdrnumber) > 0 
	RETURN -4

 IF (SELECT COUNT(1) FROM chargetype where cht_itemcode = @chargetype and ISNULL(cht_retired,'N') = 'N')  = 0
	RETURN -3

 IF (@rate = 0 OR @quantity = 0) AND @amount > 0
	SELECT @quantity = 1, @rate = @amount
 
 IF @@ivdnumber <> 0  --update routine
 BEGIN
	SELECT @@ivdnumber = ABS(@@ivdnumber)
	DELETE FROM invoicedetail WHERE ivd_number = @@ivdnumber
 END
 ELSE
 BEGIN
	EXEC @@ivdnumber = dbo.getsystemnumber 'INVDET',NULL 
 END

 IF ISNULL(@refnumber,'') > ''
	SELECT @reftype = CASE ISNULL(@reftype,'') WHEN '' THEN 'REF' ELSE @reftype END
 ELSE
	SELECT @reftype = 'REF', @refnumber = ''

 IF @amount > 0
 	 /* RK 02/18/2009 - Added to set appropriate charge for negative rate acc charges */
	 IF @rate < 0
	 BEGIN
	   SELECT @amount = (@rate * @quantity)
	 END
     /* END RK */
 
 BEGIN
	 INSERT INTO invoicedetail (ivh_hdrnumber,ivd_number,ivd_description,    						 -- 1
		cht_itemcode,ivd_quantity,ivd_rate,ivd_charge,ivd_taxable1,ivd_taxable2,ivd_taxable3,ivd_taxable4,  --2
		ivd_unit,cur_code,ivd_currencydate,ivd_glnum,ord_hdrnumber,ivd_type,ivd_rateunit,ivd_billto,			--3
		ivd_sequence,ivd_refnum,cmd_code,cmp_id,ivd_sign,	--4
		ivd_reftype,cht_basisunit,ivd_fromord,cht_class,ivd_invoicestatus)			--5
	 SELECT 0,@@ivdnumber,cht_description,											--1
		@chargetype,@quantity,@rate,ROUND(@amount,2),cht_taxtable1,cht_taxtable2,cht_taxtable3,cht_taxtable4, --2
		cht_unit,cht_currunit,getdate(),cht_glnum,@ordhdrnumber,'LI',cht_rateunit,'UNKNOWN',			--3
		999,@refnumber,'UNKNOWN','UNKNOWN',cht_sign,	--4
		@reftype,cht_basisunit,'Y',cht_class,'HLD'			--5
	   FROM chargetype 
	  WHERE cht_itemcode = @chargetype

	 IF @@error <> 0 RETURN -1
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
GRANT EXECUTE ON  [dbo].[dx_add_invoicedetail] TO [public]
GO
