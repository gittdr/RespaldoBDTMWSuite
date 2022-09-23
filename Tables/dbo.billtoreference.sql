CREATE TABLE [dbo].[billtoreference]
(
[btr_id] [int] NOT NULL IDENTITY(1, 1),
[btr_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[btr_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btr_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btr_logic] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btr_mask] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btr_masklogic] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btr_mask2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[billtoreference] ADD CONSTRAINT [pk_billtoreference_btr_id] PRIMARY KEY CLUSTERED ([btr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_billtoreference_btr_billto] ON [dbo].[billtoreference] ([btr_billto]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[billtoreference] TO [public]
GO
GRANT INSERT ON  [dbo].[billtoreference] TO [public]
GO
GRANT REFERENCES ON  [dbo].[billtoreference] TO [public]
GO
GRANT SELECT ON  [dbo].[billtoreference] TO [public]
GO
GRANT UPDATE ON  [dbo].[billtoreference] TO [public]
GO
