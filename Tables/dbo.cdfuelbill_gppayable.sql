CREATE TABLE [dbo].[cdfuelbill_gppayable]
(
[cfbgp_transdate] [datetime] NOT NULL CONSTRAINT [df_cdfuelbill_gppayable_cfbgp_transdate] DEFAULT ('19500101'),
[cfbgp_transnumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfbgp_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfbgp_unitnumber] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_truckstopinvoicenumber] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_totaldue] [money] NULL,
[cfbgp_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_employeenum] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_truckstopcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_truckstopname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_referencenumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_gl_number] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_transferred_togp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_directbill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfbgp_feefueloilproducts] [money] NULL,
[cfbgp_advancecharge] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill_gppayable] ADD CONSTRAINT [pk_cdfuelbillgppayable] PRIMARY KEY CLUSTERED ([cfbgp_accountid], [cfbgp_transnumber], [cfbgp_transdate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdfuelbill_gppayable] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill_gppayable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelbill_gppayable] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill_gppayable] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill_gppayable] TO [public]
GO
