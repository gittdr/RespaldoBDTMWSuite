CREATE TABLE [dbo].[standingdeduction_audit]
(
[sda_identity] [int] NOT NULL IDENTITY(1, 1),
[sda_number] [int] NOT NULL,
[sda_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sda_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sda_balance] [money] NULL,
[sda_startbalance] [money] NULL,
[sda_endbalance] [money] NULL,
[sda_deductionrate] [money] NULL,
[sda_reductionrate] [money] NULL,
[sda_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sda_issuedate] [datetime] NULL,
[sda_closedate] [datetime] NULL,
[sda_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sda_asgnid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sda_priority] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sda_changedate] [datetime] NOT NULL,
[sda_changeuser] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sda_transactiontype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[standingdeduction_audit] ADD CONSTRAINT [PK_standingdeduction_audit] PRIMARY KEY NONCLUSTERED ([sda_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sda_asgn_type_id] ON [dbo].[standingdeduction_audit] ([sda_asgntype], [sda_asgnid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sdm_itemcode] ON [dbo].[standingdeduction_audit] ([sda_itemcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sda_item_type_id] ON [dbo].[standingdeduction_audit] ([sda_itemcode], [sda_asgntype], [sda_asgnid]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [dk_standingdeduction_audit] ON [dbo].[standingdeduction_audit] ([sda_number], [sda_changedate], [sda_changeuser], [sda_transactiontype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[standingdeduction_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[standingdeduction_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[standingdeduction_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[standingdeduction_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[standingdeduction_audit] TO [public]
GO
