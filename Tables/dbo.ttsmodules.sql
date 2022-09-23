CREATE TABLE [dbo].[ttsmodules]
(
[modulename] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[moduleid] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [id] ON [dbo].[ttsmodules] ([moduleid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttsmodules] TO [public]
GO
GRANT INSERT ON  [dbo].[ttsmodules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttsmodules] TO [public]
GO
GRANT SELECT ON  [dbo].[ttsmodules] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttsmodules] TO [public]
GO
