CREATE TABLE [dbo].[TM2MCommMappings]
(
[MCommSystem] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCommLookupType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCommLookupValue] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmwLabelDefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmwValue] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TM2MCommMappings] ADD CONSTRAINT [tm2lm_label] CHECK ((isnull([tmwLabelDefinition],'')='' OR [dbo].[CheckLabel]([tmwValue],[tmwLabelDefinition],(1))=(1)))
GO
ALTER TABLE [dbo].[TM2MCommMappings] ADD CONSTRAINT [tm2lm_system] CHECK (([dbo].[CheckLabel]([MCommSystem],'MCommSystem',(1))=(1)))
GO
ALTER TABLE [dbo].[TM2MCommMappings] ADD CONSTRAINT [tm2lm_pk] PRIMARY KEY CLUSTERED ([MCommSystem], [MCommLookupType], [MCommLookupValue]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TM2MCommMappings] TO [public]
GO
GRANT INSERT ON  [dbo].[TM2MCommMappings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TM2MCommMappings] TO [public]
GO
GRANT SELECT ON  [dbo].[TM2MCommMappings] TO [public]
GO
GRANT UPDATE ON  [dbo].[TM2MCommMappings] TO [public]
GO
