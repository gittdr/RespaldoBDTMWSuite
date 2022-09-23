CREATE TABLE [dbo].[tblRawMsgPerformance]
(
[RawPerfNum] [bigint] NOT NULL IDENTITY(1, 1),
[BaseMsgSN] [int] NOT NULL,
[OrgMsgSN] [int] NOT NULL,
[TrueMsgSN] [int] NOT NULL,
[PerfEventNum] [int] NOT NULL,
[EventTime] [datetime2] NOT NULL,
[Processed] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRawMsgPerformance] ADD CONSTRAINT [PK_tblRawMsgPerformance] PRIMARY KEY CLUSTERED ([RawPerfNum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblRawMsgPerformance_BaseSNProcessed] ON [dbo].[tblRawMsgPerformance] ([BaseMsgSN], [Processed]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblRawMsgPerformance] TO [public]
GO
GRANT INSERT ON  [dbo].[tblRawMsgPerformance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblRawMsgPerformance] TO [public]
GO
GRANT SELECT ON  [dbo].[tblRawMsgPerformance] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblRawMsgPerformance] TO [public]
GO
