CREATE TABLE [dbo].[transcardexpense]
(
[tce_id] [int] NOT NULL IDENTITY(1, 1),
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tce_date] [datetime] NULL,
[tce_amount] [money] NULL,
[tce_approval_code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tce_cash_card] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tce_paydetail] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transcardexpense] ADD CONSTRAINT [pk_transcardexpense_tce_id] PRIMARY KEY CLUSTERED ([tce_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_transcardexpense_composite] ON [dbo].[transcardexpense] ([asgn_type], [asgn_id], [pyt_itemcode], [tce_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transcardexpense] TO [public]
GO
GRANT INSERT ON  [dbo].[transcardexpense] TO [public]
GO
GRANT REFERENCES ON  [dbo].[transcardexpense] TO [public]
GO
GRANT SELECT ON  [dbo].[transcardexpense] TO [public]
GO
GRANT UPDATE ON  [dbo].[transcardexpense] TO [public]
GO
