CREATE TABLE [dbo].[Workflow_Queues]
(
[Queue_ID] [int] NOT NULL IDENTITY(1, 1),
[Queue_Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Queue_Level] [int] NULL,
[Queue_Type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Queue_User] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Queues] ADD CONSTRAINT [PK__Workflow__2BDBAB00C7B50D43] PRIMARY KEY CLUSTERED ([Queue_ID]) ON [PRIMARY]
GO
