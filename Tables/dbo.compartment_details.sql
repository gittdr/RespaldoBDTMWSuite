CREATE TABLE [dbo].[compartment_details]
(
[comp_trl_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comp_eventcode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[compartment] [int] NOT NULL,
[comp_fgt_number] [int] NOT NULL,
[comp_innage_outage] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comp_load_amt] [float] NOT NULL,
[comp_load_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comp_commodity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comp_measure_inches] [int] NULL,
[comp_ordhdrnumber] [int] NULL,
[comp_stp_number] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [comp_ind] ON [dbo].[compartment_details] ([comp_trl_id], [comp_eventcode], [compartment], [comp_fgt_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[compartment_details] TO [public]
GO
GRANT INSERT ON  [dbo].[compartment_details] TO [public]
GO
GRANT REFERENCES ON  [dbo].[compartment_details] TO [public]
GO
GRANT SELECT ON  [dbo].[compartment_details] TO [public]
GO
GRANT UPDATE ON  [dbo].[compartment_details] TO [public]
GO
