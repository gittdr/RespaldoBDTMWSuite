CREATE TABLE [dbo].[cdphonebill]
(
[cpb_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpb_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpb_cdninvoicenumber] [char] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_cdnitemnumber] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_phonecardnumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpb_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpb_asgnid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpb_calldate] [datetime] NOT NULL,
[cpb_phonenumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_callduration] [decimal] (8, 2) NULL,
[cpb_callrateperiod] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_basicusagecharge] [money] NULL,
[cpb_surchargeamount] [money] NULL,
[cpb_fedtax] [money] NULL,
[cpb_statetax] [money] NULL,
[cpb_totalcharge] [money] NULL,
[cpb_transtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_creditapplication] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_transdate] [datetime] NULL,
[cpb_callingcardtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpb_processstat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdphonebill] ADD CONSTRAINT [pk_cdphonebill] PRIMARY KEY CLUSTERED ([cpb_asgntype], [cpb_asgnid], [cpb_calldate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdphonebill] TO [public]
GO
GRANT INSERT ON  [dbo].[cdphonebill] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdphonebill] TO [public]
GO
GRANT SELECT ON  [dbo].[cdphonebill] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdphonebill] TO [public]
GO
