CREATE TABLE [dbo].[OTHERVEHICLEDAMAGE]
(
[OVD_ID] [int] NOT NULL IDENTITY(1, 1),
[srp_ID] [int] NOT NULL,
[ovd_Sequence] [tinyint] NOT NULL,
[ovd_DriverName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverCity] [int] NULL,
[ovd_DriverCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_DriverPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehicleType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehicleYear] [smallint] NULL,
[ovd_VehicleMake] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehicleModel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehicleVIN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehiclePUNbr] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehicleLicense] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_VehicleState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_Damage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_Value] [money] NULL,
[ovd_Comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_ActionTaken] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerIs] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerCompanyID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerAddress1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerAddress2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerCity] [int] NULL,
[ovd_OwnerCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OwnerPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCompany] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoCity] [int] NULL,
[ovd_InsCoCtynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoCountry] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_ReportedToInsurance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_InsCoReportDate] [datetime] NULL,
[ovd_claimnbr] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_CKBox1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_CKBox2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_CKBox3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_CKBox4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_CKBox5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_string1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_string2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_string3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_string4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_string5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_number1] [money] NULL,
[ovd_number2] [money] NULL,
[ovd_number3] [money] NULL,
[ovd_number4] [money] NULL,
[ovd_number5] [money] NULL,
[ovd_date1] [datetime] NULL,
[ovd_date2] [datetime] NULL,
[ovd_date3] [datetime] NULL,
[ovd_date4] [datetime] NULL,
[ovd_date5] [datetime] NULL,
[ovd_OVDamageType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OVDamageType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OVDamageType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ovd_OVDamageType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_OTHERVEHICLEDAMAGE_timestamp] ON [dbo].[OTHERVEHICLEDAMAGE] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_ovdID] ON [dbo].[OTHERVEHICLEDAMAGE] ([OVD_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_srpseq] ON [dbo].[OTHERVEHICLEDAMAGE] ([srp_ID], [ovd_Sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OTHERVEHICLEDAMAGE] TO [public]
GO
GRANT INSERT ON  [dbo].[OTHERVEHICLEDAMAGE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OTHERVEHICLEDAMAGE] TO [public]
GO
GRANT SELECT ON  [dbo].[OTHERVEHICLEDAMAGE] TO [public]
GO
GRANT UPDATE ON  [dbo].[OTHERVEHICLEDAMAGE] TO [public]
GO
