CREATE TABLE [dbo].[tblWatchDogWorkFlowQueue]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[WatchSn] [int] NULL,
[WatchName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdate] [datetime] NULL,
[WatchXMLData] [xml] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblWatchDogWorkFlowQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[tblWatchDogWorkFlowQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[tblWatchDogWorkFlowQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblWatchDogWorkFlowQueue] TO [public]
GO
