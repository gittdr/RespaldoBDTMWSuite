SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VISTA_fe_generadas_vw]
AS
SELECT     dbo.invoiceheader.ivh_mbnumber AS nmaster, dbo.invoiceheader.ivh_invoicenumber AS invoice, 
                      (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END) AS serie, dbo.invoiceheader.ivh_billto AS idreceptor, 
                      dbo.invoiceheader.ivh_printdate AS fhemision, ABS(dbo.invoiceheader.ivh_totalcharge) AS total, (CASE ivh_currency WHEN 'MX$' THEN ' MXN' ELSE 'USD' END) 
                      AS moneda, 
                      CASE WHEN ivh_ref_number LIKE 'CAN%' THEN 'CANCELADA' WHEN ivh_ref_number LIKE 'TDRT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie=' + (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN
                       'Y' THEN 'NCT' END) 
                      + '&folio=' + ivh_invoicenumber + '&tipo=PDF&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652' 
                        WHEN ivh_ref_number LIKE 'NCT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie='
                       + (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END) 
                      + '&folio=' + ivh_invoicenumber + '&tipo=PDF&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652' WHEN ivh_ref_number LIKE 'TDR[0-9]%' THEN 'http://172.16.136.33:1501/TTR931201KJ6_TDR'
                       +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      invoice = ivh_invoicenumber) + '.pdf' WHEN ivh_ref_number LIKE 'NC[0-9]%' THEN 'http://172.16.136.33:1501/TTR931201KJ6_NC' +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      invoice = ivh_invoicenumber) + '.pdf' ELSE 'na' END AS rutapdf, 
                      CASE WHEN ivh_ref_number LIKE 'CAN%' THEN 'CANCELADA' WHEN ivh_ref_number LIKE 'TDRT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie=' + (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN
                       'Y' THEN 'NCT' END) 
                      + '&folio=' + ivh_invoicenumber + '&tipo=XML&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652' WHEN ivh_ref_number LIKE 'NCT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie='
                       + (CASE ivh_creditmemo WHEN 'N' THEN 'TDRT' WHEN 'Y' THEN 'NCT' END) 
                      + '&folio=' + ivh_invoicenumber + '&tipo=XML&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652' WHEN ivh_ref_number LIKE 'TDR[0-9]%' THEN 'http://172.16.136.33:1401/TTR931201KJ6_TDR'
                       +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      invoice = ivh_invoicenumber) 
                      + '_SinADDENDA.xml' WHEN ivh_ref_number LIKE 'NC[0-9]%' THEN 'http://172.16.136.33:1401/TTR931201KJ6_NC' +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      invoice = ivh_invoicenumber) + '_SinADDENDA.xml' ELSE 'na' END AS rutaxml, 
                      'http://172.16.136.34/cgi-bin/img-docfind.pl?reftype=ORD&refnum=' + dbo.invoiceheader.ord_number AS imaging, dbo.invoiceheader.ivh_ref_number AS bandera, 
                      CASE WHEN ivh_ref_number LIKE 'TDRT%' THEN 'Tralix' WHEN ivh_ref_number LIKE 'NCT%' THEN 'Tralix' ELSE 'WF' END AS provfact, 
                      dbo.invoiceheader.ivh_invoicestatus AS statusf,  dbo.invoiceheader.ivh_invoicenumber  as ultinvoice, rtrim(ltrim(ivh_user_id2)) as hechapor
FROM         dbo.city AS F INNER JOIN
                      dbo.company AS E ON F.cty_code = E.cmp_city INNER JOIN
                      dbo.city AS D INNER JOIN
                      dbo.company AS C ON D.cty_code = C.cmp_city INNER JOIN
                      dbo.city AS B INNER JOIN
                      dbo.company AS A ON B.cty_code = A.cmp_city INNER JOIN
                      dbo.invoiceheader ON A.cmp_id = dbo.invoiceheader.ivh_billto ON C.cmp_id = dbo.invoiceheader.ivh_shipper ON 
                      E.cmp_id = dbo.invoiceheader.ivh_consignee
WHERE     (SUBSTRING(dbo.invoiceheader.ivh_invoicenumber, 1, 1) <> 'T') AND (dbo.invoiceheader.ivh_billto <> 'SAE') AND (dbo.invoiceheader.ivh_ref_number <> '') AND 
                      (dbo.invoiceheader.ivh_mbnumber = 0) AND (dbo.invoiceheader.ivh_invoicestatus IN ('PRN', 'XFR')) AND (YEAR(dbo.invoiceheader.ivh_printdate) = 2009)  
