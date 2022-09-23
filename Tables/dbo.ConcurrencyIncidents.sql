CREATE TABLE [dbo].[ConcurrencyIncidents]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Machine] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Application] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessID] [int] NULL,
[ProcessStart] [datetime] NULL,
[Batch] [int] NULL,
[BatchStart] [datetime] NULL,
[MoveNumber] [int] NULL,
[OrderHeaderNumber] [int] NULL,
[LegHeaderNumber] [int] NULL,
[PreUpdateMoveNumber] [int] NULL,
[PreUpdateOrderHeaderNumber] [int] NULL,
[PreUpdateLegHeaderNumber] [int] NULL,
[UpdateType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyCol1Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol1Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol2Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol2Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol3Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol3Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol4Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyCol4Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleting] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DesiredValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailDate] [datetime] NOT NULL,
[WorkstationWriteDate] [datetime] NULL,
[ServerWriteDate] [datetime] NULL,
[Outcome] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RowWasMissing] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetryUpdateTypeSet] [datetime] NULL,
[RetryUpdateType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConcurrencyIncidents] ADD CONSTRAINT [PK__ConcurrencyIncid__5F3F6575] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ConcurrencyIncidents] TO [public]
GO
GRANT INSERT ON  [dbo].[ConcurrencyIncidents] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ConcurrencyIncidents] TO [public]
GO
GRANT SELECT ON  [dbo].[ConcurrencyIncidents] TO [public]
GO
GRANT UPDATE ON  [dbo].[ConcurrencyIncidents] TO [public]
GO
