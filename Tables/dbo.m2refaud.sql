CREATE TABLE [dbo].[m2refaud]
(
[m2rauid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[m2rauuser] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2rautype] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2rauorder] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2raustop#] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2raucrtdt] [datetime] NULL,
[m2raucrtpg] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2raustat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2rauid] ON [dbo].[m2refaud] ([m2rauid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2refaud] TO [public]
GO
GRANT INSERT ON  [dbo].[m2refaud] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2refaud] TO [public]
GO
GRANT SELECT ON  [dbo].[m2refaud] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2refaud] TO [public]
GO
