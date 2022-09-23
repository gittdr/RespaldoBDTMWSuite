CREATE TABLE [dbo].[DriverEmergencyAlerts]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Cty_code] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AlertArea_latitude] [decimal] (12, 4) NULL,
[AlertArea_longitude] [decimal] (12, 4) NULL,
[FriendlyMessage] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AlertRadius] [int] NOT NULL,
[AlertActiveFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[ExpirationDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverEmergencyAlerts] ADD CONSTRAINT [PK_DriverEmergencyAlerts] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverEmergencyAlerts] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverEmergencyAlerts] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverEmergencyAlerts] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverEmergencyAlerts] TO [public]
GO
