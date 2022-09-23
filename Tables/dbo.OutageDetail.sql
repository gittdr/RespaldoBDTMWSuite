CREATE TABLE [dbo].[OutageDetail]
(
[OutageID] [int] NOT NULL,
[DetailType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DetailValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_OutageDetail_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_OutageDetail_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OutageDetail] ADD CONSTRAINT [PK_OutageDetail] PRIMARY KEY CLUSTERED ([OutageID], [DetailType], [DetailValue]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OutageDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[OutageDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[OutageDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[OutageDetail] TO [public]
GO
