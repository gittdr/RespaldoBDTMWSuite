CREATE TABLE [dbo].[settings_item]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_settings_item_description] DEFAULT (''),
[SectionID] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AliasOfItemID] [int] NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_item_createdOn] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_item_updatedOn] DEFAULT (getdate()),
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetiredOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_item] ADD CONSTRAINT [CK_settings_item_name] CHECK (([Name]<>''))
GO
ALTER TABLE [dbo].[settings_item] ADD CONSTRAINT [PK_settings_item] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_item] ADD CONSTRAINT [FK_settings_item] FOREIGN KEY ([SectionID]) REFERENCES [dbo].[settings_section] ([ID])
GO
GRANT DELETE ON  [dbo].[settings_item] TO [public]
GO
GRANT INSERT ON  [dbo].[settings_item] TO [public]
GO
GRANT SELECT ON  [dbo].[settings_item] TO [public]
GO
GRANT UPDATE ON  [dbo].[settings_item] TO [public]
GO
