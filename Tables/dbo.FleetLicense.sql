CREATE TABLE [dbo].[FleetLicense]
(
[fl_FleetID] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fl_Jurisdiction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fl_ExpirationDate] [datetime] NOT NULL CONSTRAINT [DF_fleetlicense_expirationdate] DEFAULT ('20491231 23:59'),
[fl_MaxGVW] [int] NOT NULL CONSTRAINT [DF_fleetlicense_maxgvw] DEFAULT (65000),
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fleetlicense_trc_number] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FleetLicense] ADD CONSTRAINT [PK_FleetLicense] PRIMARY KEY CLUSTERED ([fl_FleetID], [trc_number], [fl_Jurisdiction], [fl_ExpirationDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FleetLicense] TO [public]
GO
GRANT INSERT ON  [dbo].[FleetLicense] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FleetLicense] TO [public]
GO
GRANT SELECT ON  [dbo].[FleetLicense] TO [public]
GO
GRANT UPDATE ON  [dbo].[FleetLicense] TO [public]
GO
