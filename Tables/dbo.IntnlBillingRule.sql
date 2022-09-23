CREATE TABLE [dbo].[IntnlBillingRule]
(
[ibr_ident] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ibr_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ibr_Direction] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ibr_DistanceRule] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ibr_ShowStopsRule] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntnlBillingRule] ADD CONSTRAINT [PK_intnlrules] PRIMARY KEY CLUSTERED ([ibr_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IBRCompanyCountry] ON [dbo].[IntnlBillingRule] ([cmp_id], [ibr_Country]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IntnlBillingRule] TO [public]
GO
GRANT INSERT ON  [dbo].[IntnlBillingRule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IntnlBillingRule] TO [public]
GO
GRANT SELECT ON  [dbo].[IntnlBillingRule] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntnlBillingRule] TO [public]
GO
