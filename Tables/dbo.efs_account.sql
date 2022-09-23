CREATE TABLE [dbo].[efs_account]
(
[efs_account_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[efs_auto_update_trip_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_unassign_trip_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_update_tractor_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_unassign_tractor_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_update_trailer_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_unassign_trailer_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_update_driver_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_auto_unassign_driver_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_inactive_trip_card_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_default_assignment] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_updated_on] [datetime] NULL,
[efs_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[efs_created_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[efs_account] ADD CONSTRAINT [PK_efs_account] PRIMARY KEY NONCLUSTERED ([efs_account_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[efs_account] TO [public]
GO
GRANT INSERT ON  [dbo].[efs_account] TO [public]
GO
GRANT SELECT ON  [dbo].[efs_account] TO [public]
GO
GRANT UPDATE ON  [dbo].[efs_account] TO [public]
GO
