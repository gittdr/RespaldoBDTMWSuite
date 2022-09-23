CREATE TABLE [dbo].[RecurringAdjustmentMileageCriteria]
(
[ID] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RecurringAdjustmentMileageCriteria] ADD CONSTRAINT [PK_RecurringAdjustmentMileageCriteria] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
