CREATE TABLE [dbo].[settings_source]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_source_createdOn] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_source_updatedOn] DEFAULT (getdate()),
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetiredOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_source] ADD CONSTRAINT [CK_settings_source_name] CHECK (([Name]<>''))
GO
ALTER TABLE [dbo].[settings_source] ADD CONSTRAINT [PK_settings_source] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[settings_source] TO [public]
GO
GRANT INSERT ON  [dbo].[settings_source] TO [public]
GO
GRANT SELECT ON  [dbo].[settings_source] TO [public]
GO
GRANT UPDATE ON  [dbo].[settings_source] TO [public]
GO
