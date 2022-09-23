CREATE TABLE [dbo].[sys_control_reset_rules]
(
[scrr_id] [int] NOT NULL IDENTITY(1, 1),
[scrr_entity] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scrr_resetrule] [tinyint] NOT NULL,
[scrr_table] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sys_control_reset_rules] ADD CONSTRAINT [pk_scrr_id] PRIMARY KEY CLUSTERED ([scrr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[sys_control_reset_rules] TO [public]
GO
GRANT INSERT ON  [dbo].[sys_control_reset_rules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[sys_control_reset_rules] TO [public]
GO
GRANT SELECT ON  [dbo].[sys_control_reset_rules] TO [public]
GO
GRANT UPDATE ON  [dbo].[sys_control_reset_rules] TO [public]
GO
