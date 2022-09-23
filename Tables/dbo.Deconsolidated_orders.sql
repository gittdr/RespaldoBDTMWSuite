CREATE TABLE [dbo].[Deconsolidated_orders]
(
[do_id] [int] NOT NULL IDENTITY(1, 1),
[do_orig_mov] [int] NOT NULL,
[do_orig_leg] [int] NULL,
[do_new_leg] [int] NULL,
[do_new_mov] [int] NOT NULL,
[do_ord_hdrnumber] [int] NOT NULL,
[do_date] [datetime] NULL,
[do_userid] [varchar] (225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Deconsolidated_orders] ADD CONSTRAINT [pk_do_id] PRIMARY KEY CLUSTERED ([do_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Deconsolidated_orders] TO [public]
GO
GRANT INSERT ON  [dbo].[Deconsolidated_orders] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Deconsolidated_orders] TO [public]
GO
GRANT SELECT ON  [dbo].[Deconsolidated_orders] TO [public]
GO
GRANT UPDATE ON  [dbo].[Deconsolidated_orders] TO [public]
GO
