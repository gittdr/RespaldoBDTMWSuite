CREATE TABLE [dbo].[TimeDetailActivityMappings]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[BeginningActivityId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndingActivityId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeSourceSystemId] [smallint] NOT NULL,
[MappedTimeLogActivityLabelAbbr] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeDetailActivityMappings] ADD CONSTRAINT [FK_TimeDetailActivityMappings_TimeSourceSystem] FOREIGN KEY ([TimeSourceSystemId]) REFERENCES [dbo].[TimeSourceSystem] ([TimeSourceSystemId])
GO
GRANT DELETE ON  [dbo].[TimeDetailActivityMappings] TO [public]
GO
GRANT INSERT ON  [dbo].[TimeDetailActivityMappings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TimeDetailActivityMappings] TO [public]
GO
GRANT SELECT ON  [dbo].[TimeDetailActivityMappings] TO [public]
GO
GRANT UPDATE ON  [dbo].[TimeDetailActivityMappings] TO [public]
GO
