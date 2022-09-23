CREATE TABLE [dbo].[MobileCommMessageDefinition]
(
[MessageDefinitionId] [int] NOT NULL IDENTITY(1, 1),
[ExternalId] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageDefinition] ADD CONSTRAINT [PK_MobileCommMessageDefinition] PRIMARY KEY CLUSTERED ([MessageDefinitionId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_dbo_MobileCommMessageDefinition_ExternalId] ON [dbo].[MobileCommMessageDefinition] ([ExternalId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ux_dbo_MobileCommMessageDefinition_Name] ON [dbo].[MobileCommMessageDefinition] ([Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommMessageDefinition] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageDefinition] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageDefinition] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageDefinition] TO [public]
GO
