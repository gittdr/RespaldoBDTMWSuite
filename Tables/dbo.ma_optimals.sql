CREATE TABLE [dbo].[ma_optimals]
(
[ma_opt_id] [int] NOT NULL IDENTITY(1, 1),
[ma_transaction_id] [bigint] NOT NULL,
[ma_tour_number] [int] NULL,
[ma_tour_sequence] [int] NULL,
[lgh_number] [int] NOT NULL,
[ma_load_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ma_relay_location] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ma_optimals_company_id] DEFAULT ('')
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [pk_ma_optimals] ON [dbo].[ma_optimals] ([ma_opt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ma_optimals_transaction_leg] ON [dbo].[ma_optimals] ([ma_transaction_id], [lgh_number], [company_id]) INCLUDE ([ma_load_type], [ma_tour_number], [trc_number], [mpp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ma_optimals_transaction_tour] ON [dbo].[ma_optimals] ([ma_transaction_id], [ma_tour_number], [company_id]) INCLUDE ([ma_load_type], [lgh_number], [ma_relay_location]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ma_optimals_transaction_power] ON [dbo].[ma_optimals] ([ma_transaction_id], [trc_number], [company_id]) INCLUDE ([ma_tour_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ma_optimals] TO [public]
GO
GRANT INSERT ON  [dbo].[ma_optimals] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ma_optimals] TO [public]
GO
GRANT SELECT ON  [dbo].[ma_optimals] TO [public]
GO
GRANT UPDATE ON  [dbo].[ma_optimals] TO [public]
GO
