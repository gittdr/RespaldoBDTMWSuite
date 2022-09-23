CREATE TABLE [dbo].[EtaCompanyNotification]
(
[EtaCompanyNotificationID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CompanyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception] [bit] NULL,
[Delivery] [bit] NULL,
[CreatedDate] [datetime] NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EtaCompanyNotification] ADD CONSTRAINT [PK_EtaCompanyNotification] PRIMARY KEY CLUSTERED ([EtaCompanyNotificationID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EtaCompanyNotification] ADD CONSTRAINT [EtaCompanyNotification_OrderNumber_Email] UNIQUE NONCLUSTERED ([CompanyID], [Email]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EtaCompanyNotification] TO [public]
GO
GRANT INSERT ON  [dbo].[EtaCompanyNotification] TO [public]
GO
GRANT SELECT ON  [dbo].[EtaCompanyNotification] TO [public]
GO
GRANT UPDATE ON  [dbo].[EtaCompanyNotification] TO [public]
GO
