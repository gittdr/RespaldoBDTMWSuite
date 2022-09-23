SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VISTA_TMW_Header]
AS
SELECT     ivh_billto, ivh_shipper, ivh_consignee, serie = CASE ivh_creditmemo WHEN 'N' THEN 'TDR' WHEN 'Y' THEN 'NC' END, ivh_revtype1, 
                      rtrim(ltrim(ivh_user_id2)) AS ivh_user_id2, ivh_invoicenumber, invoiceheader.ivh_printdate, ord_number, mov_number, 
                      ivh_remark = isnull(replace(rtrim(ltrim(replace(replace(ivh_remark, char(13), ''), char(10), ''))), '|', ''), ''), ivh_ref_number = isnull(ivh_ref_number, ''), 
                      ivh_terms = isnull(ivh_terms, ''), ivh_tractor, ivh_trailer, lastname = isnull
                          ((SELECT     MAX(mpp_lastname)
                              FROM         manpowerprofile
                              WHERE     mpp_id = ivh_driver), ''), firstname = isnull
                          ((SELECT     MAX(mpp_firstname)
                              FROM         manpowerprofile
                              WHERE     mpp_id = ivh_driver), ''), licensenumber = isnull
                          ((SELECT     MAX(mpp_licensenumber)
                              FROM         manpowerprofile
                              WHERE     mpp_id = ivh_driver), ''), tractor_licnum = isnull
                          ((SELECT     MAX(trc_licnum)
                              FROM         tractorprofile
                              WHERE     trc_number = ivh_tractor), ''), trailer_licnum = isnull
                          ((SELECT     MAX(trl_licnum)
                              FROM         trailerprofile
                              WHERE     trl_number = ivh_trailer), ''), comprobante = ivh_applyto, ivd_descripcion = isnull
                          ((SELECT     MAX(ivd_description)
                              FROM         invoicedetail
                              WHERE     ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN'), ''), 
                      ivh_totalcharge = abs(ivh_totalcharge), ivh_taxamount1 = abs(ivh_taxamount1), ivh_taxamount2 = abs(ivh_taxamount2), ivh_creditmemo, 
                      ciudad_origen =
                          (SELECT     rand_city + ' ' + rand_state
                            FROM          city
                            WHERE      cty_code = ivh_origincity), ciudad_destino =
                          (SELECT     rand_city + ' ' + rand_state
                            FROM          city
                            WHERE      cty_code = ivh_destcity), moneda = CASE ivh_currency WHEN 'MX$' THEN 'MX' ELSE 'US' END, masterbill = ivh_mbnumber, 
                      peso_estimado = ivh_totalweight, cmp_id = A.cmp_id, rfc = REPLACE(replace(isnull(A.cmp_taxid, ''), ' ', ''), '-', ''), calle = ltrim(rtrim(A.cmp_address1)), 
                      ext = isnull(A.cmp_misc1, ''), interior = isnull(A.cmp_misc2, ''), colonia = isnull(ltrim(rtrim(A.cmp_address2)), ''), 
                      municipio = CASE rtrim(ltrim(A.cmp_address3)) WHEN '' THEN B.cty_name WHEN NULL THEN B.cty_name ELSE isnull(rtrim(ltrim(A.cmp_address3)), 
                      B.cty_name) END, ciudad = B.cty_name, estado =
                          (SELECT     upper(stc_state_desc)
                            FROM          statecountry
                            WHERE      stc_state_c = B.cty_state), pais = isnull(A.cmp_country, ''), A.cmp_zip, A.cmp_name, email_address =
                          (SELECT     isnull(MAX(email_address), '')
                            FROM          companyemail
                            WHERE      A.cmp_id = companyemail.cmp_id), ce_phone1 =
                          (SELECT     isnull(MAX(ce_phone1), '')
                            FROM          companyemail
                            WHERE      A.cmp_id = companyemail.cmp_id), A.cmp_revtype1, contact_name =
                          (SELECT     isnull(MAX(contact_name), '')
                            FROM          companyemail
                            WHERE      A.cmp_id = companyemail.cmp_id), rfc_origen = REPLACE(isnull(C.cmp_taxid, ''), '-', ''), calle_origen = isnull(ltrim(rtrim(C.cmp_address1)), 
                      ''), ext_origen = '', interior_origen = ' ', colonia_origen = isnull(rtrim(ltrim(C.cmp_address2)), ''), municipio_origen = CASE rtrim(ltrim(C.cmp_address3)) 
                      WHEN '' THEN D .cty_name WHEN NULL THEN D .cty_name ELSE isnull(ltrim(rtrim(C.cmp_address3)), D .cty_name) END, cd_origen = D .cty_name, 
                      edo_origen = D .cty_state, pais_origen = isnull(C.cmp_country, ''), zip_origen = isnull(replace(rtrim(ltrim(C.cmp_zip)), '|', ''), ''), 
                      name_origen = isnull(C.cmp_name, ''), email_address_origen =
                          (SELECT     isnull(MAX(email_address), '')
                            FROM          companyemail
                            WHERE      C.cmp_id = companyemail.cmp_id), ce_phone1_origen =
                          (SELECT     isnull(MAX(ce_phone1), '')
                            FROM          companyemail
                            WHERE      C.cmp_id = companyemail.cmp_id), revtype1_origen = C.cmp_revtype1, contact_name_origen =
                          (SELECT     isnull(MAX(contact_name), '')
                            FROM          companyemail
                            WHERE      C.cmp_id = companyemail.cmp_id), rfc_destino = isnull(E.cmp_taxid, ''), calle_destino = isnull(rtrim(ltrim(E.cmp_address1)), ''), 
                      ext_destino = '', interior_destino = ' ', colonia_destino = isnull(rtrim(ltrim(E.cmp_address2)), ''), municipio_destino = isnull(ltrim(rtrim(E.cmp_address3)), 
                      F.cty_name), cd_destino = isnull(F.cty_name, ''), edo_destino = isnull(F.cty_state, ''), pais_destino = LEFT(isnull(E.cmp_country, ''), 15), 
                      ZIP_destino = LEFT(isnull(replace(E.cmp_zip, '|', ''), ''), 6), NAME_destino = isnull(E.cmp_name, ''), email_address_destino =
                          (SELECT     isnull(MAX(email_address), '')
                            FROM          companyemail
                            WHERE      E.cmp_id = companyemail.cmp_id), ce_phone1_destino =
                          (SELECT     isnull(MAX(ce_phone1), '')
                            FROM          companyemail
                            WHERE      E.cmp_id = companyemail.cmp_id), revtype1_destino = isnull(E.cmp_revtype1, ''), contact_name_destino =
                          (SELECT     isnull(MAX(contact_name), '')
                            FROM          companyemail
                            WHERE      E.cmp_id = companyemail.cmp_id), referencia_factura = '', fecha_wfactura = CONVERT(datetime, '01/01/1900 01:00'), archivo_tif = 0, 
                      mast_inv = ltrim(CONVERT(char, ivh_archarge))
FROM         invoiceheader, company A, city B, company C, city D, company E, city F
WHERE     invoiceheader.ivh_invoicestatus = 'PRN' AND Substring(ivh_invoicenumber, 1, 1) <> 'T'
-- AND ivh_billto <> 'SAE' 
AND ivh_mbnumber = 0 AND 
                      A.cmp_city = B.cty_code AND A.cmp_id = ivh_billto AND C.cmp_city = D .cty_code AND C.cmp_id = ivh_shipper AND E.cmp_city = F.cty_code AND 
                      E.cmp_id = ivh_consignee
UNION
SELECT     F.ivh_billto, ivh_shipper, ivh_consignee, serie = CASE invoiceheader.ivh_creditmemo WHEN 'N' THEN 'TDR' WHEN 'Y' THEN 'NC' END, ivh_revtype1, 
                      ivh_user_id2, ivh_invoicenumber = F.ivh_invoicenumber, 
                      fecha = CASE WHEN F.ivh_billto = 'KRAFT' THEN ivh_billdate WHEN F.ivh_billto <> 'KRAFT' THEN invoiceheader.ivh_printdate END, F.ord_number, 
                      mov_number = CASE WHEN F.ivh_mbnumber = 0 THEN mov_number WHEN F.ivh_mbnumber > 0 THEN F.ivh_mbnumber END, 
                      ivh_remark = isnull(replace(rtrim(ltrim(replace(replace(ivh_remark, char(13), ''), char(10), ''))), '|', ''), ''), ivh_ref_number = isnull(ivh_ref_number, ''), '', '', 
                      '', lastname = '', firstname = '', licensenumber = '', tractor_licnum = '', trailer_licnum = '', comprobante = ivh_applyto, ivd_descripcion = isnull
                          ((SELECT     MAX(ivd_description)
                              FROM         invoicedetail
                              WHERE     ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND cht_itemcode = 'DEL' AND ivd_description <> 'UNKNOWN'), ''), 
                      ivh_totalcharge = abs(F.ivh_totalcharge), ivh_taxamount1 = abs(F.ivh_taxamount1), ivh_taxamount2 = abs(F.ivh_taxamount2), 
                      invoiceheader.ivh_creditmemo, ciudad_origen =
                          (SELECT     cty_name + ' ' + isnull(rand_state, '')
                            FROM          city
                            WHERE      cty_code = ivh_origincity), ciudad_destino =
                          (SELECT     isnull(cty_name + ' ' + rand_state, '')
                            FROM          city
                            WHERE      cty_code = ivh_destcity), moneda = CASE ivh_currency WHEN 'MX$' THEN 'MX' ELSE 'US' END, masterbill = F.ivh_mbnumber, 
                      peso_estimado = ivh_totalweight, cmp_id = A.cmp_id, rfc = Replace(replace(isnull(A.cmp_taxid, ''), ' ', ''), '-', ''), 
                      calle = isnull(rtrim(ltrim(A.cmp_address1)), ''), ext = isnull(A.cmp_misc1, ''), interior = isnull(A.cmp_misc2, ''), colonia = isnull(A.cmp_address2, ''), 
                      municipio = CASE A.cmp_address3 WHEN '' THEN B.cty_name WHEN NULL THEN B.cty_name ELSE isnull(A.cmp_address3, B.cty_name) END, 
                      ciudad = isnull(B.cty_name, ''), estado =
                          (SELECT     upper(stc_state_desc)
                            FROM          statecountry
                            WHERE      stc_state_c = B.cty_state), pais = A.cmp_country, A.cmp_zip, A.cmp_name, email_address =
                          (SELECT     isnull(MAX(email_address), '')
                            FROM          companyemail
                            WHERE      A.cmp_id = companyemail.cmp_id), ce_phone1 =
                          (SELECT     isnull(MAX(ce_phone1), '')
                            FROM          companyemail
                            WHERE      A.cmp_id = companyemail.cmp_id), A.cmp_revtype1, contact_name =
                          (SELECT     isnull(MAX(contact_name), '')
                            FROM          companyemail
                            WHERE      A.cmp_id = companyemail.cmp_id), rfc_origen = isnull(C.cmp_taxid, ''), calle_origen = isnull(rtrim(ltrim(C.cmp_address1)), ''), 
                      ext_origen = '', interior_origen = '', colonia_origen = isnull(rtrim(ltrim(C.cmp_address2)), ''), 
                      municipio_origen = CASE C.cmp_address3 WHEN '' THEN D .cty_name WHEN NULL THEN D .cty_name ELSE isnull(C.cmp_address3, D .cty_name) 
                      END, cd_origen = isnull(D .cty_name, ''), edo_origen = isnull(D .cty_state, ''), pais_origen = isnull(C.cmp_country, ''), 
                      ZIP_origen = isnull(replace(C.cmp_zip, '|', ''), ''), NAME_origen = isnull(C.cmp_name, ''), email_address_origen =
                          (SELECT     isnull(MAX(email_address), '')
                            FROM          companyemail
                            WHERE      C.cmp_id = companyemail.cmp_id), ce_phone1_origen =
                          (SELECT     isnull(MAX(ce_phone1), '')
                            FROM          companyemail
                            WHERE      C.cmp_id = companyemail.cmp_id), revtype1_origen = C.cmp_revtype1, contact_name_origen =
                          (SELECT     isnull(MAX(contact_name), '')
                            FROM          companyemail
                            WHERE      C.cmp_id = companyemail.cmp_id), rfc_destino = replace(isnull(E.cmp_taxid, ''), '-', ''), calle_destino = isnull((E.cmp_address1), ''), 
                      ext_destino = '', interior_destino = '', colonia_destino = isnull(E.cmp_address2, ''), municipio_destino = isnull(E.cmp_address3, G.cty_name), 
                      cd_destino = isnull(G.cty_name, ''), edo_destino = isnull(G.cty_state, ''), pais_destino = LEFT(isnull(E.cmp_country, ''), 15), 
                      ZIP_destino = isnull(replace(E.cmp_zip, '|', ''), ''), NAME_destino = isnull(E.cmp_name, ''), email_address_destino =
                          (SELECT     isnull(MAX(email_address), '')
                            FROM          companyemail
                            WHERE      E.cmp_id = companyemail.cmp_id), ce_phone1_destino =
                          (SELECT     isnull(MAX(ce_phone1), '')
                            FROM          companyemail
                            WHERE      E.cmp_id = companyemail.cmp_id), revtype1_destino = E.cmp_revtype1, contact_name_destino =
                          (SELECT     isnull(MAX(contact_name), '')
                            FROM          companyemail
                            WHERE      E.cmp_id = companyemail.cmp_id), referencia_factura = '', fecha_wfactura = CONVERT(datetime, '01/01/1900 01:00'), archivo_tif = 0, 
                      mast_inv = ltrim(CONVERT(char, ivh_archarge))
FROM         invoiceheader, vTTSTMW_FirstREg F, company A, city B, company C, city D, company E, city G
WHERE     invoiceheader.ivh_invoicenumber = F.ivh_invoicenumber AND CONVERT(varchar, invoiceheader.ivh_printdate, 112) >= '20100801' AND 
                      F.ivh_mbnumber = invoiceheader.ivh_mbnumber AND A.cmp_city = B.cty_code AND A.cmp_id = invoiceheader.ivh_billto AND 
                      C.cmp_city = D .cty_code AND C.cmp_id = ivh_shipper AND E.cmp_city = G.cty_code AND E.cmp_id = ivh_consignee
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[4] 4[3] 2[77] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 225
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'VISTA_TMW_Header', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'VISTA_TMW_Header', NULL, NULL
GO
