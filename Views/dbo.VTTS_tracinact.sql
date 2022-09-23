SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VTTS_tracinact]
as
SELECT     [Prior Region 1], Tractor, DaysInactive, [Assignment End Date], [TrcType1 Name], [TrcType3 Name], [TrcType4 Name], Driver, [Destination Company], 
                      [TrcType2 Name], [GPS Desc], Misc4
FROM         vTTSTMW_InactivityByTractor
WHERE     (DaysInactive >= 6) AND ([TrcType3 Name] IN ('WM VH', 'WM MX', 'WM MTY', 'TOLVAS', 'SWAT', 'SAYER', 'KRAFT DEDICADO', 'HOME DEPOT', 
                      'FULL SURESTE', 'EUCOMEX', 'DHLX', 'BAJIO')) AND (TrcType2 = 'RENT') AND (ActiveYN = 'y')
GO
