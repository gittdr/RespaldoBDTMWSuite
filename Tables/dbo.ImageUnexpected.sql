CREATE TABLE [dbo].[ImageUnexpected]
(
[iu_identity] [int] NOT NULL IDENTITY(1, 1),
[iu_date] [datetime] NOT NULL,
[iu_msg] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_id] ON [dbo].[ImageUnexpected] ([iu_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageUnexpected] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageUnexpected] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageUnexpected] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageUnexpected] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageUnexpected] TO [public]
GO
