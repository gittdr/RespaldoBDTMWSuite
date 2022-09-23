CREATE TABLE [dbo].[tblMIVDNotifications]
(
[NotificationID] [int] NOT NULL IDENTITY(1, 1),
[lgh_Number] [int] NOT NULL,
[DriverID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_checkcall_processed] [int] NOT NULL,
[last_airmiles_calculated] [float] NOT NULL,
[MsgSent_counter] [int] NULL CONSTRAINT [DF_tblMIVDNotifications_MsgSent_counter] DEFAULT ((0)),
[NotificationSent_TimeStamp] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMIVDNotifications] ADD CONSTRAINT [PK_tblMIVDNotifications] PRIMARY KEY CLUSTERED ([NotificationID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMIVDNotifications] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMIVDNotifications] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMIVDNotifications] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMIVDNotifications] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMIVDNotifications] TO [public]
GO
