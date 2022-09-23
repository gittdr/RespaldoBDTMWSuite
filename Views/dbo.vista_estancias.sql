SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vista_estancias]
AS
SELECT     dbo.vTTSTMW_PayDetails.[PayDetail Number], dbo.vTTSTMW_PayDetails.[PayHeader Number], dbo.vTTSTMW_PayDetails.[LegHeader Number], 
                      dbo.vTTSTMW_PayDetails.[Assignment Number], dbo.vTTSTMW_PayDetails.[Resource Type], dbo.vTTSTMW_PayDetails.[Resource ID], 
                      dbo.vTTSTMW_PayDetails.[Resource Name], dbo.vTTSTMW_PayDetails.[Other ID], dbo.vTTSTMW_PayDetails.DrvType1, 
                      dbo.vTTSTMW_PayDetails.DrvType2, dbo.vTTSTMW_PayDetails.DrvType3, dbo.vTTSTMW_PayDetails.DrvType4, 
                      dbo.vTTSTMW_PayDetails.[Tractor Company], dbo.vTTSTMW_PayDetails.[Tractor Division], dbo.vTTSTMW_PayDetails.[Tractor Terminal], 
                      dbo.vTTSTMW_PayDetails.[Tractor Fleet], dbo.vTTSTMW_PayDetails.TrcType1, dbo.vTTSTMW_PayDetails.TrcType2, 
                      dbo.vTTSTMW_PayDetails.TrcType3, dbo.vTTSTMW_PayDetails.TrcType4, dbo.vTTSTMW_PayDetails.TrlType1, dbo.vTTSTMW_PayDetails.TrlType2, 
                      dbo.vTTSTMW_PayDetails.TrlType3, dbo.vTTSTMW_PayDetails.TrlType4, dbo.vTTSTMW_PayDetails.CarType1, dbo.vTTSTMW_PayDetails.CarType2, 
                      dbo.vTTSTMW_PayDetails.CarType3, dbo.vTTSTMW_PayDetails.CarType4, dbo.vTTSTMW_PayDetails.[Invoice Detail Number], 
                      dbo.vTTSTMW_PayDetails.[Pay To], dbo.vTTSTMW_PayDetails.[Pay To Name], dbo.vTTSTMW_PayDetails.[Pay Type], 
                      dbo.vTTSTMW_PayDetails.[Pay Type Description], dbo.vTTSTMW_PayDetails.[Move Number], dbo.vTTSTMW_PayDetails.Description, 
                      dbo.vTTSTMW_PayDetails.[Pay Rate Code], dbo.vTTSTMW_PayDetails.Quantity, dbo.vTTSTMW_PayDetails.[Rate Unit], 
                      dbo.vTTSTMW_PayDetails.Unit, dbo.vTTSTMW_PayDetails.Rate, dbo.vTTSTMW_PayDetails.Amount, dbo.vTTSTMW_PayDetails.PreTax, 
                      dbo.vTTSTMW_PayDetails.GLCode, dbo.vTTSTMW_PayDetails.[Currency Type], dbo.vTTSTMW_PayDetails.[Currency Date], 
                      dbo.vTTSTMW_PayDetails.[Currency Date Only], dbo.vTTSTMW_PayDetails.[Currency Day], dbo.vTTSTMW_PayDetails.[Currency Month], 
                      dbo.vTTSTMW_PayDetails.[Currency Month Only], dbo.vTTSTMW_PayDetails.[Currency Year], dbo.vTTSTMW_PayDetails.[Pay Status], 
                      dbo.vTTSTMW_PayDetails.[Ref Num Type], dbo.vTTSTMW_PayDetails.[Ref Num], dbo.vTTSTMW_PayDetails.[Pay Period Date], 
                      dbo.vTTSTMW_PayDetails.[Pay Period Date Only], dbo.vTTSTMW_PayDetails.[Pay Period Day], dbo.vTTSTMW_PayDetails.[Pay Period Month], 
                      dbo.vTTSTMW_PayDetails.[Pay Period Month Only], dbo.vTTSTMW_PayDetails.[Pay Period Year], dbo.vTTSTMW_PayDetails.[Work Period Date], 
                      dbo.vTTSTMW_PayDetails.[Trip Start Point], dbo.vTTSTMW_PayDetails.[Trip Start Zip Code], dbo.vTTSTMW_PayDetails.[Trip Start City-State], 
                      dbo.vTTSTMW_PayDetails.[Trip Start State], dbo.vTTSTMW_PayDetails.[Trip End Point], dbo.vTTSTMW_PayDetails.[Trip End Zip Code], 
                      dbo.vTTSTMW_PayDetails.[Trip End City-State], dbo.vTTSTMW_PayDetails.[Trip End State], dbo.vTTSTMW_PayDetails.[InvoiceDetail Pay Revenue], 
                      dbo.vTTSTMW_PayDetails.[Revenue Ratio], dbo.vTTSTMW_PayDetails.[Less Revenue], dbo.vTTSTMW_PayDetails.[PayDetail Pay Revenue], 
                      dbo.vTTSTMW_PayDetails.[Transaction Date], dbo.vTTSTMW_PayDetails.[Transaction Date Only], dbo.vTTSTMW_PayDetails.[Transaction Day], 
                      dbo.vTTSTMW_PayDetails.[Transaction Month], dbo.vTTSTMW_PayDetails.[Transaction Month Only], dbo.vTTSTMW_PayDetails.[Transaction Year], 
                      dbo.vTTSTMW_PayDetails.Minus, dbo.vTTSTMW_PayDetails.[PayDetail Sequence], dbo.vTTSTMW_PayDetails.[StandingDeduction Number], 
                      dbo.vTTSTMW_PayDetails.[Load State], dbo.vTTSTMW_PayDetails.[Transfer Number], dbo.vTTSTMW_PayDetails.[Order Number], 
                      dbo.vTTSTMW_PayDetails.Fee1, dbo.vTTSTMW_PayDetails.Fee2, dbo.vTTSTMW_PayDetails.[Gross Amount], 
                      dbo.vTTSTMW_PayDetails.[Updated By], dbo.vTTSTMW_PayDetails.[Export Status], dbo.vTTSTMW_PayDetails.[Released By], 
                      dbo.vTTSTMW_PayDetails.[Charge Type Code], dbo.vTTSTMW_PayDetails.[Billed Weight], dbo.vTTSTMW_PayDetails.[Tarrif Number], 
                      dbo.vTTSTMW_PayDetails.[Updated On], dbo.vTTSTMW_PayDetails.[Offsetpay Number], dbo.vTTSTMW_PayDetails.[Invoice Header Number], 
                      dbo.vTTSTMW_PayDetails.[Transfer Date], dbo.vTTSTMW_PayDetails.[Transfer Date Only], dbo.vTTSTMW_PayDetails.[Transfer Day], 
                      dbo.vTTSTMW_PayDetails.[Transfer Month], dbo.vTTSTMW_PayDetails.[Transfer Month Only], dbo.vTTSTMW_PayDetails.[Transfer Year], 
                      dbo.vTTSTMW_PayDetails.[Invoice Status], dbo.vTTSTMW_PayDetails.[Bill To ID], dbo.vTTSTMW_PayDetails.ReferenceNumber, 
                      dbo.vTTSTMW_PayDetails.ReferenceType, dbo.vTTSTMW_PayDetails.[Order Status], dbo.vTTSTMW_PayDetails.[Bill Date], 
                      dbo.vTTSTMW_PayDetails.ord_startdate, dbo.vTTSTMW_PayDetails.ord_completiondate, dbo.vTTSTMW_PayDetails.RevType1, 
                      dbo.vTTSTMW_PayDetails.RevType2, dbo.vTTSTMW_PayDetails.RevType3, dbo.vTTSTMW_PayDetails.RevType4, 
                      dbo.vTTSTMW_PayDetails.[Order Origin City], dbo.vTTSTMW_PayDetails.[Order Origin State], dbo.vTTSTMW_PayDetails.[Order Dest City], 
                      dbo.vTTSTMW_PayDetails.[Order Dest State], dbo.vTTSTMW_PayDetails.[PayHeader Pay Status], dbo.vTTSTMW_PayDetails.[Team Leader ID], 
                      dbo.vTTSTMW_PayDetails.PayToAltID, dbo.vTTSTMW_PayDetails.[PayTo First Name], dbo.vTTSTMW_PayDetails.[PayTo Middle Name], 
                      dbo.vTTSTMW_PayDetails.[PayTo Last Name], dbo.vTTSTMW_PayDetails.[PayTo Social Security Number], 
                      dbo.vTTSTMW_PayDetails.[PayTo Address1], dbo.vTTSTMW_PayDetails.[PayTo Address2], dbo.vTTSTMW_PayDetails.[PayTo CityName], 
                      dbo.vTTSTMW_PayDetails.[PayTo State], dbo.vTTSTMW_PayDetails.[PayTo Zip Code], dbo.vTTSTMW_PayDetails.[PayTo Phone Number1], 
                      dbo.vTTSTMW_PayDetails.[PayTo Phone Number2], dbo.vTTSTMW_PayDetails.[PayTo Phone Number3], dbo.vTTSTMW_PayDetails.[PayTo Currency], 
                      dbo.vTTSTMW_PayDetails.[PayTo Type1], dbo.vTTSTMW_PayDetails.[PayTo Type2], dbo.vTTSTMW_PayDetails.[PayTo Type3], 
                      dbo.vTTSTMW_PayDetails.[PayTo Type4], dbo.vTTSTMW_PayDetails.[PayTo Company ID], dbo.vTTSTMW_PayDetails.[PayTo Division], 
                      dbo.vTTSTMW_PayDetails.[PayTo Terminal], dbo.vTTSTMW_PayDetails.[PayTo PayToStatus], dbo.vTTSTMW_PayDetails.[PayTo LastFirstName], 
                      dbo.vTTSTMW_PayDetails.[PayTo Fleet], dbo.vTTSTMW_PayDetails.[PayTo Misc1], dbo.vTTSTMW_PayDetails.[PayTo Misc2], 
                      dbo.vTTSTMW_PayDetails.[PayTo Misc3], dbo.vTTSTMW_PayDetails.[PayTo Misc4], dbo.vTTSTMW_PayDetails.[PayTo UpdatedBy], 
                      dbo.vTTSTMW_PayDetails.[PayTo UpdatedDate], dbo.vTTSTMW_PayDetails.[PayTo YearToDateGross], 
                      dbo.vTTSTMW_PayDetails.[PayTo SocSecFedTax], dbo.vTTSTMW_PayDetails.[PayTo DirectDeposit], dbo.vTTSTMW_PayDetails.[PayTo FleetTrc], 
                      dbo.vTTSTMW_PayDetails.[PayTo Start Date], dbo.vTTSTMW_PayDetails.[PayTo Termination Date], dbo.vTTSTMW_PayDetails.[PayTo Created Date], 
                      dbo.vTTSTMW_PayDetails.[PayTo CompanyName], dbo.vTTSTMW_PayDetails.[Pay Detail Category], 
                      dbo.vTTSTMW_PayDetails.[Pay Currency Conversion Status], dbo.vTTSTMW_PayDetails.Branch, dbo.vTTSTMW_PayDetails.[Auth Code], 
                      dbo.vTTSTMW_PayDetails.[Trip Origin Country], dbo.vTTSTMW_PayDetails.[Trip Destination Country], 
                      dbo.vTTSTMW_PayDetails.[Trip Origin Zip Code], dbo.vTTSTMW_PayDetails.[Order Origin Country], 
                      dbo.vTTSTMW_PayDetails.[Order Destination Country], dbo.vTTSTMW_PayDetails.[Order Origin Zip Code], 
                      dbo.vTTSTMW_PayDetails.[Order Destination Zip Code], dbo.vTTSTMW_PayDetails.[Created From], dbo.vTTSTMW_PayDetails.[Ship Date], 
                      dbo.vTTSTMW_PayDetails.[Ship Date Only], dbo.vTTSTMW_PayDetails.[Ship Day], dbo.vTTSTMW_PayDetails.[Ship Month], 
                      dbo.vTTSTMW_PayDetails.[Ship Month Only], dbo.vTTSTMW_PayDetails.[Ship Year], dbo.vTTSTMW_PayDetails.[Delivery Date], 
                      dbo.vTTSTMW_PayDetails.[Delivery Date Only], dbo.vTTSTMW_PayDetails.[Delivery Day], dbo.vTTSTMW_PayDetails.[Delivery Month], 
                      dbo.vTTSTMW_PayDetails.[Delivery Month Only], dbo.vTTSTMW_PayDetails.[Delivery Year], 
                      CASE [Pay Type] WHEN 'COBEST' THEN 'Cliente' WHEN 'COMEST' THEN 'Patios' WHEN 'ECC' then 'Cliente' When 'EM' then 'Patios' END AS tipoest, 
                      CASE [Pay Type] WHEN 'COBEST' THEN 'Cliente' WHEN 'COMEST' THEN 'Patios' WHEN 'ECC' then 'Cliente' When 'EM' then 'Patios' END AS tipoest2,
					  
					   DATEPART(ww, 
                      dbo.vTTSTMW_PayDetails.[Transaction Date]) AS semana, DAY(dbo.vTTSTMW_PayDetails.[Transaction Date]) AS dia, 
                      MONTH(dbo.vTTSTMW_PayDetails.[Transaction Date]) AS mes, 
                      CASE [Order Dest State] WHEN 'AG' THEN 'TDR GUADALAJARA' WHEN 'BJ' THEN 'TDR GUADALAJARA' WHEN 'BS' THEN 'TDR GUADALAJARA' WHEN 'CP'
                       THEN 'TDR MEXICO' WHEN 'CH' THEN 'TDR MEXICO' WHEN 'CI' THEN 'TDR MONTERREY' WHEN 'CU' THEN 'TDR MEXICO' WHEN 'CL' THEN 'TDR GUADALAJARA'
                       WHEN 'DF' THEN 'TDR MEXICO' WHEN 'DG' THEN 'TDR GUADALAJARA' WHEN 'EM' THEN 'TDR MEXICO' WHEN 'GJ' THEN 'TDR MEXICO' WHEN 'GR'
                       THEN 'TDR QUERETARO' WHEN 'HG' THEN 'TDR MEXICO' WHEN 'JA' THEN 'TDR GUADALAJARA' WHEN 'MH' THEN 'TDR MEXICO' WHEN 'MR' THEN
                       'TDR MEXICO' WHEN 'NA' THEN 'TDR GUADALAJARA' WHEN 'NX' THEN 'TDR MONTERREY' WHEN 'OA' THEN 'TDR MEXICO' WHEN 'PU' THEN 'TDR MEXICO'
                       WHEN 'QA' THEN 'TDR MEXICO' WHEN 'QR' THEN 'TDR MEXICO' WHEN 'SL' THEN 'TDR QUERETARO' WHEN 'SI' THEN 'TDR MONTERREY' WHEN 'SO'
                       THEN 'TDR MONTERREY' WHEN 'TA' THEN 'TDR MEXICO' WHEN 'TM' THEN 'TDR NUEVO LAREDO' WHEN 'TL' THEN 'TDR MEXICO' WHEN 'VZ' THEN
                       'TDR MEXICO' WHEN 'YC' THEN 'TDR MEXICO' WHEN 'ZT' THEN 'TDR GUADALAJARA' WHEN 'MX' THEN 'TDR MEXICO' ELSE [Order Dest State] END  AS patio, 
                      dbo.orderheader.ord_billto, dbo.orderheader.ord_tractor, dbo.orderheader.ord_bookedby, dbo.orderheader.last_updateby,dbo.vTTSTMW_PayDetails.pyd_createdon as pyd_createdon
