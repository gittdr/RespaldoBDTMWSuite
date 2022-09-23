CREATE TABLE [dbo].[terminalzone]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dock_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[zone_description] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zone_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__zone___4E8742C1] DEFAULT ('Z'),
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminalzone] ADD CONSTRAINT [CK__terminalz__zone___4F7B66FA] CHECK (([zone_type]='Y' OR [zone_type]='S' OR [zone_type]='Z'))
GO
ALTER TABLE [dbo].[terminalzone] ADD CONSTRAINT [PK__terminal__1ECA71F9378874AD] PRIMARY KEY CLUSTERED ([cmp_id], [dock_zone]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminalzone] TO [public]
GO
GRANT INSERT ON  [dbo].[terminalzone] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminalzone] TO [public]
GO
GRANT SELECT ON  [dbo].[terminalzone] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminalzone] TO [public]
GO
