SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RptFreightBill]
 @ivq_batch_number int
AS
BEGIN
 
 CREATE TABLE #freightbill(
   ivh_mbnumber  INT,
   ivh_mbperiod     DATETIME,
   ivh_hdrnumber  INT,
   ord_hdrnumber  INT,
   ord_number  VARCHAR(12),
   pro_number        VARCHAR(30),
   ivh_invoicenumber VARCHAR(12),
   ivh_billdate  DATETIME,
   pickup_terminal   VARCHAR(8),
   ivh_invoicestatus VARCHAR(6),
   ivh_billto  VARCHAR(8),
   bill_to_name  VARCHAR(100),
   ivh_charge  MONEY
 );

 INSERT INTO #freightbill (ivh_hdrnumber, ord_hdrnumber, ord_number, pro_number, ivh_invoicenumber, pickup_terminal, ivh_invoicestatus,
   ivh_billto, bill_to_name, ivh_charge, ivh_billdate, ivh_mbnumber, ivh_mbperiod) 
   
   SELECT invoiceheader.ivh_hdrnumber, invoiceheader.ord_hdrnumber, invoiceheader.ord_number, '', ivh_invoicenumber, pickup_terminal, ivh_invoicestatus,
   ivh_billto, c.cmp_name, ivh_charge,
   ivh_billdate, ivh_mbnumber, ivh_mbperiod
   
   FROM invoiceheader
   INNER JOIN orderheaderltlinfo oltl ON oltl.ord_hdrnumber = invoiceheader.ord_hdrnumber
            INNER JOIN company c ON c.cmp_id = invoiceheader.ivh_billto
            INNER JOIN company sc ON sc.cmp_id = invoiceheader.ivh_shipper
            INNER JOIN company cc ON cc.cmp_id = invoiceheader.ivh_consignee
            INNER JOIN orderheader oh ON oh.ord_hdrnumber = invoiceheader.ord_hdrnumber
   INNER JOIN invoiceprintqueue ivq ON ivq.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
   WHERE ivq.ivq_batch_number = @ivq_batch_number
   AND c.cmp_invoicetype IN ('BTH','INV','MAS')

 SELECT * from #freightbill;

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[RptFreightBill] TO [public]
GO
