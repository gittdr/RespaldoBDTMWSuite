CREATE TABLE [dbo].[TMSStatusActionList]
(
[ActionCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStatusActionList] ADD CONSTRAINT [PK_TMSStatusActionList] PRIMARY KEY CLUSTERED ([ActionCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSStatusActionList] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSStatusActionList] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSStatusActionList] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSStatusActionList] TO [public]
GO
