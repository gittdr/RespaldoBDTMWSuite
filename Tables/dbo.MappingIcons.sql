CREATE TABLE [dbo].[MappingIcons]
(
[mi_Provider] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mi_Key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mi_Path] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mi_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mi_CreatedOn] [datetime] NOT NULL,
[mi_LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mi_LastUpdatedOn] [datetime] NULL,
[mi_Image] [image] NULL,
[mi_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MappingIcons] ADD CONSTRAINT [PK_[MappingIcons] PRIMARY KEY NONCLUSTERED ([mi_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MappingIcons] TO [public]
GO
GRANT INSERT ON  [dbo].[MappingIcons] TO [public]
GO
GRANT SELECT ON  [dbo].[MappingIcons] TO [public]
GO
GRANT UPDATE ON  [dbo].[MappingIcons] TO [public]
GO
