CREATE TABLE [dbo].[tchmoneycode]
(
[tmc_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmc_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmc_sequencenumber] [int] NOT NULL IDENTITY(1, 1),
[tmc_available] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmc_amountfactor] [char] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_checkamount] [money] NULL,
[tmc_mcid] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_feecode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_issuedate] [datetime] NULL,
[tmc_issuedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_unitid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmc_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tchmoneycode] ADD CONSTRAINT [pk_tchmoneycode] PRIMARY KEY CLUSTERED ([tmc_sequencenumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tchmoneycode] TO [public]
GO
GRANT INSERT ON  [dbo].[tchmoneycode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tchmoneycode] TO [public]
GO
GRANT SELECT ON  [dbo].[tchmoneycode] TO [public]
GO
GRANT UPDATE ON  [dbo].[tchmoneycode] TO [public]
GO
