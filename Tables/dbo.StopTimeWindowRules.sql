CREATE TABLE [dbo].[StopTimeWindowRules]
(
[RecId] [int] NOT NULL IDENTITY(1, 1),
[RuleTime] [datetime] NOT NULL,
[MinStartTimeHours] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StopTimeWindowRules] ADD CONSTRAINT [PK__StopTimeWindowRu__02539788] PRIMARY KEY CLUSTERED ([RecId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[StopTimeWindowRules] TO [public]
GO
GRANT INSERT ON  [dbo].[StopTimeWindowRules] TO [public]
GO
GRANT SELECT ON  [dbo].[StopTimeWindowRules] TO [public]
GO
GRANT UPDATE ON  [dbo].[StopTimeWindowRules] TO [public]
GO
