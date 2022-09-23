CREATE TABLE [dbo].[edi_nonbillable_status_events]
(
[nse_id] [int] NOT NULL IDENTITY(1, 1),
[evt_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nse_arv_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nse_dep_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_nonbillable_status_events] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_nonbillable_status_events] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_nonbillable_status_events] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_nonbillable_status_events] TO [public]
GO
