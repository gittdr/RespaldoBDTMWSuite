SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[Wadhams_PickUpPreview]
      ( 
      @StartDate DATETIME
      ,@EndDate DATETIME
      ,@_BillTo CHAR(1)
      ,@BillTo VARCHAR(20)
      ,@MovType CHAR(1)
      ,@Carrier VARCHAR(100)
      ,@OrdStatus CHAR(5)
      ,@Terminal VARCHAR(1000)
      )

AS

--EXEC dbo.[Wadhams_PickUpPreview] '11/8/13','11/8/13','N','MERLIV03',NULL,'RADOH','Y','ALB,ALT,BIL,BFL'

/***************************
DECLARE @StartDate DATETIME
            ,@EndDate DATETIME
            ,@_BillTo CHAR(1)
            ,@BillTo VARCHAR(20)
            ,@MovType CHAR(1)
            ,@Carrier VARCHAR(100)
            ,@OrdStatus CHAR(5)
            ,@Terminal VARCHAR(1000)
            
SELECT @StartDate = '11/8/13'
         ,@EndDate = '11/08/13'
         ,@_BillTo = 'N'
         ,@BillTo = 'MERLIV03'
         ,@MovType = NULL
         ,@Carrier = 'RADOH'
         ,@OrdStatus  = 'CMP'
         ,@Terminal = 'ALB,ALT,BIL,BFL,CRL'
****************************/

CREATE TABLE #Terminal 
      (TERMINAL VARCHAR(10))

INSERT INTO #Terminal
SELECT value FROM dbo.[CSVStringsToTable_fn_seq] (@Terminal) 


/*
Carrier Advanced with date selections
Carrier Beyond with date selections
Undelivered Freight (by terminal or by all with date selections)
*/

IF @_BillTo = 'Y' 
BEGIN    
      SELECT ivh.ord_hdrnumber
               ,ivh_invoicenumber
               ,ivh_consignee
               ,s.cmp_name
               ,(SELECT SUM(ivd_wgt) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) weight
               ,(SELECT SUM(ivd_count) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) pieces
               ,(SELECT SUM(ivd_volume) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) gallons
               ,s.stp_address
               ,s.stp_address2
               ,cty.cty_name
               ,cty.cty_state
               ,cty.cty_zip
               ,tc.cmp_name AS orig_term
               ,o.ord_bookdate
               ,o.ord_status, o.ord_charge
               ,carrierCharges = [dbo].[fnc_Carriers](o.ord_hdrnumber) --(select carrier_charges from orderheaderltlinfo where ord_hdrnumber = o.ord_hdrnumber)
               ,AccCharges = [dbo].fnc_AccCharges(o.ord_hdrnumber)
               ,pro_number = 
    (
     select top 1 ref_number 
     from referencenumber
     where ord_hdrnumber = o.ord_hdrnumber and ref_type = 'PRO#'
    ) 
    ,o.ord_dest_zip 
      FROM orderheader o
      LEFT JOIN invoiceheader ivh
            ON o.ord_hdrnumber = ivh.ord_hdrnumber
      LEFT JOIN stops s
            ON o.ord_hdrnumber = s.ord_hdrnumber AND s.stp_event = 'LLD'
      LEFT JOIN city cty
            ON s.stp_city = cty.cty_code
      LEFT JOIN company tc 
            ON SUBSTRING(o.ord_number,1,3)  = tc.cmp_id
      WHERE 1=1
      AND o.ord_billto = @BillTo
      AND o.ord_bookdate >= @StartDate 
      AND o.ord_bookdate < DATEADD(DD,1,@EndDate)
END

IF @MovType IN ('A','B')

BEGIN
      SELECT ivh.ord_hdrnumber
               ,ivh_invoicenumber
               ,ivh_consignee
               ,s.cmp_name
               ,(SELECT SUM(ivd_wgt) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) weight
               ,(SELECT SUM(ivd_count) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) pieces
               ,(SELECT SUM(ivd_volume) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) gallons
               ,s.stp_address
               ,s.stp_address2
               ,cty.cty_name
               ,cty.cty_state
               ,cty.cty_zip
               ,tc.cmp_name AS orig_term
               ,o.ord_bookdate
               ,o.ord_status, o.ord_charge, 
               carrierCharges = [dbo].[fnc_Carriers](o.ord_hdrnumber) --(select carrier_charges from orderheaderltlinfo where ord_hdrnumber = o.ord_hdrnumber)
               ,AccCharges = [dbo].fnc_AccCharges(o.ord_hdrnumber)
               ,pro_number = 
    (
     select top 1 ref_number 
     from referencenumber
     where ord_hdrnumber = o.ord_hdrnumber and ref_type = 'PRO#'
    ) 
    ,o.ord_dest_zip
      FROM orderheader o
      LEFT JOIN invoiceheader ivh
            ON o.ord_hdrnumber = ivh.ord_hdrnumber
      LEFT JOIN stops s
            ON o.ord_hdrnumber = s.ord_hdrnumber AND s.stp_event = 'LLD'
      LEFT JOIN city cty
            ON s.stp_city = cty.cty_code
      JOIN ordercarrier oc
            ON o.ord_hdrnumber = oc.ord_hdrnumber
      LEFT JOIN company tc 
            ON SUBSTRING(o.ord_number,1,3)  = tc.cmp_id
      WHERE 1=1
      AND oc.carrier = @Carrier
      AND o.ord_bookdate >= @StartDate 
      AND o.ord_bookdate < DATEADD(DD,1,@EndDate)
      AND oc.movement_type = @MovType
      
