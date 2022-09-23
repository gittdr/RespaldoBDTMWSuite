CREATE TABLE [dbo].[RecurringAdjustmentLeftCriteria]
(
[ID] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentLeftCriteria] ADD CONSTRAINT [PK_RecurringAdjustmentLeftCriteria] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
