CREATE TABLE [dbo].[invoicebackouts]
(
[asgn_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[boc_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ibo_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [binary] (8) NULL,
[ibo_backoutamt] [money] NOT NULL,
[ibo_ivh_hdrnumber] [int] NULL,
[ibo_rate] [float] NULL,
[ibo_quantity] [float] NULL,
[ibo_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[invoicebackouts] ADD CONSTRAINT [pk_invoicebackouts] PRIMARY KEY CLUSTERED ([asgn_type], [asgn_id], [ord_hdrnumber], [boc_itemcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ibo_ivh_hdrnumber] ON [dbo].[invoicebackouts] ([ibo_ivh_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoicebackouts] TO [public]
GO
GRANT INSERT ON  [dbo].[invoicebackouts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoicebackouts] TO [public]
GO
GRANT SELECT ON  [dbo].[invoicebackouts] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoicebackouts] TO [public]
GO
