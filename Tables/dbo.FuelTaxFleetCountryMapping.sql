CREATE TABLE [dbo].[FuelTaxFleetCountryMapping]
(
[fleet] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[country] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelTaxFleetCountryMapping] ADD CONSTRAINT [PK_FuelTaxFleetCountryMapping] PRIMARY KEY CLUSTERED ([fleet]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelTaxFleetCountryMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelTaxFleetCountryMapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelTaxFleetCountryMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelTaxFleetCountryMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelTaxFleetCountryMapping] TO [public]
GO
