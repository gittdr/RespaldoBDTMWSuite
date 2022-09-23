CREATE TABLE [dbo].[TMSTransitCalculationRule]
(
[TransitRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitCalculationRule] ADD CONSTRAINT [PK_TMSTransitCalculationRule] PRIMARY KEY CLUSTERED ([TransitRule]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSTransitCalculationRule] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitCalculationRule] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitCalculationRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitCalculationRule] TO [public]
GO
