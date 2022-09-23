CREATE TABLE [dbo].[TMSOrderLineItems]
(
[LineItemId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NULL,
[LineNumber] [smallint] NOT NULL,
[PartNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuanityToShip] [decimal] (12, 4) NULL,
[Quantity1] [decimal] (12, 4) NULL,
[Quantity2] [decimal] (12, 4) NULL,
[Quantity3] [decimal] (12, 4) NULL,
[SKU] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FreightClass] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineItemType5] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Remark] [varchar] (999) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Items] [decimal] (12, 4) NULL,
[Cases] [decimal] (12, 4) NULL,
[Pallets] [decimal] (12, 4) NULL,
[QuanityToShipUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_number_pickup] [int] NULL,
[fgt_number_drop] [int] NULL,
[PickupLocationId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryLocationId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderLineItems] ADD CONSTRAINT [PK_TMSOrderLineItems] PRIMARY KEY CLUSTERED ([LineItemId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DX_TMSOrderLineItems_fgt_number_drop] ON [dbo].[TMSOrderLineItems] ([fgt_number_drop]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DX_TMSOrderLineItems_fgt_number_pickup] ON [dbo].[TMSOrderLineItems] ([fgt_number_pickup]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderLineItems] ADD CONSTRAINT [FK_TMSOrderLineItems_Company_Delivery] FOREIGN KEY ([DeliveryLocationId]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSOrderLineItems] ADD CONSTRAINT [FK_TMSOrderLineItems_Company_Pickup] FOREIGN KEY ([PickupLocationId]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSOrderLineItems] ADD CONSTRAINT [FK_TMSOrderLineItems_OrderheaderDEL] FOREIGN KEY ([ord_hdrnumber]) REFERENCES [dbo].[orderheader] ([ord_hdrnumber]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TMSOrderLineItems] ADD CONSTRAINT [FK_TMSOrderLineItems_TMSOrderNull] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderLineItems] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderLineItems] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderLineItems] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderLineItems] TO [public]
GO
