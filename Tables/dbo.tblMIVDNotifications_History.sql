CREATE TABLE [dbo].[tblMIVDNotifications_History]
(
[NotificationHistoryID] [bigint] NOT NULL IDENTITY(1, 1),
[NotificationID] [int] NOT NULL,
[lgh_Number] [int] NOT NULL,
[DriverID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_checkcall_processed] [int] NULL,
[last_airmiles_calculated] [float] NULL,
[MsgSent_counter] [int] NULL,
[NotificationSent_TimeStamp] [datetime] NULL,
[Resolution_TimeStamp] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMIVDNotifications_History] ADD CONSTRAINT [PK_tblMIVDNotifications_History] PRIMARY KEY CLUSTERED ([NotificationHistoryID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMIVDNotifications_History] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMIVDNotifications_History] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMIVDNotifications_History] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMIVDNotifications_History] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMIVDNotifications_History] TO [public]
GO
