CREATE TABLE [dbo].[company_charge]
(
[cch_cmp_charge_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cch_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cch_createdate] [datetime] NULL,
[cch_upddateddate] [datetime] NULL,
[cch_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_charge] ADD CONSTRAINT [pk_cch_cmp_charge_id] PRIMARY KEY CLUSTERED ([cch_cmp_charge_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_cch_cmp_id_cht_itemcode] ON [dbo].[company_charge] ([cmp_id], [cht_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_charge] TO [public]
GO
GRANT INSERT ON  [dbo].[company_charge] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_charge] TO [public]
GO
GRANT SELECT ON  [dbo].[company_charge] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_charge] TO [public]
GO
