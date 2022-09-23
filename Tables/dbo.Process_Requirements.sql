CREATE TABLE [dbo].[Process_Requirements]
(
[prq_id] [int] NOT NULL IDENTITY(1, 1),
[prq_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prq_reftable] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_required] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_210export] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_214export] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_210check] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_stopstatusfield] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_stopstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_ordstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_stoptype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_activitytable] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_reftype_validatemask] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_cmp_role] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Process_R__prq_c__67ECE76B] DEFAULT ('billto'),
[prq_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_cmpid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_invoicestatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prq_reftype_validatevalidateproc] [int] NULL,
[prq_optional] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Process_R__prq_o__0DDD8629] DEFAULT ('0')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Process_Requirements] ADD CONSTRAINT [pk_process_requirements] PRIMARY KEY CLUSTERED ([prq_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_prq_billto] ON [dbo].[Process_Requirements] ([prq_billto]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_pr_cmpid] ON [dbo].[Process_Requirements] ([prq_cmpid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Process_Requirements] TO [public]
GO
GRANT INSERT ON  [dbo].[Process_Requirements] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Process_Requirements] TO [public]
GO
GRANT SELECT ON  [dbo].[Process_Requirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[Process_Requirements] TO [public]
GO
