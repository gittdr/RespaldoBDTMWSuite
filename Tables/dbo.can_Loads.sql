CREATE TABLE [dbo].[can_Loads]
(
[ld_transactionnum] [int] NOT NULL,
[car_carrierid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[all_allianceid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_contactid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_contact] [char] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_postdate] [datetime] NULL,
[ld_expiredate] [datetime] NULL,
[ld_shipdate] [datetime] NULL,
[ld_deliverydate] [datetime] NULL,
[ld_origincity] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_originstate] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_originname] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_destcity] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_deststate] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_destname] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_comments] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_equipmenttype] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_product] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_weight] [decimal] (10, 4) NULL,
[ld_weightunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_volumn] [decimal] (10, 4) NULL,
[ld_volumnunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_count] [int] NULL,
[ld_countunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_linehaulcharges] [money] NULL,
[ld_currency] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_acceptedby] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_feet] [int] NULL,
[ld_ordernumber] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_referencetype] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_referencenumber] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_restrictto1] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_restrictto2] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_restrictto3] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_restrictto4] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_awarded_dt] [datetime] NULL,
[ld_nlm_critical] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_network] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_shipment_number] [int] NULL,
[nlm_accid] [int] NULL,
[ld_miles] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ld_origzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ld_destzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[all_alliancesn] [int] NULL,
[nlm_required_vehicle] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_acc_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_first_right_refusal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_Loads] ADD CONSTRAINT [pk_can_loads] PRIMARY KEY NONCLUSTERED ([ld_transactionnum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_can_carrier_ord] ON [dbo].[can_Loads] ([car_carrierid], [ld_ordernumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_Loads] TO [public]
GO
GRANT INSERT ON  [dbo].[can_Loads] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_Loads] TO [public]
GO
GRANT SELECT ON  [dbo].[can_Loads] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_Loads] TO [public]
GO
