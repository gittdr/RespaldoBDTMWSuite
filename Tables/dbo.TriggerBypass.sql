CREATE TABLE [dbo].[TriggerBypass]
(
[moduleid] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TriggerBypass] ADD CONSTRAINT [PK__TriggerBypass__230DAD39] PRIMARY KEY CLUSTERED ([moduleid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TriggerBypass] TO [public]
GO
GRANT INSERT ON  [dbo].[TriggerBypass] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TriggerBypass] TO [public]
GO
GRANT SELECT ON  [dbo].[TriggerBypass] TO [public]
GO
GRANT UPDATE ON  [dbo].[TriggerBypass] TO [public]
GO
