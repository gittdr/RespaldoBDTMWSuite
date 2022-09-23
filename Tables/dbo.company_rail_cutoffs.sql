CREATE TABLE [dbo].[company_rail_cutoffs]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crc_cutoff_time] [datetime] NOT NULL,
[crc_cutoff_day] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crc_equipmconfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[crc_destination_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_rail_cutoffs] ADD CONSTRAINT [pk_company_rail_cutoffs] PRIMARY KEY CLUSTERED ([cmp_id], [crc_cutoff_time], [crc_equipmconfiguration], [crc_cutoff_day], [crc_destination_city]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_rail_cutoffs] TO [public]
GO
GRANT INSERT ON  [dbo].[company_rail_cutoffs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_rail_cutoffs] TO [public]
GO
GRANT SELECT ON  [dbo].[company_rail_cutoffs] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_rail_cutoffs] TO [public]
GO
