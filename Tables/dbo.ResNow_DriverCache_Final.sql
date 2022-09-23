CREATE TABLE [dbo].[ResNow_DriverCache_Final]
(
[driver_key] [int] NOT NULL IDENTITY(1, 1),
[driver_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_directoryname] [varchar] (84) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_type1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_type2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_type3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_type4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_company] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_division] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_terminal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_fleet] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_branch] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_domicile] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_teamleader] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_servicerule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_address1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_address2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_city] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_county] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_country] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_lastname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_firstname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_middlename] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_dateofbirth] [datetime] NULL,
[driver_hiredate] [datetime] NULL,
[driver_senioritydate] [datetime] NULL,
[driver_licensestate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_licenseclass] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_licensenumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driver_terminationdate] [datetime] NULL,
[driver_DateStart] [datetime] NULL,
[driver_DateEnd] [datetime] NULL,
[driver_active] [bit] NOT NULL CONSTRAINT [DF__ResNow_Dr__drive__12C9F673] DEFAULT ((1)),
[driver_Updated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_DriverCache_Final] ADD CONSTRAINT [AutoPK_ResNow_DriverCache_Final_driver_key] PRIMARY KEY CLUSTERED ([driver_key]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNow_DriverCache_Final_driver_DateStart] ON [dbo].[ResNow_DriverCache_Final] ([driver_DateStart]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNow_DriverCache_Final_driver_id] ON [dbo].[ResNow_DriverCache_Final] ([driver_id], [driver_DateStart], [driver_DateEnd]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_DriverCache_Final] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_DriverCache_Final] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_DriverCache_Final] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_DriverCache_Final] TO [public]
GO
