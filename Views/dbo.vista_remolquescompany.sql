SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vista_remolquescompany]
AS
SELECT     trl_number, trl_avail_date, 
DATEDIFF(dd, trl_avail_date, GETDATE()) AS DIFDIAS,
DATEDIFF(dd, trl_avail_date, GETDATE()) AS DIAS,
trl_quickentry as CapturaRapida,

trl_prior_cmp_id ,
trl_avail_cmp_id ,
(select rgh_name from regionheader with (nolock) where rgh_id  = (select cmp_region1  from company where company.cmp_id = trl_avail_cmp_id)) as Region,

trl_status,
trl_type2,
trl_type1,
trl_type3,
trl_updatedby,
trl_createdate,
(select cmp_revtype3 from company with (nolock)  where  CMP_ID = trl_avail_cmp_id) AS proyecto,

case 
when ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id) in ('NV')) then 'LAD'
when ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id) in ('GD','CU'))  then 'GDA'
when ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id)  in ('MA','MX','PB','VH')) then'MEX'
when ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id)  in ('MT','CH','TJ')) then 'MTE'
when ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id)  in ('QR'))  then'QRO'
end as sucursal

--(select cmp_revtype2 from company with (nolock)  where  CMP_ID = trl_avail_cmp_id) AS sucursal

FROM         dbo.trailerprofile with (nolock) 
WHERE     (trl_status not in ('OUT')) --,'SIN','VAC'))
--and trl_number not in (select exp_id from expiration where exp_idtype = 'TRL')








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
         Begin Table = "trailerprofile"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 233
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 9
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1980
         Width = 2295
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_remolquescompany', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_remolquescompany', NULL, NULL
GO
