CREATE TABLE [dbo].[FuelTaxMileage_ErrorCodes]
(
[ftc_errorcode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ftc_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelTaxMileage_ErrorCodes] ADD CONSTRAINT [PK_ftc_errorcode] PRIMARY KEY CLUSTERED ([ftc_errorcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelTaxMileage_ErrorCodes] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelTaxMileage_ErrorCodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[FuelTaxMileage_ErrorCodes] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelTaxMileage_ErrorCodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelTaxMileage_ErrorCodes] TO [public]
GO
