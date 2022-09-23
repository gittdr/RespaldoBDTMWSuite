CREATE TABLE [dbo].[BillDoctypes]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bdt_doctype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bdt_sequence] [tinyint] NOT NULL,
[bdt_inv_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_inv_attach] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_required_for_application] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_required_for_fgt_event] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_inv_attachBC] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_inv_attachMisc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_required_for_dispatch] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillDocTypes_ident] [int] NOT NULL IDENTITY(1, 1),
[bdt_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_inv_attachcredit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_inv_attachrebill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_inv_attachsupp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cmpidseq] ON [dbo].[BillDoctypes] ([cmp_id], [bdt_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BillDoctypes] TO [public]
GO
GRANT INSERT ON  [dbo].[BillDoctypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[BillDoctypes] TO [public]
GO
GRANT SELECT ON  [dbo].[BillDoctypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[BillDoctypes] TO [public]
GO
