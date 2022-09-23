CREATE TABLE [dbo].[FuelChargeTypes]
(
[Cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FuelChargeTypes_timestamp] ON [dbo].[FuelChargeTypes] ([dw_timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelChargeTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelChargeTypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelChargeTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelChargeTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelChargeTypes] TO [public]
GO
