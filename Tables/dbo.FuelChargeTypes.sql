CREATE TABLE [dbo].[FuelChargeTypes]
(
[Cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__FuelCharg__INS_T__51A4D14A] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FuelChargeTypes_timestamp] ON [dbo].[FuelChargeTypes] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FuelChargeTypes_INS_TIMESTAMP] ON [dbo].[FuelChargeTypes] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
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
