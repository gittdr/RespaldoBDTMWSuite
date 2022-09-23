CREATE TABLE [dbo].[TimeDetails]
(
[TimeDetailId] [int] NOT NULL IDENTITY(1, 1),
[MappedTimeLogActivityLabelAbbr] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActivityStart] [datetime2] (3) NOT NULL,
[ActivityEnd] [datetime2] (3) NOT NULL,
[Duration] [decimal] (8, 4) NOT NULL,
[TimeSourceSystemId] [smallint] NOT NULL,
[Approved] [bit] NOT NULL,
[Overridden] [bit] NOT NULL,
[Comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdatedDate] [datetime2] (3) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeDetails] ADD CONSTRAINT [PK_TimeDetail] PRIMARY KEY CLUSTERED ([TimeDetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeDetails] ADD CONSTRAINT [FK_TimeDetails_TimeSourceSystem] FOREIGN KEY ([TimeSourceSystemId]) REFERENCES [dbo].[TimeSourceSystem] ([TimeSourceSystemId])
GO
GRANT DELETE ON  [dbo].[TimeDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[TimeDetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TimeDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[TimeDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[TimeDetails] TO [public]
GO
