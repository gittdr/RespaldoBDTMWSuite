CREATE TABLE [dbo].[carrier411ws]
(
[BATCH_ID] [int] NOT NULL IDENTITY(1, 1),
[method] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[workflow_id] [int] NULL,
[LastUpdatedBy] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__carrier41__LastU__3C987512] DEFAULT (user_name()),
[LastUpdateDate] [datetime] NULL CONSTRAINT [DF__carrier41__LastU__3D8C994B] DEFAULT (getdate()),
[CarrierCSALogHdr_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier411ws] ADD CONSTRAINT [pk_carrier411ws] PRIMARY KEY CLUSTERED ([BATCH_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrier411ws] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier411ws] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier411ws] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier411ws] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier411ws] TO [public]
GO
