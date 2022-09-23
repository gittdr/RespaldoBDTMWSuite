CREATE TABLE [dbo].[TMSDefaultWarehouse]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[BillToId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConsigneeId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommodityId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssignedWarehouseId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MfgLocationId] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedOn] [datetime] NULL,
[PriceList] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSDefaultWarehouse] ADD CONSTRAINT [PK_TMSDefaultWarehouse] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_BillTo_Consignee_Commodity] ON [dbo].[TMSDefaultWarehouse] ([BillToId], [ConsigneeId], [CommodityId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSDefaultWarehouse] ADD CONSTRAINT [FK_TMSDefaultWarehouse_assignedwarehouseid] FOREIGN KEY ([AssignedWarehouseId]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSDefaultWarehouse] ADD CONSTRAINT [FK_TMSDefaultWarehouse_billtoid] FOREIGN KEY ([BillToId]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSDefaultWarehouse] ADD CONSTRAINT [FK_TMSDefaultWarehouse_commodityid] FOREIGN KEY ([CommodityId]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
ALTER TABLE [dbo].[TMSDefaultWarehouse] ADD CONSTRAINT [FK_TMSDefaultWarehouse_consigneeid] FOREIGN KEY ([ConsigneeId]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TMSDefaultWarehouse] ADD CONSTRAINT [FK_TMSDefaultWarehouse_mfglocationid] FOREIGN KEY ([MfgLocationId]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[TMSDefaultWarehouse] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSDefaultWarehouse] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSDefaultWarehouse] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSDefaultWarehouse] TO [public]
GO
