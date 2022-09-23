CREATE TABLE [dbo].[toll_history]
(
[th_ident] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[toll_ident] [int] NOT NULL,
[th_cash_toll] [money] NOT NULL,
[th_card_toll] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[toll_history] ADD CONSTRAINT [pk_toll_history_ident] PRIMARY KEY CLUSTERED ([th_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[toll_history] TO [public]
GO
GRANT INSERT ON  [dbo].[toll_history] TO [public]
GO
GRANT SELECT ON  [dbo].[toll_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[toll_history] TO [public]
GO
