CREATE TABLE [dbo].[cdexpresscheck]
(
[ceh_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_sequencenumber] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_available] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_amountfactor] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_checkamount] [money] NULL,
[ceh_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_feetype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_issuedate] [datetime] NULL,
[ceh_issuedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_registered] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_ceh_registered] DEFAULT ('R'),
[ceh_registeredtotalamount] [money] NULL,
[ceh_transcharges] [money] NULL,
[ceh_transplflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_transinvamount] [money] NULL,
[ceh_transdate] [datetime] NULL,
[ceh_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_refnum] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceh_productcode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_reportcode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_processeddate] [datetime] NULL,
[ceh_effectivedate] [datetime] NULL,
[ceh_servicecentercode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_servicecentername] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_invoiceitemnumber] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_servicecentercity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_servicecenterstate] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_commissionfee] [money] NULL,
[ceh_purposecode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_fleetcode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_netamtsign] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceh_customernumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdexpresscheck] ADD CONSTRAINT [pk_cdexpresscheck] PRIMARY KEY CLUSTERED ([ceh_accountid], [ceh_customerid], [ceh_sequencenumber], [ceh_refnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cdexpresscheck_idseqreg] ON [dbo].[cdexpresscheck] ([ceh_customerid], [ceh_sequencenumber], [ceh_registered]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdexpresscheck] ADD CONSTRAINT [fk_cdexpresschecktocdacctcode] FOREIGN KEY ([ceh_accountid]) REFERENCES [dbo].[cdacctcode] ([cac_id])
GO
ALTER TABLE [dbo].[cdexpresscheck] ADD CONSTRAINT [fk_cdexpresschecktocdcustcode] FOREIGN KEY ([ceh_accountid], [ceh_customerid]) REFERENCES [dbo].[cdcustcode] ([cac_id], [ccc_id])
GO
GRANT DELETE ON  [dbo].[cdexpresscheck] TO [public]
GO
GRANT INSERT ON  [dbo].[cdexpresscheck] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdexpresscheck] TO [public]
GO
GRANT SELECT ON  [dbo].[cdexpresscheck] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdexpresscheck] TO [public]
GO
