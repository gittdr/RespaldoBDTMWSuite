CREATE TABLE [dbo].[SyncTable]
(
[SyncSet] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PSTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RuleType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rules] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyNumeric] [numeric] (18, 0) NULL,
[KeyDate] [datetime] NULL,
[KeyOther] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSKeyField] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyField] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSPrimaryField] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryField] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StoredProc] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SyncTable] TO [public]
GO
GRANT INSERT ON  [dbo].[SyncTable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SyncTable] TO [public]
GO
GRANT SELECT ON  [dbo].[SyncTable] TO [public]
GO
GRANT UPDATE ON  [dbo].[SyncTable] TO [public]
GO
