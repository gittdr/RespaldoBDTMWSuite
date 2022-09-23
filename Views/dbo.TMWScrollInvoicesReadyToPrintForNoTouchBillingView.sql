SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollInvoicesReadyToPrintForNoTouchBillingView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves invoice records that are ready for printing. It is used by the No Touch Processing Service

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  -----------  -----------------------------------------------------------------------
  2016/08/04   Andy Vanek       PTS: 104706  Fix query performance, rewrite query to meet DBA standards
  2016/08/23   Andy Vanek       PTS: 104958  Reintroduce columns expected by NTDSCR planning board
  2016/10/13   Andy Vanek       PTS: 105638  Add additional filter to join on stops table to remove records with ord_hdrnumber = 0
********************************************************************************************************************/
WITH applicableNoTouchConfigBillTos(billToId)
AS
  (
    SELECT AppliesToId
    FROM NoTouchBillingConfiguration (NOLOCK)
      JOIN labelfile (NOLOCK) ON labelfile.labeldefinition = 'INVOICESTATUS' AND NoTouchBillingConfiguration.NewInvoiceStatus = labelfile.abbr
    WHERE NoTouchBillingConfiguration.ntbTypeId = 1 AND labelfile.code >= 60
  )
SELECT 
  dbo.invoiceheader.car_key,
  dbo.invoiceheader.cht_itemcode,
  dbo.invoiceheader.inv_revenue_pay,
  dbo.invoiceheader.inv_revenue_pay_fix,
  dbo.invoiceheader.ivh_allinclusivecharge,
  dbo.invoiceheader.ivh_applyto,
  dbo.invoiceheader.ivh_applyto_definition,
  dbo.invoiceheader.ivh_archarge,
  dbo.invoiceheader.ivh_arcurrency,
  dbo.invoiceheader.ivh_attention,
  dbo.invoiceheader.ivh_batch_id,
  dbo.invoiceheader.ivh_BelongsTo,
  dbo.invoiceheader.ivh_billdate,
  dbo.invoiceheader.ivh_billing_usedate,
  dbo.invoiceheader.ivh_billing_usedate_setting,
  dbo.invoiceheader.ivh_billto,
  dbo.invoiceheader.ivh_billto_parent,
  dbo.invoiceheader.ivh_block_printing,
  dbo.invoiceheader.ivh_booked_revtype1,
  dbo.invoiceheader.ivh_bookmonth,
  dbo.invoiceheader.ivh_bookyear,
  dbo.invoiceheader.ivh_carrier,
  dbo.invoiceheader.ivh_charge,
  dbo.invoiceheader.ivh_charge_type,
  dbo.invoiceheader.ivh_charge_type_lh,
  dbo.invoiceheader.ivh_cmrbill_link,
  dbo.invoiceheader.ivh_company,
  dbo.invoiceheader.ivh_consignee,
  dbo.invoiceheader.ivh_creditmemo,
  dbo.invoiceheader.ivh_currency,
  dbo.invoiceheader.ivh_currencydate,
  dbo.invoiceheader.ivh_custdoc,
  dbo.invoiceheader.ivh_dedicated_invnumber,
  dbo.invoiceheader.ivh_definition,
  dbo.invoiceheader.ivh_deliverydate,
  dbo.invoiceheader.ivh_destcity,
  dbo.invoiceheader.ivh_destpoint,
  dbo.invoiceheader.ivh_destregion1,
  dbo.invoiceheader.ivh_destregion2,
  dbo.invoiceheader.ivh_destregion3,
  dbo.invoiceheader.ivh_destregion4,
  dbo.invoiceheader.ivh_deststate,
  dbo.invoiceheader.ivh_destzipcode,
  dbo.invoiceheader.ivh_dimfactor,
  dbo.invoiceheader.ivh_docnumber,
  dbo.invoiceheader.ivh_driver,
  dbo.invoiceheader.ivh_driver2,
  dbo.invoiceheader.ivh_drivetime,
  dbo.invoiceheader.ivh_edi_flag,
  dbo.invoiceheader.ivh_empty_distance,
  dbo.invoiceheader.ivh_entryport,
  dbo.invoiceheader.ivh_exchangerate,
  dbo.invoiceheader.ivh_exitport,
  dbo.invoiceheader.ivh_freight_miles,
  dbo.invoiceheader.ivh_fuelprice,
  dbo.invoiceheader.ivh_furthestpointconsignee,
  dbo.invoiceheader.ivh_gp_gl_postdate,
  dbo.invoiceheader.ivh_hdrnumber,
  dbo.invoiceheader.ivh_hideconsignaddr,
  dbo.invoiceheader.ivh_hideshipperaddr,
  dbo.invoiceheader.ivh_high_temp,
  dbo.invoiceheader.ivh_imagecount,
  dbo.invoiceheader.ivh_imagestatus,
  dbo.invoiceheader.ivh_imagestatus_date,
  dbo.invoiceheader.ivh_invoiceby,
  dbo.invoiceheader.ivh_invoicenumber,
  dbo.invoiceheader.ivh_invoicestatus,
  dbo.invoiceheader.ivh_lastcheckamount,
  dbo.invoiceheader.ivh_lastcheckdate,
  dbo.invoiceheader.ivh_lastchecknumber,
  dbo.invoiceheader.ivh_lastprintdate,
  dbo.invoiceheader.ivh_leaseid,
  dbo.invoiceheader.ivh_leaseperiodenddate,
  dbo.invoiceheader.ivh_loaded_distance,
  dbo.invoiceheader.ivh_loadtime,
  dbo.invoiceheader.ivh_low_temp,
  dbo.invoiceheader.ivh_maxheight,
  dbo.invoiceheader.ivh_maxlength,
  dbo.invoiceheader.ivh_maxwidth,
  dbo.invoiceheader.ivh_mbimagecount,
  dbo.invoiceheader.ivh_mbimagestatus,
  dbo.invoiceheader.ivh_mbimagestatus_date,
  dbo.invoiceheader.ivh_mbnumber,
  dbo.invoiceheader.ivh_mbnumber_custom,
  dbo.invoiceheader.ivh_mbperiod,
  dbo.invoiceheader.ivh_mbperiodstart,
  dbo.invoiceheader.ivh_mbstatus,
  dbo.invoiceheader.ivh_mileage_adj_pct,
  dbo.invoiceheader.ivh_mileage_adjustment,
  dbo.invoiceheader.ivh_misc_number,
  dbo.invoiceheader.ivh_nomincharges,
  dbo.invoiceheader.ivh_order_by,
  dbo.invoiceheader.ivh_order_cmd_code,
  dbo.invoiceheader.ivh_order_source,
  dbo.invoiceheader.ivh_origincity,
  dbo.invoiceheader.ivh_originpoint,
  dbo.invoiceheader.ivh_originregion1,
  dbo.invoiceheader.ivh_originregion2,
  dbo.invoiceheader.ivh_originregion3,
  dbo.invoiceheader.ivh_originregion4,
  dbo.invoiceheader.ivh_originstate,
  dbo.invoiceheader.ivh_originzipcode,
  dbo.invoiceheader.ivh_paid_amount,
  dbo.invoiceheader.ivh_paid_indicator,
  dbo.invoiceheader.ivh_paperwork_override,
  dbo.invoiceheader.ivh_paperworkstatus,
  dbo.invoiceheader.ivh_pay_status,
  dbo.invoiceheader.ivh_printdate,
  dbo.invoiceheader.ivh_priority,
  dbo.invoiceheader.ivh_quantity,
  dbo.invoiceheader.Ivh_quantity_type,
  dbo.invoiceheader.ivh_rate,
  dbo.invoiceheader.ivh_rate_type,
  dbo.invoiceheader.ivh_rateby,
  dbo.invoiceheader.ivh_ratingquantity,
  dbo.invoiceheader.ivh_ratingunit,
  dbo.invoiceheader.ivh_ref_number,
  dbo.invoiceheader.ivh_reftype,
  dbo.invoiceheader.ivh_remark,
  dbo.invoiceheader.ivh_revenue_date,
  dbo.invoiceheader.ivh_revtype1,
  dbo.invoiceheader.ivh_revtype2,
  dbo.invoiceheader.ivh_revtype3,
  dbo.invoiceheader.ivh_revtype4,
  dbo.invoiceheader.ivh_shipdate,
  dbo.invoiceheader.ivh_shipper,
  dbo.invoiceheader.ivh_showcons,
  dbo.invoiceheader.ivh_showshipper,
  dbo.invoiceheader.ivh_splitbill_flag,
  dbo.invoiceheader.ivh_stopoffs,
  dbo.invoiceheader.ivh_supplier,
  dbo.invoiceheader.ivh_taxamount1,
  dbo.invoiceheader.ivh_taxamount2,
  dbo.invoiceheader.ivh_taxamount3,
  dbo.invoiceheader.ivh_taxamount4,
  dbo.invoiceheader.ivh_terms,
  dbo.invoiceheader.ivh_totalcharge,
  dbo.invoiceheader.ivh_totalmiles,
  dbo.invoiceheader.ivh_totalpaid,
  dbo.invoiceheader.ivh_totalpieces,
  dbo.invoiceheader.ivh_totaltime,
  dbo.invoiceheader.ivh_totalvolume,
  dbo.invoiceheader.ivh_totalweight,
  dbo.invoiceheader.ivh_tractor,
  dbo.invoiceheader.ivh_trailer,
  dbo.invoiceheader.ivh_trailer2,
  dbo.invoiceheader.ivh_transtype,
  dbo.invoiceheader.ivh_TrlConfiguration,
  dbo.invoiceheader.ivh_unit,
  dbo.invoiceheader.ivh_unloadtime,
  dbo.invoiceheader.ivh_user_id1,
  dbo.invoiceheader.ivh_user_id2,
  dbo.invoiceheader.ivh_xferdate,
  dbo.invoiceheader.last_updateby,
  dbo.invoiceheader.last_updatedate,
  dbo.invoiceheader.mfh_hdrnumber,
  dbo.invoiceheader.mov_number,
  dbo.invoiceheader.ord_hdrnumber,
  dbo.invoiceheader.ord_number,
  dbo.invoiceheader.rowsec_rsrv_id,
  dbo.invoiceheader.shp_hdrnumber,
  dbo.invoiceheader.tar_number,
  dbo.invoiceheader.tar_tariffitem,
  dbo.invoiceheader.tar_tarriffnumber,
  dbo.invoiceheader.timestamp,
  dbo.orderheader.ord_trailer2,
  dbo.orderheader.ord_BelongsTo,
  ShipperCity.cty_nmstct AS [ShipperCity], 
  ConsigneeCity.cty_nmstct AS [ConsigneeCity],
  dbo.orderheader.rowsec_rsrv_id AS [ord_rowsec_rsrv_id],
  dbo.TMW_AreAllPpwkDocsReceived('INV', dbo.invoiceheader.ivh_hdrnumber) AS [PaperworkReqDocsReceived],
  ISNULL(dbo.stops.stp_schdtearliest, '1950-01-01 00:00:00.000') AS [FirstBillableStopSchdEarliestDate]
