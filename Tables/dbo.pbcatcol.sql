CREATE TABLE [dbo].[pbcatcol]
(
[pbc_tnam] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_tid] [int] NULL,
[pbc_ownr] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cnam] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cid] [smallint] NULL,
[pbc_labl] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_lpos] [smallint] NULL,
[pbc_hdr] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_hpos] [smallint] NULL,
[pbc_jtfy] [smallint] NULL,
[pbc_mask] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_case] [smallint] NULL,
[pbc_hght] [smallint] NULL,
[pbc_wdth] [smallint] NULL,
[pbc_ptrn] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_bmap] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_init] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_cmnt] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_edit] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbc_tag] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pbcatcol_idx] ON [dbo].[pbcatcol] ([pbc_tid], [pbc_cid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcatcol] TO [public]
GO
GRANT INSERT ON  [dbo].[pbcatcol] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pbcatcol] TO [public]
GO
GRANT SELECT ON  [dbo].[pbcatcol] TO [public]
GO
GRANT UPDATE ON  [dbo].[pbcatcol] TO [public]
GO
