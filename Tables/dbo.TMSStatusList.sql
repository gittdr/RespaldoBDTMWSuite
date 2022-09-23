CREATE TABLE [dbo].[TMSStatusList]
(
[StatusCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActionCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStatusList] ADD CONSTRAINT [PK_TMSStatusList] PRIMARY KEY CLUSTERED ([StatusCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSStatusList] ADD CONSTRAINT [FK_TMSStatusList_TMSStatusActionList] FOREIGN KEY ([ActionCode]) REFERENCES [dbo].[TMSStatusActionList] ([ActionCode])
GO
GRANT DELETE ON  [dbo].[TMSStatusList] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSStatusList] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSStatusList] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSStatusList] TO [public]
GO
