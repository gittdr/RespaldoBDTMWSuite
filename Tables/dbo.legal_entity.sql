CREATE TABLE [dbo].[legal_entity]
(
[le_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_le_id] DEFAULT ('UNK'),
[le_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_city] [int] NULL,
[le_cty_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_primaryphone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_secondaryphone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_faxphone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_po_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_po_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_po_city] [int] NULL,
[le_po_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_po_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_po_cty_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_misc1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_misc2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_misc3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_misc4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_billinginfo] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_po_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_taxid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_CURRENCY] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_bank_account] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_code] [int] NOT NULL IDENTITY(10, 10),
[le_shortname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_invoicenumber] [int] NULL,
[le_arserver] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_ardb] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_salesserver] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_salesdb] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_apserver] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_apdb] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_prserver] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_prdb] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[le_reverseARfromAP] [int] NOT NULL CONSTRAINT [DF__legal_ent__le_re__1A10831F] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legal_entity] ADD CONSTRAINT [pk_leid] PRIMARY KEY NONCLUSTERED ([le_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legal_entity] TO [public]
GO
GRANT INSERT ON  [dbo].[legal_entity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legal_entity] TO [public]
GO
GRANT SELECT ON  [dbo].[legal_entity] TO [public]
GO
GRANT UPDATE ON  [dbo].[legal_entity] TO [public]
GO
