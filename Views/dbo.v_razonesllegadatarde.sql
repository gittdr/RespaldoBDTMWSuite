SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
select sxn_mov_number,sxn_sequence_number,sxa_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm,'C'
from serviceexceptionaudit where sxn_mov_number = @pl_mov
union
select sxn_mov_number,sxn_sequence_number,0,'Deleted!',sxn_asgn_type,sxn_asgn_id, sxn_deletedby,sxn_deleteddate,'D'
from serviceexception where sxn_mov_number = @pl_mov and sxn_delete_flag = 'Y'
end
else
begin

select sxn_mov_number,sxn_sequence_number,sxa_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm,'C'
from serviceexceptionaudit where sxn_sequence_number = @sxn_sequence_number
union
select sxn_mov_number,sxn_sequence_number,0,'Deleted!',sxn_asgn_type,sxn_asgn_id, sxn_deletedby,sxn_deleteddate,'D'
from serviceexception where sxn_sequence_number = @sxn_sequence_number and sxn_delete_flag = 'Y'

sxn_stp_number, sxn_sequence_number, sxn_asgn_type, sxn_asgn_id,  sxn_expcode, sxn_expdate, sxn_mov_number, 
sxn_createdby,  sxn_createddate, sxn_affectspay, sxn_actioncode, sxn_actionuserid, sxn_actiondate, 
sxn_description, sxn_ord_hdrnumber, sxn_cmp_id, sxn_cty_code, sxn_action_description, sxn_delete_flag,
sxn_deletedby,   sxn_deleteddate, sxn_late, sxn_contact_customer, sxn_action_received, sxn_action_received_desc
from serviceexception
sp_help

-Drop View v_razonesllegadatarde
select ord_status, ord_billto,* from orderheader where ord_hdrnumber = 118842



*/
CREATE VIEW [dbo].[v_razonesllegadatarde]
AS
SELECT     CASE sxn_expcode WHEN 'FM' THEN 'MTTO' WHEN 'OP' THEN 'Operac' WHEN 'DP' THEN 'Operac' WHEN 'SIN' THEN 'Otros' WHEN 'CU' THEN 'Otros'
                       WHEN 'SC' THEN 'Otros' WHEN 'CL' THEN 'Otros' WHEN 'LL' THEN 'MTTO' WHEN 'DDES' THEN 'SAC' WHEN 'ESAC' THEN 'SAC' WHEN 'FSL' THEN 'Operac'
                       WHEN 'FSC' THEN 'CEMS' WHEN 'UNK' THEN 'No Ident' END AS Depto, YEAR(dbo.serviceexception.sxn_createddate) AS Año, 
                      CASE Month(sxn_createddate) 
                      WHEN '1' THEN 'Ene' WHEN '2' THEN 'Feb' WHEN '3' THEN 'Mar' WHEN '4' THEN 'Abr' WHEN '5' THEN 'May' WHEN '6' THEN 'Jun' WHEN '7' THEN 'Jul'
                       WHEN '8' THEN 'Ago' WHEN '9' THEN 'Sep' WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dic' END AS mes, 
                      DAY(dbo.serviceexception.sxn_createddate) AS Dia, DATEPART(week, dbo.serviceexception.sxn_createddate) - 1 AS Semana, 
                      dbo.serviceexception.sxn_asgn_type, dbo.serviceexception.sxn_asgn_id, dbo.serviceexception.sxn_expdate, 
                      dbo.serviceexception.sxn_mov_number, dbo.serviceexception.sxn_createdby, dbo.serviceexception.sxn_description, 
                      dbo.serviceexception.sxn_ord_hdrnumber, dbo.serviceexception.sxn_cmp_id, dbo.serviceexception.sxn_cty_code, 
                      dbo.serviceexception.sxn_action_description, dbo.serviceexception.sxn_late, dbo.serviceexception.sxn_action_received_desc, 
                      dbo.serviceexception.sxn_expcode, 
                      dbo.orderheader.ord_billto + '/Driver:' + dbo.serviceexception.sxn_asgn_id + '/Creado por:' + dbo.serviceexception.sxn_createdby + '/Leader:' + RTRIM(dbo.manpowerprofile.mpp_teamleader)
                       AS Identificador
FROM         dbo.serviceexception INNER JOIN
                      dbo.orderheader ON dbo.serviceexception.sxn_ord_hdrnumber = dbo.orderheader.ord_hdrnumber INNER JOIN
                      dbo.manpowerprofile ON dbo.orderheader.ord_driver1 = dbo.manpowerprofile.mpp_id
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
         Begin Table = "serviceexception"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 132
               Left = 553
               Bottom = 349
               Right = 810
            End
            DisplayFlags = 280
            TopColumn = 56
         End
         Begin Table = "manpowerprofile"
            Begin Extent = 
               Top = 44
               Left = 1106
               Bottom = 349
               Right = 1384
            End
            DisplayFlags = 280
            TopColumn = 18
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 20
         Width = 284
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
         Width = 11145
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
         O', 'SCHEMA', N'dbo', 'VIEW', N'v_razonesllegadatarde', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'r = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'v_razonesllegadatarde', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_razonesllegadatarde', NULL, NULL
GO
