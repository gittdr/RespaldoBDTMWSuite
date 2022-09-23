CREATE TABLE [dbo].[TotalMailDriverEmergencyAlerts]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[Stp_Number] [int] NULL,
[FriendlyMessage] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalMailSentDate] [datetime] NOT NULL,
[drv_emergency_alert_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TotalMailDriverEmergencyAlerts] ADD CONSTRAINT [PK_TotalMailDriverEmergencyAlerts] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TotalMailDriverEmergencyAlerts] TO [public]
GO
GRANT INSERT ON  [dbo].[TotalMailDriverEmergencyAlerts] TO [public]
GO
GRANT SELECT ON  [dbo].[TotalMailDriverEmergencyAlerts] TO [public]
GO
GRANT UPDATE ON  [dbo].[TotalMailDriverEmergencyAlerts] TO [public]
GO
