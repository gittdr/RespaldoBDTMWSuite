CREATE TABLE [dbo].[RailTemplateDetail]
(
[rtd_id] [int] NOT NULL IDENTITY(1, 1),
[rth_id] [int] NOT NULL,
[rtd_quote] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_plan] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_service] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_loaded] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_mode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_length] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_stcc] [varchar] (72) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_benown] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtd_lastupdate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailTemplateDetail] ADD CONSTRAINT [pk_railtemplatedetail_rtd_id] PRIMARY KEY CLUSTERED ([rtd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_railtemplatedetail_rth_id] ON [dbo].[RailTemplateDetail] ([rth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RailTemplateDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[RailTemplateDetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RailTemplateDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[RailTemplateDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[RailTemplateDetail] TO [public]
GO
