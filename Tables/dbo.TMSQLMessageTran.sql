CREATE TABLE [dbo].[TMSQLMessageTran]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ServerCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Flags] [int] NULL,
[ResetRequest] [datetime] NULL,
[Reset] [datetime] NULL,
[Data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSQLMessageTran] ADD CONSTRAINT [TMSQLMessageTran_PK] PRIMARY KEY NONCLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSQLMessageTran] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSQLMessageTran] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMSQLMessageTran] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSQLMessageTran] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSQLMessageTran] TO [public]
GO