--AND (Month(dbo.invoiceheader.ivh_printdate) > 5) 
AND 
                      (dbo.invoiceheader.ivh_invoicenumber NOT IN
                          (SELECT     invoice
                            FROM          dbo.VISTA_fe_Header))
UNION
SELECT     nmaster, invoice, serie, idreceptor,
                          (SELECT     MAX(ivh_printdate) AS Expr1
                            FROM          dbo.invoiceheader AS V
                            WHERE      (ivh_mbnumber = dbo.VISTA_fe_masterhist.nmaster)) AS fhemision,
                          (SELECT     SUM(ivh_totalcharge) AS Expr1
                            FROM          dbo.invoiceheader AS W
                            WHERE      (ivh_mbnumber = dbo.VISTA_fe_masterhist.nmaster)) AS total, moneda, 

                   CASE  WHEN
(SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) 
                      LIKE 'CAN%' THEN 'CANCELADA'



WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) 
                      LIKE 'TDRT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie=' + serie + '&folio=' + invoice + '&tipo=PDF&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652'
                       WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) 
                      LIKE 'NCT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie=' + serie + '&folio=' + invoice + '&tipo=PDF&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652'
                       WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) LIKE 'TDR[0-9]%' THEN 'http://172.16.136.33:1501/TTR931201KJ6_TDR' +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      master = nmaster) + '.pdf' WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) LIKE 'NC[0-9]%' THEN 'http://172.16.136.33:1501/TTR931201KJ6_NC' +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      master = nmaster) + '.pdf' ELSE 'na' END AS rutapdf, 



CASE  WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) 
                      LIKE 'CAN%' THEN 'CANCELADA'



WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) 
                      LIKE 'TDRT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie=' + serie + '&folio=' + invoice + '&tipo=XML&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652'
                       WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) 
                      LIKE 'NCT%' THEN 'http://173.205.254.88/xsamanager/downloadCfdWebView?serie=' + serie + '&folio=' + invoice + '&tipo=XML&rfc=TTR931201KJ6&key=c3a0578bbe5801cecc89d30b48052652'
                       WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) LIKE 'TDR[0-9]%' THEN 'http://172.16.136.33:1401/TTR931201KJ6_TDR' +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      master = nmaster) + '_SinADDENDA.xml' WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) LIKE 'NC[0-9]%' THEN 'http://172.16.136.33:1401/TTR931201KJ6_NC' +
                          (SELECT     MAX(folio)
                            FROM          wf_archivos
                            WHERE      master = nmaster) + '_SinADDENDA.xml' ELSE 'na' END AS rutaxml, 'http://172.16.136.34/cgi-bin/img-docfind.pl?reftype=ORD&refnum=' +
                          (SELECT     MAX(ord_number) AS Expr1
                            FROM          dbo.invoiceheader AS Z
                            WHERE      (ivh_mbnumber = dbo.VISTA_fe_masterhist.nmaster)) AS imaging,
                          (SELECT     MAX(ivh_ref_number) AS Expr1
                            FROM          dbo.invoiceheader AS Y
                            WHERE      (ivh_mbnumber = dbo.VISTA_fe_masterhist.nmaster)) AS bandera, CASE WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) LIKE 'TDRT%' THEN 'Tralix' WHEN
                          (SELECT     MAX(ivh_ref_number)
                            FROM          invoiceheader Y
                            WHERE      y.ivh_mbnumber = nmaster) LIKE 'NCT%' THEN 'Tralix' ELSE 'WF' END AS provfact, statusf, ultinvoice, hechapor
FROM         dbo.VISTA_fe_masterhist
WHERE     (YEAR
                          ((SELECT     MAX(ivh_printdate) AS Expr1
                              FROM         dbo.invoiceheader AS V
                              WHERE     (ivh_mbnumber = dbo.VISTA_fe_masterhist.nmaster))) = 2009)
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
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
         Configuration = "(H (1[56] 4[18] 2) )"
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
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
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
', 'SCHEMA', N'dbo', 'VIEW', N'VISTA_fe_generadas_vw', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'VISTA_fe_generadas_vw', NULL, NULL
GO
