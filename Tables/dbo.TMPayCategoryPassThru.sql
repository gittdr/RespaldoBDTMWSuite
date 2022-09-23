CREATE TABLE [dbo].[TMPayCategoryPassThru]
(
[tmpc_id] [int] NOT NULL IDENTITY(1, 1),
[billto_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_category] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmpc_passthru] [tinyint] NULL,
[tmpc_passthruqty] [tinyint] NULL,
[tmpc_passthrumarkup] [tinyint] NULL,
[tmpc_markupunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmpc_markupvalue] [money] NULL,
[tmpc_markupitemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmpc_allocation_rule] [int] NULL,
[tmpc_reconcile] [tinyint] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmpc_reconcile_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmpc_reconcile_toleranceunit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMPayCate__tmpc___5495E8FA] DEFAULT ('N'),
[tmpc_reconcile_tolerancevalue] [money] NOT NULL CONSTRAINT [DF__TMPayCate__tmpc___558A0D33] DEFAULT ((0)),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime2] NULL,
[LastUpdatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [datetime2] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMPayCategoryPassThru] ADD CONSTRAINT [pk_TMPayCategoryPassThru_tmpc_id] PRIMARY KEY CLUSTERED ([tmpc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_TMPayCategoryPassThru_billto_id] ON [dbo].[TMPayCategoryPassThru] ([billto_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMPayCategoryPassThru] TO [public]
GO
GRANT INSERT ON  [dbo].[TMPayCategoryPassThru] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMPayCategoryPassThru] TO [public]
GO
GRANT SELECT ON  [dbo].[TMPayCategoryPassThru] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMPayCategoryPassThru] TO [public]
GO
