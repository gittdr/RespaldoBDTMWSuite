CREATE TABLE [dbo].[JurisdictionGVWLimits]
(
[jgl_Identity] [int] NOT NULL IDENTITY(1, 1),
[jgl_Jurisdiction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jgl_RoadClass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jgl_TrailerConfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jgl_MaxGVW] [int] NOT NULL CONSTRAINT [DF_jurisdictiongvwlimits_maxgvw] DEFAULT (65000),
[jgl_Season] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JurisdictionGVWLimits] ADD CONSTRAINT [PK_JurisdictionGVWLimits] PRIMARY KEY CLUSTERED ([jgl_Identity]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_JurisdictionGVWLimits] ON [dbo].[JurisdictionGVWLimits] ([jgl_Jurisdiction], [jgl_RoadClass], [jgl_TrailerConfiguration]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[JurisdictionGVWLimits] TO [public]
GO
GRANT INSERT ON  [dbo].[JurisdictionGVWLimits] TO [public]
GO
GRANT REFERENCES ON  [dbo].[JurisdictionGVWLimits] TO [public]
GO
GRANT SELECT ON  [dbo].[JurisdictionGVWLimits] TO [public]
GO
GRANT UPDATE ON  [dbo].[JurisdictionGVWLimits] TO [public]
GO
