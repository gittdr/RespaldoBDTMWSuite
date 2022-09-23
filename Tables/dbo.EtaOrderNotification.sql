CREATE TABLE [dbo].[EtaOrderNotification]
(
[EtaOrderNotificationID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderNumber] [int] NOT NULL,
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception] [bit] NULL,
[Delivery] [bit] NULL,
[CreatedDate] [datetime] NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EtaOrderNotification] ADD CONSTRAINT [PK_EtaOrderNotification] PRIMARY KEY CLUSTERED ([EtaOrderNotificationID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EtaOrderNotification] ADD CONSTRAINT [EtaOrderNotification_OrderNumber_Email] UNIQUE NONCLUSTERED ([OrderNumber], [Email]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EtaOrderNotification] TO [public]
GO
GRANT INSERT ON  [dbo].[EtaOrderNotification] TO [public]
GO
GRANT SELECT ON  [dbo].[EtaOrderNotification] TO [public]
GO
GRANT UPDATE ON  [dbo].[EtaOrderNotification] TO [public]
GO
