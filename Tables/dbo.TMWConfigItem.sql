CREATE TABLE [dbo].[TMWConfigItem]
(
[AppKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SectionKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PossibleValues] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRetired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMWConfigItem_IsRetired] DEFAULT ('N'),
[IsGlobalOnly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TMWConfigItem_IsGlobalOnly] DEFAULT ('Y'),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_TMWConfigItem_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigItem] ADD CONSTRAINT [PK_TMWConfigItem_AppKey_SectionKey_ItemKey] PRIMARY KEY CLUSTERED ([AppKey], [SectionKey], [ItemKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigItem] ADD CONSTRAINT [FK_TMWConfigItem_TMWConfigSection] FOREIGN KEY ([AppKey], [SectionKey]) REFERENCES [dbo].[TMWConfigSection] ([AppKey], [SectionKey])
GO
GRANT DELETE ON  [dbo].[TMWConfigItem] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWConfigItem] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWConfigItem] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWConfigItem] TO [public]
GO
