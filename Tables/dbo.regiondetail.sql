CREATE TABLE [dbo].[regiondetail]
(
[rgd_number] [int] NOT NULL,
[rgh_number] [int] NOT NULL,
[rgd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rgd_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_rgd_id] ON [dbo].[regiondetail] ([rgd_type], [rgd_id]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [idx1_reg] ON [dbo].[regiondetail] ([rgh_number], [rgd_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[regiondetail] TO [public]
GO
GRANT INSERT ON  [dbo].[regiondetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[regiondetail] TO [public]
GO
GRANT SELECT ON  [dbo].[regiondetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[regiondetail] TO [public]
GO
