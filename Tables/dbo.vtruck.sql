CREATE TABLE [dbo].[vtruck]
(
[vtrk_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vtrk_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtrk_weightcap] [int] NULL,
[vtrk_volumecap] [int] NULL,
[vtrk_countcap] [int] NULL,
[vtrk_oneway] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vtruck] ADD CONSTRAINT [PK__vtruck__1C2BA580] PRIMARY KEY CLUSTERED ([vtrk_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[vtruck] TO [public]
GO
GRANT INSERT ON  [dbo].[vtruck] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vtruck] TO [public]
GO
GRANT SELECT ON  [dbo].[vtruck] TO [public]
GO
GRANT UPDATE ON  [dbo].[vtruck] TO [public]
GO
