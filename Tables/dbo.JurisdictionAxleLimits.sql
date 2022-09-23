CREATE TABLE [dbo].[JurisdictionAxleLimits]
(
[jal_Identity] [int] NOT NULL IDENTITY(1, 1),
[jal_Jurisdiction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jal_RoadClass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jal_RoadClassRestriction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jal_AxleGroupType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jal_MaxAxleWeight] [int] NOT NULL CONSTRAINT [DF_jurisdictiongvwlimits_maxaxleweight] DEFAULT (65000)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JurisdictionAxleLimits] ADD CONSTRAINT [PK_JurisdictionAxleLimits] PRIMARY KEY CLUSTERED ([jal_Identity]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ui_JurisdictionAxleLimits] ON [dbo].[JurisdictionAxleLimits] ([jal_Jurisdiction], [jal_RoadClass], [jal_RoadClassRestriction], [jal_AxleGroupType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[JurisdictionAxleLimits] TO [public]
GO
GRANT INSERT ON  [dbo].[JurisdictionAxleLimits] TO [public]
GO
GRANT REFERENCES ON  [dbo].[JurisdictionAxleLimits] TO [public]
GO
GRANT SELECT ON  [dbo].[JurisdictionAxleLimits] TO [public]
GO
GRANT UPDATE ON  [dbo].[JurisdictionAxleLimits] TO [public]
GO
