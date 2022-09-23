CREATE TABLE [dbo].[TMSCommodityWarehouse]
(
[CmdWhId] [int] NOT NULL IDENTITY(1, 1),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSCommodityWarehouse] ADD CONSTRAINT [PK_TMSCommodityWarehouse] PRIMARY KEY CLUSTERED ([CmdWhId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSCommodityWarehouse] ADD CONSTRAINT [FK_TMSCommodityWarehouse_commodity] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
ALTER TABLE [dbo].[TMSCommodityWarehouse] ADD CONSTRAINT [FK_TMSCommodityWarehouse_company] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[TMSCommodityWarehouse] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSCommodityWarehouse] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSCommodityWarehouse] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSCommodityWarehouse] TO [public]
GO
