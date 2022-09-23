CREATE TABLE [dbo].[settings_section]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[SourceID] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_section_createdOn] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_section_updatedOn] DEFAULT (getdate()),
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetiredOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_section] ADD CONSTRAINT [CK_settings_section_name] CHECK (([Name]<>''))
GO
ALTER TABLE [dbo].[settings_section] ADD CONSTRAINT [PK_settings_section] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_section] ADD CONSTRAINT [FK_settings_section] FOREIGN KEY ([SourceID]) REFERENCES [dbo].[settings_source] ([ID])
GO
GRANT DELETE ON  [dbo].[settings_section] TO [public]
GO
GRANT INSERT ON  [dbo].[settings_section] TO [public]
GO
GRANT SELECT ON  [dbo].[settings_section] TO [public]
GO
GRANT UPDATE ON  [dbo].[settings_section] TO [public]
GO
