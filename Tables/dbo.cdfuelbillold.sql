CREATE TABLE [dbo].[cdfuelbillold]
(
[cfb_accountid] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_customerid] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_transdate] [datetime] NOT NULL,
[cfb_transnumber] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_unitnumber] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_truckstopcode] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopinvoicenumber] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_totaldue] [money] NULL,
[cfb_feefueloilproducts] [money] NULL,
[cfb_trcgallons] [float] NULL,
[cfb_trccostpergallon] [money] NULL,
[cfb_trccost] [money] NULL,
[cfb_reefergallons] [float] NULL,
[cfb_reefercostpergallon] [money] NULL,
[cfb_reefercost] [money] NULL,
[cfb_oilquarts] [int] NULL,
[cfb_oilcost] [money] NULL,
[cfb_advanceamt] [money] NULL,
[cfb_advancecharge] [money] NULL,
[cfb_tripnumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_cardnumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_employeenum] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_rebateamount] [money] NULL,
[cfb_focusorselect] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopname] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopcityname] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopstate] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_currencytype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_nonbillableitem] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_productamt1] [money] NULL,
[cfb_productamt2] [money] NULL,
[cfb_productamt3] [money] NULL,
[cfb_trailernumber] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_rebateamt] [money] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdfuelbillold] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbillold] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelbillold] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbillold] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbillold] TO [public]
GO
