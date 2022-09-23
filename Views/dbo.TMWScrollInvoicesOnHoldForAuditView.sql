SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollInvoicesOnHoldForAuditView] AS

SELECT DISTINCT
    ivh.ivh_invoicenumber,
    ivh.ivh_hdrnumber,
    ivh.ord_number,
    ivh.ord_hdrnumber,
    ivh.ivh_invoicestatus,
    ivh.mov_number,
    ivh.ivh_order_by,
    (select top 1 cmp_name from company (nolock) where company.cmp_id = ivh.ivh_order_by) as 'ivh_order_by_name',
    ivh.ivh_billto,
    (select top 1 cmp_name from company (nolock) where company.cmp_id = ivh.ivh_billto) as 'ivh_billto_name',
    ivh.ivh_shipper,
    (select top 1 cmp_name from company (nolock) where company.cmp_id = ivh.ivh_shipper) as 'ivh_shipper_name',
    ivh.ivh_consignee,
    (select top 1 cmp_name from company (nolock) where company.cmp_id = ivh.ivh_consignee) as 'ivh_consignee_name',
    ivh.ivh_shipdate,
    ivh.ivh_deliverydate,
    ivh.ivh_totalcharge,
    ivh.ivh_revtype1,
    (select top 1 lf.name from labelfile lf (nolock) where lf.labeldefinition = 'RevType1' and lf.abbr = ivh.ivh_revtype1) as 'ivh_revtype1_name',
    ivh.ivh_revtype2,
    (select top 1 lf.name from labelfile lf (nolock) where lf.labeldefinition = 'RevType2' and lf.abbr = ivh.ivh_revtype2) as 'ivh_revtype2_name',
    ivh.ivh_revtype3,
    (select top 1 lf.name from labelfile lf (nolock) where lf.labeldefinition = 'RevType3' and lf.abbr = ivh.ivh_revtype3) as 'ivh_revtype3_name',
    ivh.ivh_revtype4,
    (select top 1 lf.name from labelfile lf (nolock) where lf.labeldefinition = 'RevType4' and lf.abbr = ivh.ivh_revtype4) as 'ivh_revtype4_name',
    ivh.ivh_totalweight,
    ivh.ivh_totalpieces,
    ivh.ivh_totalmiles,
    ivh.ivh_totalvolume,
    ivh.ivh_printdate,
    ivh.ivh_billdate,
    ivh.ivh_lastprintdate,
    ivh.ivh_edi_flag,
    (select top 1 cmp_edi210 from company bc (nolock) where ivh.ivh_billto = bc.cmp_id) as 'ivh_edi210_flag',
    (select top 1 cmp_edi214 from company bc (nolock) where ivh.ivh_billto = bc.cmp_id) as 'ivh_edi214_flag',
    ivh.ivh_xferdate,
    ivh.ivh_booked_revtype1,
    ivh.ivh_paperwork_override,
    ivh.ivh_carrier,
    (select top 1 cmp_name from company (nolock) where company.cmp_id = ivh.ivh_carrier) as 'ivh_carrier_name',
    isnull((select top 1 stops.stp_schdtearliest 
            from stops (nolock) 
            where stops.ord_hdrnumber = ivh.ord_hdrnumber
            order by stops.stp_mfh_sequence, stops.stp_arrivaldate)
            , '1950-01-01 00:00:00.000') as 'stp_schdtearliest'
FROM invoiceheader ivh (nolock)
where ivh.ivh_invoicestatus = 'HLA'

GO
GRANT DELETE ON  [dbo].[TMWScrollInvoicesOnHoldForAuditView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollInvoicesOnHoldForAuditView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollInvoicesOnHoldForAuditView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollInvoicesOnHoldForAuditView] TO [public]
GO
