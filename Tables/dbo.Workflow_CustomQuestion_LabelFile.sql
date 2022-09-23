CREATE TABLE [dbo].[Workflow_CustomQuestion_LabelFile]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TrackingTableName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyFieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrackingColQ1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrackingColA1Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA2Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA3Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA4Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA5Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA6Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA7Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ8] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA8Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColQ9] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingColA9Choices] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastupdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastupdatedDate] [datetime] NOT NULL,
[Q1Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q2Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q3Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q4Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q5Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q6Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q7Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q8Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Q9Desc] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Workflow_CustomQuestion_LabelFile] ADD CONSTRAINT [PK__Workflow__3214EC271F3C82A5] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Workflow_CustomQuestion_LabelFile] TO [public]
GO
GRANT INSERT ON  [dbo].[Workflow_CustomQuestion_LabelFile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Workflow_CustomQuestion_LabelFile] TO [public]
GO
GRANT SELECT ON  [dbo].[Workflow_CustomQuestion_LabelFile] TO [public]
GO
GRANT UPDATE ON  [dbo].[Workflow_CustomQuestion_LabelFile] TO [public]
GO
