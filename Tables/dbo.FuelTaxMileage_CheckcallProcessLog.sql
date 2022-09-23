CREATE TABLE [dbo].[FuelTaxMileage_CheckcallProcessLog]
(
[ckc_number] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelTaxMileage_CheckcallProcessLog] ADD CONSTRAINT [PK_ftc_ckc_number] PRIMARY KEY CLUSTERED ([ckc_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelTaxMileage_CheckcallProcessLog] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelTaxMileage_CheckcallProcessLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelTaxMileage_CheckcallProcessLog] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelTaxMileage_CheckcallProcessLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelTaxMileage_CheckcallProcessLog] TO [public]
GO
