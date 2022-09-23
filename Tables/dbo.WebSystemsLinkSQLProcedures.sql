CREATE TABLE [dbo].[WebSystemsLinkSQLProcedures]
(
[ProcedureId] [int] NOT NULL IDENTITY(1, 1),
[ProcedureKey] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcedureName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkSQLProcedures] ADD CONSTRAINT [PK_WebSystemsLinkSQLProcedures] PRIMARY KEY CLUSTERED ([ProcedureId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[WebSystemsLinkSQLProcedures] TO [public]
GO
GRANT INSERT ON  [dbo].[WebSystemsLinkSQLProcedures] TO [public]
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkSQLProcedures] TO [public]
GO
GRANT UPDATE ON  [dbo].[WebSystemsLinkSQLProcedures] TO [public]
GO
