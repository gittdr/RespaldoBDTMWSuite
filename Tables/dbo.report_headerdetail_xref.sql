CREATE TABLE [dbo].[report_headerdetail_xref]
(
[rth_reporttype] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtd_id] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [rpx_primary] ON [dbo].[report_headerdetail_xref] ([rth_reporttype], [rtd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[report_headerdetail_xref] TO [public]
GO
GRANT INSERT ON  [dbo].[report_headerdetail_xref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[report_headerdetail_xref] TO [public]
GO
GRANT SELECT ON  [dbo].[report_headerdetail_xref] TO [public]
GO
GRANT UPDATE ON  [dbo].[report_headerdetail_xref] TO [public]
GO
