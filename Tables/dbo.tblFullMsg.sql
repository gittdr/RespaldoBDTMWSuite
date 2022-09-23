CREATE TABLE [dbo].[tblFullMsg]
(
[MsgDate] [datetime] NOT NULL,
[Subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRACTOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MsgType] [int] NOT NULL,
[Priority] [int] NOT NULL,
[Ignition] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NOT NULL,
[MessageID] [int] NOT NULL,
[Error] [int] NULL,
[DateRead] [datetime] NULL,
[DTSent] [datetime] NULL,
[DTReceived] [datetime] NULL,
[Folder] [int] NOT NULL,
[Raw_Status] [int] NOT NULL,
[TypeDesc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateAck] [datetime] NULL,
[SpecialMsgSN] [int] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblFullMsg] ON [dbo].[tblFullMsg] ([TRACTOR]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFullMsg] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFullMsg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFullMsg] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFullMsg] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFullMsg] TO [public]
GO
