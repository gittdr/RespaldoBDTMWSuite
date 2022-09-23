CREATE TABLE [dbo].[csvoutbound]
(
[cso_id] [int] NOT NULL IDENTITY(1, 1),
[cso_file] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cso_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cso_created_dt] [datetime] NULL,
[cso_sent_dt] [datetime] NULL,
[cso_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csvoutbound] ADD CONSTRAINT [pk_csvoutbound_cso_id] PRIMARY KEY CLUSTERED ([cso_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[csvoutbound] TO [public]
GO
GRANT INSERT ON  [dbo].[csvoutbound] TO [public]
GO
GRANT REFERENCES ON  [dbo].[csvoutbound] TO [public]
GO
GRANT SELECT ON  [dbo].[csvoutbound] TO [public]
GO
GRANT UPDATE ON  [dbo].[csvoutbound] TO [public]
GO
