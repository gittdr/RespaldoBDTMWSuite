CREATE TABLE [dbo].[can_capacity]
(
[cap_transactionid] [int] NOT NULL,
[car_carrierid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[all_allianceid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_contactid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_contact] [char] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_postdate] [datetime] NULL,
[cap_expiredate] [datetime] NULL,
[cap_availabledate] [datetime] NULL,
[cap_availablecity] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_availablestate] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_prefdestcity] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_prefstate] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_comments] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_equipmenttype] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_acceptedby] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_feet] [int] NULL,
[cap_weight] [decimal] (10, 4) NULL,
[cap_weightunits] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_volumn] [decimal] (10, 4) NULL,
[cap_volumnunits] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_unitnumber] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_restrictto1] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_restrictto2] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_restrictto3] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cap_restrictto4] [char] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_capacity] ADD CONSTRAINT [pk_can_capacity] PRIMARY KEY NONCLUSTERED ([cap_transactionid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_capacity] TO [public]
GO
GRANT INSERT ON  [dbo].[can_capacity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_capacity] TO [public]
GO
GRANT SELECT ON  [dbo].[can_capacity] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_capacity] TO [public]
GO
