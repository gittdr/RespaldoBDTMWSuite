CREATE TABLE [dbo].[cdfuelbill]
(
[cfb_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_transdate] [datetime] NOT NULL,
[cfb_transnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_employeenum] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_unitnumber] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfb_trchubmiles] [int] NULL,
[cfb_trailernumber] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_tripnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_totaldue] [money] NULL,
[cfb_feefueloilproducts] [money] NULL,
[cfb_trcgallons] [decimal] (9, 2) NULL,
[cfb_trccostpergallon] [money] NULL,
[cfb_trccost] [money] NULL,
[cfb_reefergallons] [decimal] (9, 2) NULL,
[cfb_reefercostpergallon] [money] NULL,
[cfb_reefercost] [money] NULL,
[cfb_oilquarts] [int] NULL,
[cfb_oilcost] [money] NULL,
[cfb_advanceamt] [money] NULL,
[cfb_advancecharge] [money] NULL,
[cfb_productcode1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_productamt1] [money] NULL,
[cfb_productcode2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_productamt2] [money] NULL,
[cfb_productcode3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_productamt3] [money] NULL,
[cfb_productcode4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_productamount4] [money] NULL,
[cfb_tax1] [money] NULL,
[cfb_tax2] [money] NULL,
[cfb_tax3] [money] NULL,
[cfb_tax4] [money] NULL,
[cfb_rebateamount] [money] NULL,
[cfb_rebateamt] [money] NULL,
[cfb_truckstopinvoicenumber] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopcityname] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_truckstopstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_focusorselect] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_network_ts] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_directbill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_currencytype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_nonbillableitem] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_gp_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_cfb_gp_payto] DEFAULT ('UNKNOWN'),
[cfb_gp_payto_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_cfb_gp_payto_indicator] DEFAULT ('P'),
[cfb_gp_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_gp_glnumber] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_gp_suspense_glnumber] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_plusless] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_referencenumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_checknumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_transferred_to_gp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdfuelbill_cfb_transferred_to_gp] DEFAULT ('N'),
[cfb_error] [char] (1023) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_updateddate] [datetime] NULL,
[cfb_export_to_tmt] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cfb_export_to_tmt] DEFAULT ('N'),
[cfb_reeferfuelcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_tractorfuelcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_dieselnbr1fuelcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_otherfuelcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_otherfuelcost] [money] NULL,
[cfb_dieselnbr1fuelcost] [money] NULL,
[cfb_dieselnbr1gallons] [decimal] (9, 3) NULL,
[cfb_dieselnbr1costpergallon] [money] NULL,
[cfb_otherfuelgallons] [decimal] (9, 3) NULL,
[cfb_otherfuelcostpergallon] [money] NULL,
[cfb_advanceamt2] [money] NULL,
[cfb_prevhubmiles] [int] NULL,
[cfb_fuelbillingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_cashbillingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_product1billingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_product2billingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_product3billingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_ServiceCenterChain] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_xfacetype] [int] NULL,
[cfb_shortname] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_fuelprocessed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_payprocessed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_oilbillingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_reeferbillingflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_fuel_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_pay_processed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_add_props] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_policy_number] [int] NULL,
[cfb_approcessed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_cancel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_authnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_reefauthgallons] [decimal] (9, 2) NULL,
[cfb_reefauthcostpergallon] [money] NULL,
[cfb_reefauthcost] [money] NULL,
[cfb_reefauthfuelcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_reefauthaction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_tax5] [money] NULL,
[cfb_tax6] [money] NULL,
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_otherfuelprocessed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_rfid_trans] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfb_drv_pin] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__cdfuelbil__INS_T__39CD47B9] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_cdfuelbill] ON [dbo].[cdfuelbill] 
FOR INSERT  as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

UPDATE tractorprofile 
   SET trc_currenthub = cfb_trchubmiles 
  FROM inserted 
 WHERE cfb_unitnumber = trc_number AND
       (cfb_trchubmiles > trc_currenthub OR
        trc_currenthub IS NULL)
GO
ALTER TABLE [dbo].[cdfuelbill] ADD CONSTRAINT [pk_cdfuelbill] PRIMARY KEY CLUSTERED ([cfb_accountid], [cfb_customerid], [cfb_transdate], [cfb_transnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_cdfuelbill_transdate] ON [dbo].[cdfuelbill] ([cfb_transdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_cdfuelbill_transnumber] ON [dbo].[cdfuelbill] ([cfb_transnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CDFuelbill_timestamp] ON [dbo].[cdfuelbill] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cdfuelbill_INS_TIMESTAMP] ON [dbo].[cdfuelbill] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdfuelbill] ADD CONSTRAINT [fk_cdfuelbilltocashcard] FOREIGN KEY ([cfb_cardnumber], [cfb_accountid], [cfb_customerid]) REFERENCES [dbo].[cashcard] ([crd_cardnumber], [crd_accountid], [crd_customerid])
GO
ALTER TABLE [dbo].[cdfuelbill] ADD CONSTRAINT [fk_cdfuelbilltocdacctcode] FOREIGN KEY ([cfb_accountid]) REFERENCES [dbo].[cdacctcode] ([cac_id])
GO
ALTER TABLE [dbo].[cdfuelbill] ADD CONSTRAINT [fk_cdfuelbilltocdcustcode] FOREIGN KEY ([cfb_accountid], [cfb_customerid]) REFERENCES [dbo].[cdcustcode] ([cac_id], [ccc_id])
GO
ALTER TABLE [dbo].[cdfuelbill] ADD CONSTRAINT [fk_cdfuelbilltotruckstops] FOREIGN KEY ([cfb_truckstopcode]) REFERENCES [dbo].[truckstops] ([ts_code])
GO
GRANT DELETE ON  [dbo].[cdfuelbill] TO [public]
GO
GRANT INSERT ON  [dbo].[cdfuelbill] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdfuelbill] TO [public]
GO
GRANT SELECT ON  [dbo].[cdfuelbill] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdfuelbill] TO [public]
GO
