CREATE TABLE [dbo].[trlconfiguration]
(
[cfg_identity] [int] NOT NULL IDENTITY(1, 1),
[cfg_trlconfiguration] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cfg_mt_type_loaded] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfg_mt_type_empty] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfg_season] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trlconfig__cfg_s__259A6D91] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trlconfiguration] ADD CONSTRAINT [idx_trlcfg] PRIMARY KEY CLUSTERED ([cfg_trlconfiguration], [cfg_season]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trlconfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[trlconfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trlconfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[trlconfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[trlconfiguration] TO [public]
GO
