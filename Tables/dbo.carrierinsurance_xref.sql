CREATE TABLE [dbo].[carrierinsurance_xref]
(
[caix_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_policynumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_insurance_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciax_source] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciax_determination] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierinsurance_xref] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierinsurance_xref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierinsurance_xref] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierinsurance_xref] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierinsurance_xref] TO [public]
GO
