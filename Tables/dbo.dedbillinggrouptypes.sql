CREATE TABLE [dbo].[dedbillinggrouptypes]
(
[dbgt_id] [int] NOT NULL IDENTITY(1, 1),
[dbg_id] [int] NULL,
[dbg_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_sequence] [int] NULL,
[dbgt_priority] [int] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_supresszero] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgt_subtotalonly] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[tar_tariffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillinggrouptypes] ADD CONSTRAINT [pk_dedbillinggrouptypes_dbgt_id] PRIMARY KEY CLUSTERED ([dbgt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillinggrouptypes_dbg_id] ON [dbo].[dedbillinggrouptypes] ([dbg_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillinggrouptypes] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillinggrouptypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillinggrouptypes] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillinggrouptypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillinggrouptypes] TO [public]
GO
