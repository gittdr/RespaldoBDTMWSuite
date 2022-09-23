CREATE TABLE [dbo].[dedbillinggroupdetails]
(
[dbgd_id] [int] NOT NULL IDENTITY(1, 1),
[dbg_id] [int] NULL,
[dbgt_id] [int] NULL,
[dbgd_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_sequence] [int] NULL,
[dbgd_priority] [int] NULL,
[dbgd_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_ratingtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[tar_tarrifnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_tariffitem] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_computeexpression] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dbgd_rateexpression] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dedbillinggroupdetails] ADD CONSTRAINT [pk_dedbillinggroupdetails_dbgd_id] PRIMARY KEY CLUSTERED ([dbgd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillinggroupdetails_dbg_id] ON [dbo].[dedbillinggroupdetails] ([dbg_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dedbillinggroupdetails_dbgt_id] ON [dbo].[dedbillinggroupdetails] ([dbgt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dedbillinggroupdetails] TO [public]
GO
GRANT INSERT ON  [dbo].[dedbillinggroupdetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dedbillinggroupdetails] TO [public]
GO
GRANT SELECT ON  [dbo].[dedbillinggroupdetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[dedbillinggroupdetails] TO [public]
GO
