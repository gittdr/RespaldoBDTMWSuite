CREATE TABLE [dbo].[gpdefaults]
(
[DBname] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Server_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Copy_currency] [int] NULL,
[Pay_details_to_distributions] [int] NULL,
[Roll_up_distributions] [int] NULL,
[Transfer_MB_only] [int] NULL,
[Export_to_multicompany] [int] NULL,
[Rev2_to_sales] [int] NULL,
[Invoice_details_to_distributions] [int] NULL,
[Rev1_to_territory] [int] NULL,
[Primary_from_billto] [int] NULL,
[primary_from_payto] [int] NULL,
[UserId] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_default] [int] NULL,
[pay_to_class] [int] NULL,
[inv_transfer] [int] NULL,
[stl_transfer] [int] NULL,
[docdate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__docda__1F997E18] DEFAULT ('Bill Date'),
[postdate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__postd__208DA251] DEFAULT ('Bill Date'),
[edi_820] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[miles_to_unit] [int] NULL,
[id] [int] NULL,
[altid] [int] NULL,
[payroll_distributions] [int] NULL,
[payables_distributions] [int] NULL,
[receivables_distributions] [int] NULL,
[glonly_pr] [int] NULL,
[department] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__depar__4C220BCC] DEFAULT (''),
[position] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__posit__4D163005] DEFAULT (''),
[gpd_retrievebydate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_copy_credit_terms] [int] NULL,
[gp_accrue_comp] [int] NULL,
[GP_accrue_ded] [int] NULL,
[gp_accrue_reimb] [int] NULL,
[gp_accrue_pretaxded] [int] NULL,
[gp_salesmanfrom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_territoryfrom] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_ap_docnumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__gp_ap__7BF3E018] DEFAULT ('UNK'),
[gp_ap_docdescription] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__gp_ap__7CE80451] DEFAULT ('UNK'),
[gp_ap_docdate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__gp_ap__7DDC288A] DEFAULT ('UNK'),
[gp_ap_postingdate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__gp_ap__7ED04CC3] DEFAULT ('UNK'),
[gp_ap_ponumber] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__gpdefault__gp_ap__7FC470FC] DEFAULT ('UNK'),
[gpdefaults_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gpdefaults] ADD CONSTRAINT [prkey_gpdefaults] PRIMARY KEY CLUSTERED ([gpdefaults_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gpdefaults] TO [public]
GO
GRANT INSERT ON  [dbo].[gpdefaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gpdefaults] TO [public]
GO
GRANT SELECT ON  [dbo].[gpdefaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[gpdefaults] TO [public]
GO
