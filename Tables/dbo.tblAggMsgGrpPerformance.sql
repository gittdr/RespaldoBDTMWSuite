CREATE TABLE [dbo].[tblAggMsgGrpPerformance]
(
[MsgGrpAggPerfNum] [int] NOT NULL IDENTITY(1, 1),
[BaseMsgSN] [int] NOT NULL,
[MsgCount] [int] NOT NULL,
[Start] [datetime2] NOT NULL,
[Final] [datetime2] NOT NULL,
[ToVendorRAW] [float] NULL,
[TotalRAW] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAggMsgGrpPerformance] ADD CONSTRAINT [PK_tblAggMsgGrpPerformance] PRIMARY KEY CLUSTERED ([MsgGrpAggPerfNum]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblAggMsgGrpPerformance] TO [public]
GO
GRANT INSERT ON  [dbo].[tblAggMsgGrpPerformance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblAggMsgGrpPerformance] TO [public]
GO
GRANT SELECT ON  [dbo].[tblAggMsgGrpPerformance] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblAggMsgGrpPerformance] TO [public]
GO
