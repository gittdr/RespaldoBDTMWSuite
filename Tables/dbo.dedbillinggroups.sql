CREATE TABLE [dbo].[dedbillinggroups]
(
[dbg_id] [int] NOT NULL IDENTITY(1, 1),
[dbg_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbg_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbg_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillinggroups] ADD CONSTRAINT [pk_dedbillinggroups_dbgh_id] PRIMARY KEY CLUSTERED ([dbg_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillinggroups] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillinggroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillinggroups] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillinggroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillinggroups] TO [public]
GO
