CREATE TABLE [dbo].[orderheader_cancel_log]
(
[ord_hdrnumber] [int] NOT NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ohc_cancelled_by] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ohc_cancelled_date] [datetime] NOT NULL,
[ohc_requested_by] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohc_remark] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[och_cancelreasoncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ohcl] ON [dbo].[orderheader_cancel_log] ([ord_hdrnumber], [ohc_cancelled_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[orderheader_cancel_log] TO [public]
GO
GRANT INSERT ON  [dbo].[orderheader_cancel_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[orderheader_cancel_log] TO [public]
GO
GRANT SELECT ON  [dbo].[orderheader_cancel_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[orderheader_cancel_log] TO [public]
GO
