CREATE TABLE [dbo].[carrier411wslog]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[BATCH_ID] [int] NOT NULL,
[FaultCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaultMessage] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedBy] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__carrier41__LastU__406905F6] DEFAULT (user_name()),
[LastUpdateDate] [datetime] NULL CONSTRAINT [DF__carrier41__LastU__415D2A2F] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier411wslog] ADD CONSTRAINT [pk_carrier411wslog] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier411wslog] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier411wslog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier411wslog] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier411wslog] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier411wslog] TO [public]
GO
