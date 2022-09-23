CREATE TABLE [dbo].[HistoryUserInformation]
(
[HistoryUserInformationId] [int] NOT NULL IDENTITY(1, 1),
[UserName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HistoryUserInformation] ADD CONSTRAINT [PK_HistoryUserInformation] PRIMARY KEY CLUSTERED ([HistoryUserInformationId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[HistoryUserInformation] TO [public]
GO
GRANT INSERT ON  [dbo].[HistoryUserInformation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[HistoryUserInformation] TO [public]
GO
GRANT SELECT ON  [dbo].[HistoryUserInformation] TO [public]
GO
GRANT UPDATE ON  [dbo].[HistoryUserInformation] TO [public]
GO
