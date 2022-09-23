CREATE TABLE [dbo].[core_PostalCodePatternExpansion]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PostalCodePattern] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PostalCodePart] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_PostalCodePatternExpansion] ADD CONSTRAINT [PK_core_PostalCodePatternExpansion] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_PostalCodePatternExpansion] ADD CONSTRAINT [AK_core_PostalCodePatternExpansion] UNIQUE NONCLUSTERED ([PostalCodePattern], [PostalCodePart]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_PostalCodePatternExpansion] TO [public]
GO
GRANT INSERT ON  [dbo].[core_PostalCodePatternExpansion] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_PostalCodePatternExpansion] TO [public]
GO
GRANT SELECT ON  [dbo].[core_PostalCodePatternExpansion] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_PostalCodePatternExpansion] TO [public]
GO
