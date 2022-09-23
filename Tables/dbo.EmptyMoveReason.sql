CREATE TABLE [dbo].[EmptyMoveReason]
(
[lgh_number] [int] NOT NULL,
[Reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmptyMoveReason] ADD CONSTRAINT [PK_EmptyMoveReason] PRIMARY KEY CLUSTERED ([lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EmptyMoveReason] TO [public]
GO
GRANT INSERT ON  [dbo].[EmptyMoveReason] TO [public]
GO
GRANT SELECT ON  [dbo].[EmptyMoveReason] TO [public]
GO
GRANT UPDATE ON  [dbo].[EmptyMoveReason] TO [public]
GO
