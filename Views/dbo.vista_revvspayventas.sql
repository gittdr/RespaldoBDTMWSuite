SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_revvspayventas]
AS
SELECT [Leg Header Number], [Move Number], [Order Header Number], [Reference Number], TractorActiveYN, Revenue, [LineHaul Revenue], Pay, 
               TaxableCompensationPay, ReleasedTaxableCompensationPay, [Driver Pay], [Tractor Pay], [Carrier Pay], [Fuel Surcharge], [TRIP Tractor Company], 
               [TRIP Tractor Division], [TRIP Tractor Fleet], [TRIP Tractor Terminal], [TRIP Driver Fleet], [TRIP Driver Division], [TRIP Driver Domicile], [TRIP Driver Company], 
               [TRIP Driver Terminal], OrderTrailerType1, [Driver Hire Date], CarType1, CarType2, CarType3, CarType4, NumberOfSplitsOnMove, NumberOfOrdersOnLeg, 
               NumberOfDropsOnLeg, NumberOfPickUpsOnLeg, NumberOfOrderStopsOnLeg, [Total Miles], [Empty Miles], [Loaded Miles], [Tractor ID], [Driver1 ID], 
               [Driver1 Name], [Driver2 ID], [Driver2 Name], [Carrier ID], [Carrier Name], [Primary Trailer ID], [Segment Trailer ID], [Segment Start Date], [Segment Start Date Only], 
               [Segment Start Day], [Segment Start Month], [Segment Start Month Only], [Segment Start Year], [Segment End Date], [Segment End Date Only], [End Day], 
               [End Month], [End Month Only], [End Year], [Segment Start City], [Segment End City], [Segment Start State], [Segment End State], [Segment Start Region1], 
               [Segment End Region1], [Segment Status], RevType1, RevType2, RevType3, RevType4, [Team Leader ID], Fleet, DrvType1, DrvType2, DrvType3, DrvType4, 
               TrcType1, TrcType2, TrcType3, TrcType4, TrlType1, TrlType2, TrlType3, TrlType4, [Commodity Code], [Freight Description], [Segment Start CmpID], 
               [Segment End CmpID], [Segment Start CmpName], [Segment End CmpName], [Order Ship Date], [Order Delivery Date], [Order Book Date], [Shipper ID], 
               [Consignee ID], [Ordered By ID], [Bill To ID], RevType1AndTractorTerminalDifferentYN, [Booked By], [Order Currency], [Pay Currency], [Revenue Date], 
               [Transfer Date], [Bill Date], [Sub Company ID], [Pay Period DateStr], [Pay Period Date], [Pay To], [Odometer Start], [Odometer End], [Hub Miles], [Dispatch Status], 
               [Trip Hours], lgh_type1, lgh_type2, [Booked RevType1], [204 Status], Comment, [CrossDock Inbound], [CrossDock Outbound], [Trip Origin Country], 
               [Trip Destination Country], [Trip Origin Zip Code], [Trip Destination Zip Code], SecondPickupSequence, SecondDropSequence, [Last GPS Date], 
               [LegHeader LineHaul], RevenuePerTravelMile, LineHaulRevenuePerLoadedMile, RevenuePerLoadedMile, [Percent Empty], FuelSurchargePercentofRevenue, Net, 
               [Accessorial Revenue], [Revenue Per Load], RevenuePerHubMile, LineHaulRevenuePerHubMile, [Allocated Consolidated Load Count], [Other Type 1], 
               [Other Type 2], [Shipper OtherType1], [Shipper OtherType2], [Trailer Company], [Trailer Fleet], [Trailer Terminal], [Trailer Division], [Driver Division], [Driver Domicile], 
               [Driver Fleet], [Driver Terminal], [Driver Company], [Tractor Company], [Tractor Division], [Tractor Terminal], [Tractor Fleet], [Pay Period Month], 
               [Pay Period Month Only], [Order Ship Date Only], [Order Ship Day], [Order Ship Month], [Order Ship Month Only], [Order Ship Year], [Order Ship DayOfWeek], 
               [Delivery Date Only], [Delivery Day], [Delivery Month], [Delivery Month Only], [Delivery Year], [Bill Date Only], [Bill Day], [Bill Month], [Bill Month Only], [Bill Year], 
               [Transfer Date Only], [Transfer Day], [Transfer Month], [Transfer Month Only], [Transfer Year], Shipper, Consignee, [Bill To], [Master Bill To], SameSegmentCityYN, 
               [Order Origin City], [Order Origin State], [Order Dest City], [Order Dest State], SecondPickupCityState, SecondDropCityState, 
               CASE WHEN [Order Currency] = 'US$' THEN Revenue *
                   (SELECT cex_rate
                    FROM   currency_exchange
                    WHERE (DAY(cex_date) =
                                       (SELECT fechamax = MAX(DAY(cex_date))
                                        FROM   currency_exchange
                                        WHERE (MONTH(cex_date) = MONTH(GETDATE())) AND (YEAR(cex_date) = YEAR(GETDATE())))) AND (YEAR(cex_date) = YEAR(GETDATE())) AND 
                                   (MONTH(cex_date) = MONTH(GETDATE()))) WHEN [Order Currency] = 'MX$' THEN Revenue END AS totalrevenue
FROM  dbo.vTTSTMW_RevVsPay
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[14] 2[44] 3) )"
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
         Begin Table = "vTTSTMW_RevVsPay"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 317
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vista_revvspayventas', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_revvspayventas', NULL, NULL
GO
