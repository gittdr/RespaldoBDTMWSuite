CREATE TABLE [dbo].[KaneStatusData]
(
[ImpId] [int] NOT NULL IDENTITY(1, 1),
[KaneId] [int] NOT NULL,
[OrderNumber] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerNumber] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusCode] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDateTime] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentNumber] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusDescription] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedByUser] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Device] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Program] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Time] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Date] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AuthorizationNumber] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReasonStatus] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CheckC3Value] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCreated] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C3TSTP] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[C3SEQNO] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneStatusData] ADD CONSTRAINT [PK_KaneStatusData] PRIMARY KEY CLUSTERED ([ImpId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneStatusData] ADD CONSTRAINT [FK_KaneStatusData_KaneBatch] FOREIGN KEY ([KaneId]) REFERENCES [dbo].[KaneBatch] ([KaneId])
GO
GRANT DELETE ON  [dbo].[KaneStatusData] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneStatusData] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneStatusData] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneStatusData] TO [public]
GO
