CREATE TABLE [dbo].[SecondsGained]
(
[SecondsGainedId] [int] NOT NULL IDENTITY(1, 1),
[Value] [int] NULL,
[Sequence] [int] NULL,
[HoSRuleId] [int] NULL,
[ModifiedLast] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecondsGained] ADD CONSTRAINT [PK_dbo.SecondsGained] PRIMARY KEY CLUSTERED ([SecondsGainedId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecondsGained] ADD CONSTRAINT [FK_dbo.SecondsGained_dbo.HoSRule_HoSRuleId] FOREIGN KEY ([HoSRuleId]) REFERENCES [dbo].[HoSRule] ([HoSRuleId]) ON DELETE CASCADE
GO
