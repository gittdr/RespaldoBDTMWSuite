CREATE TABLE [dbo].[reportdetail]
(
[rph_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtd_id] [int] NOT NULL,
[rtd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpd_sequence] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [rpd_primary] ON [dbo].[reportdetail] ([rph_id], [rtd_id], [rtd_type], [rpd_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reportdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[reportdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reportdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[reportdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[reportdetail] TO [public]
GO
