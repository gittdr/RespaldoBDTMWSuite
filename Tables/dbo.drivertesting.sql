CREATE TABLE [dbo].[drivertesting]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drt_testdate] [datetime] NOT NULL,
[drt_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drt_results] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drt_administrator] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drt_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[sn] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_drt_drvdt] ON [dbo].[drivertesting] ([mpp_id], [drt_testdate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivertesting] TO [public]
GO
GRANT INSERT ON  [dbo].[drivertesting] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivertesting] TO [public]
GO
GRANT SELECT ON  [dbo].[drivertesting] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivertesting] TO [public]
GO
