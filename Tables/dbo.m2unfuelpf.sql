CREATE TABLE [dbo].[m2unfuelpf]
(
[ufunit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ufkeyvalue] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ufvalue] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ufstamp] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ufunit] ON [dbo].[m2unfuelpf] ([ufunit]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2unfuelpf] TO [public]
GO
GRANT INSERT ON  [dbo].[m2unfuelpf] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2unfuelpf] TO [public]
GO
GRANT SELECT ON  [dbo].[m2unfuelpf] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2unfuelpf] TO [public]
GO
