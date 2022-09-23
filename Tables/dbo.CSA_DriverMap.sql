CREATE TABLE [dbo].[CSA_DriverMap]
(
[drv_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drv_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drv_license] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drv_dob] [datetime] NULL
) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[CSA_DriverMap] TO [public]
GO
GRANT SELECT ON  [dbo].[CSA_DriverMap] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSA_DriverMap] TO [public]
GO
