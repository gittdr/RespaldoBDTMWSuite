CREATE TABLE [dbo].[pbcattbl]
(
[pbt_tnam] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbt_tid] [int] NULL,
[pbt_ownr] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbd_fhgt] [smallint] NULL,
[pbd_fwgt] [smallint] NULL,
[pbd_fitl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbd_funl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbd_fchr] [smallint] NULL,
[pbd_fptc] [smallint] NULL,
[pbd_ffce] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbh_fhgt] [smallint] NULL,
[pbh_fwgt] [smallint] NULL,
[pbh_fitl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbh_funl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbh_fchr] [smallint] NULL,
[pbh_fptc] [smallint] NULL,
[pbh_ffce] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbl_fhgt] [smallint] NULL,
[pbl_fwgt] [smallint] NULL,
[pbl_fitl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbl_funl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbl_fchr] [smallint] NULL,
[pbl_fptc] [smallint] NULL,
[pbl_ffce] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbt_cmnt] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pbcattbl_idx] ON [dbo].[pbcattbl] ([pbt_tid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcattbl] TO [public]
GO
GRANT INSERT ON  [dbo].[pbcattbl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pbcattbl] TO [public]
GO
GRANT SELECT ON  [dbo].[pbcattbl] TO [public]
GO
GRANT UPDATE ON  [dbo].[pbcattbl] TO [public]
GO
