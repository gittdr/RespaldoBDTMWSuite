CREATE TABLE [dbo].[tarifferrorlog]
(
[tel_id] [int] NOT NULL IDENTITY(1, 1),
[tel_dttm] [datetime] NOT NULL,
[tel_msg] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tel_userid] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tarifferrorlog] ADD CONSTRAINT [pk_tarifferrorlog] PRIMARY KEY CLUSTERED ([tel_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tarifferrorlogdttm] ON [dbo].[tarifferrorlog] ([tel_dttm]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tarifferrorlog] TO [public]
GO
GRANT INSERT ON  [dbo].[tarifferrorlog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tarifferrorlog] TO [public]
GO
GRANT SELECT ON  [dbo].[tarifferrorlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tarifferrorlog] TO [public]
GO
