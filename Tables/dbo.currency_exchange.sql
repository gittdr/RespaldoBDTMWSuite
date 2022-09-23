CREATE TABLE [dbo].[currency_exchange]
(
[cex_from_curr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cex_to_curr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cex_date] [datetime] NOT NULL,
[cex_rate] [money] NOT NULL,
[dw_timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [i_cex_1] ON [dbo].[currency_exchange] ([cex_from_curr], [cex_to_curr], [cex_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_currency_exchange_timestamp] ON [dbo].[currency_exchange] ([dw_timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[currency_exchange] TO [public]
GO
GRANT INSERT ON  [dbo].[currency_exchange] TO [public]
GO
GRANT REFERENCES ON  [dbo].[currency_exchange] TO [public]
GO
GRANT SELECT ON  [dbo].[currency_exchange] TO [public]
GO
GRANT UPDATE ON  [dbo].[currency_exchange] TO [public]
GO
