CREATE TABLE [dbo].[TransferHeader]
(
[TransferHeaderId] [int] NOT NULL,
[TransferConfigId] [int] NOT NULL,
[BatchNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__TransferH__Creat__4308A07D] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TransferH__Creat__43FCC4B6] DEFAULT (user_name()),
[PackageStartDate] [datetime] NULL,
[PackageEndDate] [datetime] NULL,
[Status] [bit] NULL,
[StatusMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferHeader] ADD CONSTRAINT [PK_TransferHeader] PRIMARY KEY CLUSTERED ([TransferHeaderId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TransferHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferHeader] TO [public]
GO
