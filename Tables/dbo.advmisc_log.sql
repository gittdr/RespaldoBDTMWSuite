CREATE TABLE [dbo].[advmisc_log]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Action] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyd_number] [int] NOT NULL,
[createdon] [datetime] NOT NULL CONSTRAINT [DF__advmisc_l__creat__1F165E49] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[advmisc_log] ADD CONSTRAINT [pk_advmisc_log_sn] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[advmisc_log] TO [public]
GO
GRANT INSERT ON  [dbo].[advmisc_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[advmisc_log] TO [public]
GO
GRANT SELECT ON  [dbo].[advmisc_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[advmisc_log] TO [public]
GO
