SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[d_stlmnt_det_final_MULTI_sp] (@phnum INT, @type CHAR(6), @id CHAR(13), @paydate DATETIME)
AS
set nocount on 

/* Revision History:
   Date        Name              Label    Description
   ----------- ---------------   -------  ------------------------------------------------------------------------------------
   11-24-2010   PTS 54736                 Initial Version (Service pack only)
   03-02-2011   PTS 55812 SPN    
   05-12-2012	PTS 60458				  Initial Version In Core.			         
*/


DECLARE  @v_PerDiemPaytype varchar(60),    
		 @paydatecheck char(1)
    

SELECT  @v_PerDiemPaytype = IsNull(gi_string1, '')
FROM  generalinfo
WHERE gi_name = 'PerDiemPaytype'

SELECT @paydatecheck = LEFT(upper(IsNull(gi_string1, 'N')), 1)
FROM  generalinfo
WHERE gi_name = 'UseTransDateInCollect'

  SELECT paydetail.pyd_number
        , paydetail.pyh_number
        , paydetail.lgh_number
        , paydetail.asgn_number
        , paydetail.asgn_type
        , paydetail.asgn_id        
        , paydetail.ivd_number
        , paydetail.pyd_prorap
        , paydetail.pyd_payto
        , paydetail.pyt_itemcode
        , paydetail.pyd_description
        , paydetail.pyr_ratecode
        , paydetail.pyd_quantity
        , paydetail.pyd_rateunit
        , paydetail.pyd_unit
        , paydetail.pyd_pretax
        , paydetail.pyd_glnum
        , paydetail.pyd_status   
        , paydetail.pyd_refnumtype
        , paydetail.pyd_refnum
        , paydetail.pyh_payperiod
        , paydetail.lgh_startpoint
        , paydetail.lgh_startcity
        , paydetail.lgh_endpoint
        , paydetail.lgh_endcity
        , paydetail.ivd_payrevenue           
        , paydetail.mov_number
        , paydetail.pyd_minus
        , paydetail.pyd_workperiod
        , paydetail.pyd_sequence
        , paydetail.pyd_rate
        , paydetail.pyd_amount
        , paydetail.pyd_revenueratio
        , paydetail.pyd_lessrevenue
        , paydetail.pyd_payrevenue
        , paydetail.std_number
        , paydetail.pyd_loadstate
        , paydetail.pyd_transdate
        , paydetail.pyd_xrefnumber
        , paydetail.ord_hdrnumber         
        , paytype.pyt_basis
        , paydetail.pyt_fee1
        , paydetail.pyt_fee2
        , paydetail.pyd_grossamount
        , paydetail.psd_id          
        , CONVERT(datetime, NULL) dummydate
        , paydetail.pyd_updatedby
        , paydetail.pyd_adj_flag
        , paydetail.pyd_exportstatus
        , paydetail.pyd_releasedby
        , CONVERT(varchar(12), ISNULL(orderheader.ord_number, '0')) ord_number      
        , paydetail.pyd_billedweight
        , paydetail.cht_itemcode
        , paydetail.tar_tarriffnumber
        , paydetail.psd_batch_id       
        , CONVERT(varchar(6), ISNULL(orderheader.ord_revtype1, 'UNK')) ord_revtype1
        , CONVERT(varchar(20), 'RevType1') revtype1_name   
        , CASE(SELECT ISNULL(cmp_invoicetype,'INV') FROM company WHERE orderheader.ord_billto = company.cmp_id) 
               WHEN 'MAS' THEN
                  (SELECT ISNULL(MIN(code), 0)
                     FROM labelfile
                        , invoiceheader
                    WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
                      AND invoiceheader.ivh_mbstatus = labelfile.abbr
                      AND labelfile.labeldefinition = 'InvoiceStatus'
                  )
               ELSE
                  (SELECT ISNULL(MIN(code), 0)
                     FROM labelfile
                        , invoiceheader
                    WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
                      AND invoiceheader.ivh_invoicestatus = labelfile.abbr
                      AND labelfile.labeldefinition = 'InvoiceStatus'
                  )
          END inv_statuscode        
        , paydetail.pyd_updatedon
        , paydetail.pyd_currency
        , paydetail.pyd_currencydate
        , paydetail.pyd_updsrc
        , 0 pyd_changed
        , paytype.pyt_agedays
        , paydetail.pyd_ivh_hdrnumber        
        , ISNULL(paytype.pyt_group,'UNK') pyt_group
        , paydetail.pyd_ref_invoice
        , paydetail.pyd_ref_invoicedate
        , 'N' AS calc
        , 'N' AS edit_status
        , purchaseservicedetail.psh_number
        , paydetail.pyd_authcode
        , ISNULL(paydetail.pyd_maxquantity_used,'N') pyd_maxquantity_used
        , ISNULL(paydetail.pyd_maxcharge_used,'N') pyd_maxcharge_used            
        , @v_PerDiemPaytype dummy_pyh_paystatus
        , paydetail.pyd_carinvnum
        , paydetail.pyd_carinvdate
        , paydetail.std_number_adj
        , paydetail.pyd_vendortopay
        , paytype.pyt_editindispatch
        , paydetail.pyd_remarks
        , ISNULL(paytype.pyt_exclude_guaranteed_pay,'N') pyt_exclude_guaranteed_pay
        , paydetail.stp_number
        , paydetail.stp_mfh_sequence
        , paydetail.pyd_perdiem_exceeded
        , paydetail.stp_number_pacos
        , paydetail.pyd_createdby
        , paydetail.pyd_createdon
        , paydetail.pyd_gst_amount
        , paydetail.pyd_gst_flag
        , paydetail.pyd_mileagetable
        , paydetail.pyd_mbtaxableamount
        , paydetail.pyd_nttaxableamount
        , paydetail.pyt_otflag
        , paytype.pyt_basisunit           
        , otflag_workfield = paydetail.pyt_otflag
        , 0 AS 'pyh_lgh_number'
        , 0 AS 'cc_xfer_ckbox'
        , paydetail.pyd_min_period
        , paydetail.pyd_workcycle_status
        , paydetail.pyd_workcycle_description                       
        , IsNull(paytype.pyt_taxable, 'Y')     
        , IsNull(paytypetax.pyt_tax1, 'N')     
        , IsNull(paytypetax.pyt_tax2, 'N')     
        , IsNull(paytypetax.pyt_tax3, 'N')     
        , IsNull(paytypetax.pyt_tax4, 'N')     
        , IsNull(paytypetax.pyt_tax5, 'N')     
        , IsNull(paytypetax.pyt_tax6, 'N')     
        , IsNull(paytypetax.pyt_tax7, 'N')     
        , IsNull(paytypetax.pyt_tax8, 'N')     
        , IsNull(paytypetax.pyt_tax9, 'N')     
        , IsNull(paytypetax.pyt_tax10, 'N')    
        , paydetail.std_purchase_date          
        , paydetail.std_purchase_tax_state     
        , paydetail.pyd_tax_originator_pyd_number 
   FROM paydetail
   JOIN paytype ON paydetail.pyt_itemcode = paytype.pyt_itemcode
   LEFT OUTER JOIN orderheader ON paydetail.ord_hdrnumber = orderheader.ord_hdrnumber
   LEFT OUTER JOIN purchaseservicedetail ON paydetail.psd_number = purchaseservicedetail.psd_number   
   LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
  WHERE asgn_id = @id
    AND asgn_type = @type
    AND (  (pyh_number > 0 AND pyh_payperiod = @paydate)
        OR (
            (pyd_status = 'PND'
            AND pyh_payperiod >= '20491231 00:00:00'
            AND CASE @paydatecheck WHEN 'Y' THEN pyd_transdate ELSE '19500101' END <= @paydate
            )
            OR
            (pyd_status = 'PND'
            AND pyh_payperiod = @paydate
            )
            OR
            (pyd_status = 'HLD'
            AND (pyd_workperiod <= @paydate OR pyd_workperiod >= '20491231 23:59')
            )
            OR
            (pyd_status = 'HLD'
            AND pyt_agedays > 0
            AND DATEADD(day, pyt_agedays, pyd_transdate) < @paydate
            )
           )
        )

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_final_MULTI_sp] TO [public]
GO
