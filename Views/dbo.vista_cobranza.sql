SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_cobranza]
AS
SELECT     DATA.CUSTNMBR, DATA.APFRDCNM, DATA.ActualApplyToAmount, DATA.FROMCURR, DATA.APFRDCDT, DATA.CSPORNBR, dbo.invoiceheader.ivh_totalcharge, 
                      dbo.invoiceheader.ord_hdrnumber, dbo.invoiceheader.ivh_driver, dbo.invoiceheader.ivh_ref_number, dbo.invoiceheader.ivh_revtype2, 
                      dbo.invoiceheader.ivh_revtype4, dbo.invoiceheader.ivh_revtype3, dbo.invoiceheader.ivh_deliverydate, dbo.invoiceheader.ivh_xferdate, 
                      dbo.invoiceheader.ivh_currencydate
FROM         dbo.invoiceheader RIGHT OUTER JOIN
                          (SELECT     CUSTNMBR, APFRDCNM, ActualApplyToAmount, FROMCURR, APFRDCDT, CSPORNBR
                            FROM          TDR.dbo.vista_cobrosvsfact
                            WHERE      (APFRDCDT BETWEEN
                                                       (SELECT     CASE WHEN CHARINDEX(DATENAME(dw, getdate()), 'Monday') != 0 THEN dateadd(DAY, - 9, getdate()) WHEN CHARINDEX(DATENAME(dw, 
                                                                                getdate()), 'Tuesday') != 0 THEN dateadd(DAY, - 10, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Wednesday') 
                                                                                != 0 THEN dateadd(DAY, - 11, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Thursday') != 0 THEN dateadd(DAY, - 12, getdate()) 
                                                                                WHEN CHARINDEX(DATENAME(dw, getdate()), 'Friday') != 0 THEN dateadd(DAY, - 13, getdate()) WHEN CHARINDEX(DATENAME(dw, 
                                                                                getdate()), 'Saturday') != 0 THEN dateadd(DAY, - 14, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Sunday') 
                                                                                != 0 THEN dateadd(DAY, - 15, getdate()) END AS Expr1) AND
                                                       (SELECT     CASE WHEN CHARINDEX(DATENAME(dw, getdate()), 'Monday') != 0 THEN dateadd(DAY, - 3, getdate()) WHEN CHARINDEX(DATENAME(dw, 
                                                                                getdate()), 'Tuesday') != 0 THEN dateadd(DAY, - 4, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Wednesday') 
                                                                                != 0 THEN dateadd(DAY, - 5, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Thursday') != 0 THEN dateadd(DAY, - 6, getdate()) 
                                                                                WHEN CHARINDEX(DATENAME(dw, getdate()), 'Friday') != 0 THEN dateadd(DAY, - 7, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 
                                                                                'Saturday') != 0 THEN dateadd(DAY, - 8, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Sunday') != 0 THEN dateadd(DAY, - 9, 
                                                                                getdate()) END AS Expr1)) AND (CUSTNMBR <> 'SAE') AND (CSPORNBR <> ' ') AND (ActualApplyToAmount > 10)
                            UNION
                            SELECT     CUSTNMBR, DOCNUMBR, ORTRXAMT, CURNCYID, DOCDATE, 'FACTURA' AS CSPORNBR
                            FROM         TDR.dbo.RM20101
                            WHERE     (DOCDATE BETWEEN
                                                      (SELECT     CASE WHEN CHARINDEX(DATENAME(dw, getdate()), 'Monday') != 0 THEN dateadd(DAY, - 9, getdate()) WHEN CHARINDEX(DATENAME(dw, 
                                                                               getdate()), 'Tuesday') != 0 THEN dateadd(DAY, - 10, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Wednesday') 
                                                                               != 0 THEN dateadd(DAY, - 11, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Thursday') != 0 THEN dateadd(DAY, - 12, getdate()) 
                                                                               WHEN CHARINDEX(DATENAME(dw, getdate()), 'Friday') != 0 THEN dateadd(DAY, - 13, getdate()) WHEN CHARINDEX(DATENAME(dw, 
                                                                               getdate()), 'Saturday') != 0 THEN dateadd(DAY, - 14, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Sunday') 
                                                                               != 0 THEN dateadd(DAY, - 15, getdate()) END AS Expr1) AND
                                                      (SELECT     CASE WHEN CHARINDEX(DATENAME(dw, getdate()), 'Monday') != 0 THEN dateadd(DAY, - 3, getdate()) WHEN CHARINDEX(DATENAME(dw, 
                                                                               getdate()), 'Tuesday') != 0 THEN dateadd(DAY, - 4, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Wednesday') 
                                                                               != 0 THEN dateadd(DAY, - 5, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Thursday') != 0 THEN dateadd(DAY, - 6, getdate()) 
                                                                               WHEN CHARINDEX(DATENAME(dw, getdate()), 'Friday') != 0 THEN dateadd(DAY, - 7, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 
                                                                               'Saturday') != 0 THEN dateadd(DAY, - 8, getdate()) WHEN CHARINDEX(DATENAME(dw, getdate()), 'Sunday') != 0 THEN dateadd(DAY, - 9, 
                                                                               getdate()) END AS Expr1)) AND (RMDTYPAL = 9) AND (DOCNUMBR NOT IN
                                                      (SELECT     APFRDCNM
                                                        FROM          TDR.dbo.vista_cobrosvsfact AS vista_cobrosvsfact_1
                                                        WHERE      (APFRDCDT BETWEEN
                                                                                   (SELECT     CASE WHEN CHARINDEX(DATENAME(dw, getdate()), 'Monday') != 0 THEN dateadd(DAY, - 9, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Tuesday') != 0 THEN dateadd(DAY, - 10, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Wednesday') != 0 THEN dateadd(DAY, - 11, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Thursday') != 0 THEN dateadd(DAY, - 12, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Friday') != 0 THEN dateadd(DAY, - 13, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Saturday') != 0 THEN dateadd(DAY, - 14, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Sunday') != 0 THEN dateadd(DAY, - 15, getdate()) END AS Expr1) AND
                                                                                   (SELECT     CASE WHEN CHARINDEX(DATENAME(dw, getdate()), 'Monday') != 0 THEN dateadd(DAY, - 3, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Tuesday') != 0 THEN dateadd(DAY, - 4, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Wednesday') != 0 THEN dateadd(DAY, - 5, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Thursday') != 0 THEN dateadd(DAY, - 6, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Friday') != 0 THEN dateadd(DAY, - 7, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Saturday') != 0 THEN dateadd(DAY, - 8, getdate()) 
                                                                                                            WHEN CHARINDEX(DATENAME(dw, getdate()), 'Sunday') != 0 THEN dateadd(DAY, - 9, getdate()) END AS Expr1))))) AS DATA ON 
                      dbo.invoiceheader.ivh_ref_number = DATA.CSPORNBR
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[2] 2[33] 3) )"
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
         Configuration = "(H (4[44] 2[26] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
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
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "invoiceheader"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 125
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 23
         End
         Begin Table = "DATA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_cobranza', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_cobranza', NULL, NULL
GO
