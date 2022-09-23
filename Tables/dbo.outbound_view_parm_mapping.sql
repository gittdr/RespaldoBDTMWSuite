CREATE TABLE [dbo].[outbound_view_parm_mapping]
(
[ovmp_id] [int] NOT NULL IDENTITY(1, 1),
[dv_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parm_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[outbound_view_parm_mapping] ADD CONSTRAINT [PK__outbound_view_pa__7F0556ED] PRIMARY KEY CLUSTERED ([ovmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[outbound_view_parm_mapping] TO [public]
GO
GRANT INSERT ON  [dbo].[outbound_view_parm_mapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[outbound_view_parm_mapping] TO [public]
GO
GRANT SELECT ON  [dbo].[outbound_view_parm_mapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[outbound_view_parm_mapping] TO [public]
GO
