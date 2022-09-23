CREATE TABLE [dbo].[MobileCommMessageQueue]
(
[msg_ID] [int] NOT NULL,
[msg_date] [datetime] NOT NULL,
[msg_FormID] [int] NOT NULL,
[msg_To] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msg_ToType] [int] NOT NULL,
[msg_FilterData] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msg_FilterDataDupWaitSeconds] [int] NULL,
[msg_From] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[msg_FromType] [int] NOT NULL,
[msg_Subject] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageGroup] [int] NOT NULL CONSTRAINT [DF__MobileCom__Messa__6DE0EB7B] DEFAULT ((1)),
[RetrievedDate] [datetime2] (3) NULL,
[ApplicationName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageQueue] ADD CONSTRAINT [PK_MobileCommMessageQueue] PRIMARY KEY CLUSTERED ([msg_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RetrievedDate] ON [dbo].[MobileCommMessageQueue] ([RetrievedDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommMessageQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageQueue] TO [public]
GO
