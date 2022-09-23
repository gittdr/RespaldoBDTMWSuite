CREATE TABLE [dbo].[payratedetail]
(
[timestamp] [timestamp] NULL,
[prh_number] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prd_sequence] [smallint] NOT NULL,
[prd_break1] [float] NOT NULL,
[prd_rate1] [money] NOT NULL,
[prd_break2] [float] NULL,
[prd_rate2] [money] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [idx_pyd1] ON [dbo].[payratedetail] ([prh_number], [prd_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payratedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[payratedetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payratedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[payratedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[payratedetail] TO [public]
GO
