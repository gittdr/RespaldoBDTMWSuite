CREATE TABLE [dbo].[paperwork_by_assettypes]
(
[pat_ident] [int] NOT NULL IDENTITY(1, 1),
[pat_doctype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asset_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asset_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asset_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asset_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asset_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bdt_required_for_fgt_event] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__paperwork__bdt_r__63436177] DEFAULT ('ASTOP')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paperwork_by_assettypes] ADD CONSTRAINT [pk_pat_ident] PRIMARY KEY CLUSTERED ([pat_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paperwork_by_assettypes] TO [public]
GO
GRANT INSERT ON  [dbo].[paperwork_by_assettypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paperwork_by_assettypes] TO [public]
GO
GRANT SELECT ON  [dbo].[paperwork_by_assettypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[paperwork_by_assettypes] TO [public]
GO
