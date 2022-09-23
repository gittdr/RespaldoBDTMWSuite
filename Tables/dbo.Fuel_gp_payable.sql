CREATE TABLE [dbo].[Fuel_gp_payable]
(
[fgp_shortname] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_vendor] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_docnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_currency] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_transdate] [datetime] NOT NULL,
[fgp_transnumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_creditaccount] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_debitaccount] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgp_amount] [decimal] (9, 4) NOT NULL,
[fgp_sequence] [int] NOT NULL,
[fgp_gpdatabase] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_gpserver] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_trccompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_ordcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_trcompanydb] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_trcompanyserver] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_creditaccountar] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_debitaccountar] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_taxamount] [decimal] (9, 4) NULL,
[fgp_gpARtransnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_gpAPtransnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_gpGltransnumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_artaxgl] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_aptaxgl] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_truckstopcompnay] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_truckstopaccount] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_alternatecredit] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgp_usealtcredit] [int] NULL,
[fgp_GP_doc_number] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Fuel_gp_payable] ADD CONSTRAINT [PK_transnumber_date_vendor] PRIMARY KEY CLUSTERED ([fgp_shortname], [fgp_vendor], [fgp_docnumber], [fgp_currency], [fgp_transdate], [fgp_transnumber], [fgp_creditaccount], [fgp_debitaccount], [fgp_amount], [fgp_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_transnumber] ON [dbo].[Fuel_gp_payable] ([fgp_transnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Fuel_gp_payable] TO [public]
GO
GRANT INSERT ON  [dbo].[Fuel_gp_payable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Fuel_gp_payable] TO [public]
GO
GRANT SELECT ON  [dbo].[Fuel_gp_payable] TO [public]
GO
GRANT UPDATE ON  [dbo].[Fuel_gp_payable] TO [public]
GO
