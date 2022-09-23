CREATE TABLE [dbo].[settings_value]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ItemID] [int] NOT NULL,
[ScopeType] [int] NOT NULL,
[ScopeName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MachineName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_settings_value_machineName] DEFAULT (''),
[ShortValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LongValue] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScopeLocked] [bit] NOT NULL CONSTRAINT [DF_settings_value_scopeLocked] DEFAULT (0),
[TypeUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_settings_value_typeUpdatedBy] DEFAULT (''),
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_value_createdOn] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NOT NULL CONSTRAINT [DF_settings_value_updatedOn] DEFAULT (getdate()),
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_value] ADD CONSTRAINT [PK_settings_value] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settings_value] ADD CONSTRAINT [FK_settings_value] FOREIGN KEY ([ItemID]) REFERENCES [dbo].[settings_item] ([ID])
GO
GRANT DELETE ON  [dbo].[settings_value] TO [public]
GO
GRANT INSERT ON  [dbo].[settings_value] TO [public]
GO
GRANT SELECT ON  [dbo].[settings_value] TO [public]
GO
GRANT UPDATE ON  [dbo].[settings_value] TO [public]
GO
