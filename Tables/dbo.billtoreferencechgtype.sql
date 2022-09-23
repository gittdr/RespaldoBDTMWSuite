CREATE TABLE [dbo].[billtoreferencechgtype]
(
[btrct_id] [int] NOT NULL IDENTITY(1, 1),
[btrct_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[btrct_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btrct_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chg_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btrct_mask] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[billtoreferencechgtype] ADD CONSTRAINT [pk_billtoreferencechgtype_btrct_id] PRIMARY KEY CLUSTERED ([btrct_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_billtoreferencechgtype_btrct_billto] ON [dbo].[billtoreferencechgtype] ([btrct_billto]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[billtoreferencechgtype] TO [public]
GO
GRANT INSERT ON  [dbo].[billtoreferencechgtype] TO [public]
GO
GRANT REFERENCES ON  [dbo].[billtoreferencechgtype] TO [public]
GO
GRANT SELECT ON  [dbo].[billtoreferencechgtype] TO [public]
GO
GRANT UPDATE ON  [dbo].[billtoreferencechgtype] TO [public]
GO
