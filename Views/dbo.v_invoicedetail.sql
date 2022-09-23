SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  View dbo.v_invoicedetail    Script Date: 6/1/99 11:54:01 AM ******/
/****** Object:  View dbo.v_invoicedetail    Script Date: 12/10/97 1:56:59 PM ******/
/****** Object:  View dbo.v_invoicedetail    Script Date: 4/17/97 3:25:38 PM ******/
CREATE VIEW [dbo].[v_invoicedetail]  
    ( ivh_hdrnumber,   
      ivd_number,   
      stp_number,   
      ivd_description,   
      cht_itemcode,   
      ivd_quantity,   
      ivd_rate,   
      ivd_charge,   
      ivd_taxable1,   
      ivd_taxable2,   
      ivd_taxable3,   
      ivd_taxable4,   
      ivd_unit,   
      cur_code,   
      ivd_currencydate,   
      ivd_glnum,   
      ord_hdrnumber,   
      ivd_type,   
      ivd_rateunit,   
      ivd_billto,   
      ivd_itemquantity,   
      ivd_subtotalptr,   
      ivd_allocatedrev,   
      ivd_sequence,   
      ivd_invoicestatus,   
      mfh_hdrnumber,   
      ivd_refnum,   
      cmd_code,   
      cmp_id,   
      ivd_distance,   
      ivd_distunit,   
      ivd_wgt,   
      ivd_wgtunit,   
      ivd_count,   
      ivd_countunit,   
      evt_number,   
      ivd_reftype,   
      ivd_volume,   
      ivd_volunit,   
      ivd_orig_cmpid,   
      ivd_payrevenue,   
      ivd_sign,   
      ivd_length,   
      ivd_lengthunit,   
      ivd_width,   
      ivd_widthunit,   
      ivd_height,   
      ivd_heightunit,   
      ivd_exportstatus,   
      cht_basisunit ) AS   
  SELECT invoicedetail.ivh_hdrnumber,   
         invoicedetail.ivd_number,   
         invoicedetail.stp_number,   
         invoicedetail.ivd_description,   
         invoicedetail.cht_itemcode,   
         invoicedetail.ivd_quantity,   
         invoicedetail.ivd_rate,   
         invoicedetail.ivd_charge,   
         invoicedetail.ivd_taxable1,   
         invoicedetail.ivd_taxable2,   
         invoicedetail.ivd_taxable3,   
         invoicedetail.ivd_taxable4,   
         invoicedetail.ivd_unit,   
         invoicedetail.cur_code,   
         invoicedetail.ivd_currencydate,   
         invoicedetail.ivd_glnum,   
         invoicedetail.ord_hdrnumber,   
         invoicedetail.ivd_type,   
         invoicedetail.ivd_rateunit,   
         invoicedetail.ivd_billto,   
         invoicedetail.ivd_itemquantity,   
         invoicedetail.ivd_subtotalptr,   
         invoicedetail.ivd_allocatedrev,   
         invoicedetail.ivd_sequence,   
         invoicedetail.ivd_invoicestatus,   
         invoicedetail.mfh_hdrnumber,   
         invoicedetail.ivd_refnum,   
         invoicedetail.cmd_code,   
         invoicedetail.cmp_id,   
         invoicedetail.ivd_distance,   
         invoicedetail.ivd_distunit,   
         invoicedetail.ivd_wgt,   
         invoicedetail.ivd_wgtunit,   
         invoicedetail.ivd_count,   
         invoicedetail.ivd_countunit,   
         invoicedetail.evt_number,   
         invoicedetail.ivd_reftype,   
         invoicedetail.ivd_volume,   
         invoicedetail.ivd_volunit,   
         invoicedetail.ivd_orig_cmpid,   
         invoicedetail.ivd_payrevenue,   
         invoicedetail.ivd_sign,   
         invoicedetail.ivd_length,   
         invoicedetail.ivd_lengthunit,   
         invoicedetail.ivd_width,   
         invoicedetail.ivd_widthunit,   
         invoicedetail.ivd_height,   
         invoicedetail.ivd_heightunit,   
         invoicedetail.ivd_exportstatus,   
         invoicedetail.cht_basisunit  
    FROM invoicedetail   



GO
GRANT DELETE ON  [dbo].[v_invoicedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[v_invoicedetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[v_invoicedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[v_invoicedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[v_invoicedetail] TO [public]
GO