FROM dbo.invoiceheader (NOLOCK) 
  JOIN dbo.city ShipperCity (NOLOCK) ON dbo.invoiceheader.ivh_origincity = ShipperCity.cty_code 
  JOIN dbo.city ConsigneeCity (NOLOCK) ON dbo.invoiceheader.ivh_destcity = ConsigneeCity.cty_code 
  LEFT OUTER JOIN dbo.orderheader (NOLOCK) ON dbo.invoiceheader.ord_hdrnumber = dbo.orderheader.ord_hdrnumber
  LEFT OUTER JOIN dbo.stops (NOLOCK) ON dbo.stops.ord_hdrnumber = dbo.orderheader.ord_hdrnumber AND dbo.stops.ord_hdrnumber > 0 AND dbo.stops.stp_sequence = 1
WHERE dbo.invoiceheader.ivh_invoicestatus = 'RTP'
  AND EXISTS (SELECT 1 FROM applicableNoTouchConfigBillTos WHERE applicableNoTouchConfigBillTos.billToId IN ('UNKNOWN', dbo.invoiceheader.ivh_billto))
GO
GRANT DELETE ON  [dbo].[TMWScrollInvoicesReadyToPrintForNoTouchBillingView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollInvoicesReadyToPrintForNoTouchBillingView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollInvoicesReadyToPrintForNoTouchBillingView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollInvoicesReadyToPrintForNoTouchBillingView] TO [public]
GO
