CREATE TABLE [dbo].[dx_Archive_RecordLock]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ProcessID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_filter] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updatedtime] [datetime] NOT NULL,
[TimeStamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Archive_RecordLock] ADD CONSTRAINT [uk_dx_archive_recordlock] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Archive_RecordLock] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Archive_RecordLock] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Archive_RecordLock] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Archive_RecordLock] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Archive_RecordLock] TO [public]
GO
