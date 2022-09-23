CREATE TABLE [dbo].[SecondsWorked]
(
[SecondsWorkedId] [int] NOT NULL IDENTITY(1, 1),
[Value] [int] NULL,
[Sequence] [int] NULL,
[CycleTimeId] [int] NULL,
[ModifiedLast] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecondsWorked] ADD CONSTRAINT [PK_dbo.SecondsWorked] PRIMARY KEY CLUSTERED ([SecondsWorkedId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecondsWorked] ADD CONSTRAINT [FK_dbo.SecondsWorked_dbo.CycleTime_CycleTimeId] FOREIGN KEY ([CycleTimeId]) REFERENCES [dbo].[CycleTime] ([CycleTimeId]) ON DELETE CASCADE
GO
