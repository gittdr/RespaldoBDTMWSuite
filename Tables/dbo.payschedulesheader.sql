CREATE TABLE [dbo].[payschedulesheader]
(
[psh_id] [int] NOT NULL,
[psh_name] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psh_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[psh_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_psh1] ON [dbo].[payschedulesheader] ([psh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payschedulesheader] TO [public]
GO
GRANT INSERT ON  [dbo].[payschedulesheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payschedulesheader] TO [public]
GO
GRANT SELECT ON  [dbo].[payschedulesheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[payschedulesheader] TO [public]
GO
