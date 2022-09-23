CREATE TABLE [dbo].[tblEventsMsgPerformance]
(
[PerfEventNum] [int] NOT NULL IDENTITY(1, 1),
[EventCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SequenceNum] [int] NOT NULL,
[IsOrgin] [tinyint] NULL CONSTRAINT [DF__tblEvents__IsOrg__7149667C] DEFAULT ((0)),
[IsFinal] [tinyint] NULL CONSTRAINT [DF__tblEvents__IsFin__723D8AB5] DEFAULT ((0)),
[LongDescription] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEventsMsgPerformance] ADD CONSTRAINT [PK_tblEventsMsgPerformance] PRIMARY KEY CLUSTERED ([PerfEventNum]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEventsMsgPerformance] ADD CONSTRAINT [uc_EventCode_tblEventsMsgPerformance] UNIQUE NONCLUSTERED ([EventCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblEventsMsgPerformance] TO [public]
GO
GRANT INSERT ON  [dbo].[tblEventsMsgPerformance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblEventsMsgPerformance] TO [public]
GO
GRANT SELECT ON  [dbo].[tblEventsMsgPerformance] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblEventsMsgPerformance] TO [public]
GO
