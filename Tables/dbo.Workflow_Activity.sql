CREATE TABLE [dbo].[Workflow_Activity]
(
[Activity_ID] [int] NOT NULL IDENTITY(1, 1),
[Activity_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_RunTimeType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_RunTime] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Workflow_Type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Activity_ClassName] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_OutputFieldname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity_Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Workflow___Activ__4B01F55C] DEFAULT ('Y'),
[IsGUI] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___IsGUI__18416B65] DEFAULT ('N'),
[IsClientSide] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___IsCli__19358F9E] DEFAULT ('N'),
[IsCached] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___IsCac__1A29B3D7] DEFAULT ('N'),
[HasMultipleOutputs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Workflow___HasMu__1B1DD810] DEFAULT ('N'),
[Activity_DependencyPath] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Activity] ADD CONSTRAINT [PK__Workflow__393F5BA59B801FE3] PRIMARY KEY CLUSTERED ([Activity_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Activity] ADD CONSTRAINT [UQ__Workflow__7FD1B8774F4FE5DD] UNIQUE NONCLUSTERED ([Activity_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_Activity] ADD CONSTRAINT [FK__Workflow___Activ__4BF61995] FOREIGN KEY ([Activity_Workflow_Type]) REFERENCES [dbo].[Workflow_Types] ([Type_ID])
GO
GRANT DELETE ON  [dbo].[Workflow_Activity] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_Activity] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_Activity] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_Activity] TO [public]
GO