FROM         dbo.vTTSTMW_PayDetails INNER JOIN
                      dbo.orderheader ON CAST(dbo.vTTSTMW_PayDetails.[Order Number] AS varchar) = CAST(dbo.orderheader.ord_number AS varchar)
WHERE     (dbo.vTTSTMW_PayDetails.[Pay Type Description] IN ('%Estancias Cte Carga', '%Estancias Cte Descarga', '%Estancias MTTO','%Estancias en Patio')) AND 
                      (YEAR(dbo.vTTSTMW_PayDetails.[pyd_createdon]) >= 2012)



GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[16] 2[30] 3) )"
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
         Begin Table = "vTTSTMW_PayDetails"
            Begin Extent = 
               Top = 15
               Left = 338
               Bottom = 350
               Right = 574
            End
            DisplayFlags = 280
            TopColumn = 77
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 4
               Left = 628
               Bottom = 145
               Right = 903
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
      Begin ColumnWidths = 194
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1755
         Width = 1440
         Width = 1440
         Width = 2310
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
 ', 'SCHEMA', N'dbo', 'VIEW', N'vista_estancias', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'        Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 2025
         Width = 2370
         Width = 2115
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1200
         Width = 2670
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
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
 ', 'SCHEMA', N'dbo', 'VIEW', N'vista_estancias', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane3', N'  End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vista_estancias', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=3
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_estancias', NULL, NULL
GO
