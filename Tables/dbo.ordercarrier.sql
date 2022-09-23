CREATE TABLE [dbo].[ordercarrier]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[movement_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL,
[probill] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[protected_charge] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ordercarr__prote__6D40D40B] DEFAULT ('N'),
[lgh_number] [int] NULL,
[base_amount] [money] NULL,
[acc_amount] [money] NULL,
[rowchgts] [timestamp] NOT NULL,
[currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[manual_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_by] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gl_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approve] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ordercarrier] ADD CONSTRAINT [PK__ordercar__3213E83FCE677304] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ordercarrier_leg] ON [dbo].[ordercarrier] ([lgh_number], [id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ordercarrier_ord] ON [dbo].[ordercarrier] ([ord_hdrnumber], [id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ordercarrier] TO [public]
GO
GRANT INSERT ON  [dbo].[ordercarrier] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ordercarrier] TO [public]
GO
GRANT SELECT ON  [dbo].[ordercarrier] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordercarrier] TO [public]
GO
