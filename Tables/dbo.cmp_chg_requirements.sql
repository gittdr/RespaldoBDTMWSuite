CREATE TABLE [dbo].[cmp_chg_requirements]
(
[ccr_rule_id] [int] NOT NULL IDENTITY(1, 1),
[ccr_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccr_rule_number] [int] NULL,
[ccr_rule_sequence] [int] NULL,
[ccr_min_charge] [money] NULL,
[ccr_max_charge] [money] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccr_exclude] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccr_chargeonly] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccr_rule_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmp_chg_requirements] ADD CONSTRAINT [PK_cmp_chg_requirements] PRIMARY KEY CLUSTERED ([ccr_rule_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmp_chg_requirements] TO [public]
GO
GRANT INSERT ON  [dbo].[cmp_chg_requirements] TO [public]
GO
GRANT SELECT ON  [dbo].[cmp_chg_requirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmp_chg_requirements] TO [public]
GO
