CREATE TABLE [dbo].[dwHeartbeat]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[DateUpdated] [datetime] NULL,
[UTCDateUpdated] [datetime] NULL,
[RowVersionValue] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dwHeartbeat] ADD CONSTRAINT [PK__dwHeartbeat__035C6297] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dwHeartbeat] TO [public]
GO
GRANT INSERT ON  [dbo].[dwHeartbeat] TO [public]
GO
GRANT SELECT ON  [dbo].[dwHeartbeat] TO [public]
GO
GRANT UPDATE ON  [dbo].[dwHeartbeat] TO [public]
GO
