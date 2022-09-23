CREATE TABLE [dbo].[TMSGeographyType]
(
[GeographyType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSGeographyType] ADD CONSTRAINT [PK_TMSGeographyType] PRIMARY KEY CLUSTERED ([GeographyType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSGeographyType] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSGeographyType] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSGeographyType] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSGeographyType] TO [public]
GO
