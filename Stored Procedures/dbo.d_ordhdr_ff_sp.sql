SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_ordhdr_ff_sp    Script Date: 6/1/99 11:54:51 AM ******/
create proc [dbo].[d_ordhdr_ff_sp] (@OrdHdr int)  
as 

SELECT orderheader.ord_company, company_a.cmp_name, city_a.cty_nmstct, 
orderheader.ord_shipper, company_b.cmp_name, orderheader.ord_origincity, 
city_b.cty_nmstct, orderheader.ord_consignee, company_c.cmp_name, orderheader.ord_destcity, 
city_c.cty_nmstct, orderheader.ord_billto, company_d.cmp_name, city_d.cty_nmstct, 
orderheader.ord_number, orderheader.ord_contact, orderheader.ord_originpoint, 
orderheader.ord_destpoint, orderheader.ord_bookdate, orderheader.ord_bookedby, 
orderheader.ord_status, orderheader.ord_invoicestatus, orderheader.ord_revtype1, 
orderheader.ord_revtype2, orderheader.ord_revtype3, orderheader.ord_revtype4, 
orderheader.ord_totalcharge, orderheader.ord_hdrnumber, orderheader.ord_invoicewhole, 
orderheader.ord_remark, orderheader.ord_pu_at, orderheader.ord_dr_at, 
referencenumber.ref_type, referencenumber.ref_number, 
referencenumber.ord_hdrnumber, orderheader.ord_startdate, orderheader.ord_completiondate, 
orderheader.mfh_hdrnumber, 'RevType1', 'RevType2', 'RevType3', 'RevType4', 
orderheader.ord_priority, orderheader.mov_number 
FROM city city_a, city city_b, city city_c, city city_d, company company_a, 
company company_b, company company_c, company company_d, orderheader, 
referencenumber 
WHERE ( orderheader.ord_company = company_a.cmp_id ) and 
( city_a.cty_code = company_a.cmp_city ) and 
( orderheader.ord_shipper = company_b.cmp_id ) and 
( city_b.cty_code = company_b.cmp_city ) and 
( orderheader.ord_consignee = company_c.cmp_id ) and 
( city_c.cty_code = company_c.cmp_city ) and 
( orderheader.ord_billto = company_d.cmp_id ) and 
( city_d.cty_code = company_d.cmp_city ) and 
( referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber ) and 
( orderheader.ord_hdrnumber = @OrdHdr )






GO
GRANT EXECUTE ON  [dbo].[d_ordhdr_ff_sp] TO [public]
GO
