CREATE TABLE [dbo].[invoiceheaderltlinfo]
(
[ivh_hdrnumber] [int] NOT NULL,
[shipper_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipper_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickup_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_address1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_address2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[consignee_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_client] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_client_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svclevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[intermodal] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hazmat] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[temperature_control] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL,
[pro_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[invoiceheaderltlinfo] ADD CONSTRAINT [PK__invoiceh__BABBB69D7AA99C7A] PRIMARY KEY CLUSTERED ([ivh_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoiceheaderltlinfo] TO [public]
GO
GRANT INSERT ON  [dbo].[invoiceheaderltlinfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoiceheaderltlinfo] TO [public]
GO
GRANT SELECT ON  [dbo].[invoiceheaderltlinfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoiceheaderltlinfo] TO [public]
GO
