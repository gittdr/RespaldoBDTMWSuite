CREATE TABLE [dbo].[WorkFlow_Sequence]
(
[WorkFlow_Sequence_id] [int] NOT NULL IDENTITY(1, 1),
[WorkFlow_Template_id] [int] NOT NULL,
[WorkFlow_Activity] [int] NOT NULL,
[WorkFlow_TrueActivity] [int] NULL,
[WorkFlow_FalseActivity] [int] NULL,
[WorkFlow_MetaData] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkFlow_OutputFieldname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkFlow_Prefix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkFlow_X] [int] NULL,
[WorkFlow_Y] [int] NULL,
[WorkFlow_Height] [int] NULL,
[WorkFlow_Width] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Sequence] ADD CONSTRAINT [PK__WorkFlow__134E0E483309C38D] PRIMARY KEY CLUSTERED ([WorkFlow_Sequence_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkFlow_Sequence] ADD CONSTRAINT [FK__WorkFlow___WorkF__51AEF2EB] FOREIGN KEY ([WorkFlow_Activity]) REFERENCES [dbo].[Workflow_Activity] ([Activity_ID])
GO
ALTER TABLE [dbo].[WorkFlow_Sequence] ADD CONSTRAINT [FK__WorkFlow___WorkF__50BACEB2] FOREIGN KEY ([WorkFlow_Template_id]) REFERENCES [dbo].[WorkFlow_Template] ([Workflow_Template_ID])
GO
GRANT DELETE ON  [dbo].[WorkFlow_Sequence] TO [public]
GO
GRANT INSERT ON  [dbo].[WorkFlow_Sequence] TO [public]
GO
GRANT SELECT ON  [dbo].[WorkFlow_Sequence] TO [public]
GO
GRANT UPDATE ON  [dbo].[WorkFlow_Sequence] TO [public]
GO