END

IF @OrdStatus = 'CMP'
BEGIN

      SELECT ivh.ord_hdrnumber
               ,ivh_invoicenumber
               ,ivh_consignee
               ,s.cmp_name
               ,(SELECT SUM(ivd_wgt) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) weight
               ,(SELECT SUM(ivd_count) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) pieces
               ,(SELECT SUM(ivd_volume) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) gallons
               ,s.stp_address
               ,s.stp_address2
               ,cty.cty_name
               ,cty.cty_state
               ,cty.cty_zip
               ,tc.cmp_name AS orig_term
               ,o.ord_bookdate
               ,o.ord_status, o.ord_charge, 
               carrierCharges = [dbo].[fnc_Carriers](o.ord_hdrnumber) --(select carrier_charges from orderheaderltlinfo where ord_hdrnumber = o.ord_hdrnumber)
      ,AccCharges = [dbo].fnc_AccCharges(o.ord_hdrnumber)
               ,pro_number = 
    (
     select top 1 ref_number 
     from referencenumber
     where ord_hdrnumber = o.ord_hdrnumber and ref_type = 'PRO#'
    ) 
    ,o.ord_dest_zip
      FROM orderheader o
      LEFT JOIN invoiceheader ivh
            ON o.ord_hdrnumber = ivh.ord_hdrnumber
      LEFT JOIN stops s
            ON o.ord_hdrnumber = s.ord_hdrnumber AND s.stp_event = 'LLD'
      LEFT JOIN city cty
            ON s.stp_city = cty.cty_code
      LEFT JOIN company tc 
            ON SUBSTRING(o.ord_number,1,3)  = tc.cmp_id
      WHERE 1=1
      AND o.ord_bookdate >= @StartDate 
      AND o.ord_bookdate < DATEADD(DD,1,@EndDate)
      AND tc.cmp_id IN (SELECT terminal FROM #Terminal )
      AND o.ord_status = 'CMP'
END   

IF @OrdStatus = 'ALL'
BEGIN 
      SELECT ivh.ord_hdrnumber
               ,ivh_invoicenumber
               ,ivh_consignee
               ,s.cmp_name
               ,(SELECT SUM(ivd_wgt) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) weight
               ,(SELECT SUM(ivd_count) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) pieces
               ,(SELECT SUM(ivd_volume) FROM invoicedetail WHERE ivh_hdrnumber = ivh.ivh_hdrnumber) gallons
               ,s.stp_address
               ,s.stp_address2
               ,cty.cty_name
               ,cty.cty_state
               ,cty.cty_zip
               ,tc.cmp_name AS orig_term
               ,o.ord_bookdate
               ,o.ord_status, o.ord_charge, 
               carrierCharges = [dbo].[fnc_Carriers](o.ord_hdrnumber) --(select carrier_charges from orderheaderltlinfo where ord_hdrnumber = o.ord_hdrnumber)
               ,AccCharges = [dbo].fnc_AccCharges(o.ord_hdrnumber)
               ,pro_number = 
    (
     select top 1 ref_number 
     from referencenumber
     where ord_hdrnumber = o.ord_hdrnumber and ref_type = 'PRO#'
    )
    ,o.ord_dest_zip
      FROM orderheader o
      LEFT JOIN invoiceheader ivh
            ON o.ord_hdrnumber = ivh.ord_hdrnumber
      LEFT JOIN stops s
            ON o.ord_hdrnumber = s.ord_hdrnumber AND s.stp_event = 'LLD'
      LEFT JOIN city cty
            ON s.stp_city = cty.cty_code
      LEFT JOIN company tc 
            ON SUBSTRING(o.ord_number,1,3)  = tc.cmp_id
      WHERE 1=1
      AND o.ord_bookdate >= @StartDate 
      AND o.ord_bookdate < DATEADD(DD,1,@EndDate)
      AND tc.cmp_id IN (SELECT terminal FROM #Terminal )
      AND o.ord_status <> 'CMP'
END
      
DROP TABLE #Terminal
GO
GRANT EXECUTE ON  [dbo].[Wadhams_PickUpPreview] TO [public]
GO
