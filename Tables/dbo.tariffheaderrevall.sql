CREATE TABLE [dbo].[tariffheaderrevall]
(
[thr_id] [int] NOT NULL IDENTITY(1, 1),
[thr_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thr_rate] [money] NULL,
[thr_processing_sequence] [int] NULL,
[thr_created_date] [datetime] NOT NULL,
[thr_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[thr_modified_date] [datetime] NOT NULL,
[thr_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[thr_prevent_chrg_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffheaderrevall] ADD CONSTRAINT [pk_tariffheaderrevall_id] PRIMARY KEY CLUSTERED ([thr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffheaderrevall] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffheaderrevall] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffheaderrevall] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffheaderrevall] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffheaderrevall] TO [public]
GO
