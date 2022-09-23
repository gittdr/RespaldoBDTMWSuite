CREATE TABLE [dbo].[DriverAwareSuite_Conversation]
(
[mpp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[logdate] [datetime] NOT NULL,
[conversation] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[username] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[convid] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_Conversation] ADD CONSTRAINT [PK_DriverAwareSuite_Conversations] PRIMARY KEY CLUSTERED ([mpp_id], [logdate], [username]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_Conversation] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_Conversation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_Conversation] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_Conversation] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_Conversation] TO [public]
GO
