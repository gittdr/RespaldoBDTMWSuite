CREATE TABLE [dbo].[fuel_intraday_packets]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[xfacetype] [int] NOT NULL,
[transaction_data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[transaction_date] [datetime] NOT NULL,
[transaction_number] [int] NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extra_data] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_datetime] [datetime] NULL,
[processed_datetime] [datetime] NULL,
[last_updated_datetime] [datetime] NOT NULL,
[last_updated_by] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuel_intraday_packets_transaction_date] ON [dbo].[fuel_intraday_packets] ([transaction_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuel_intraday_packets_transaction_date_and_number] ON [dbo].[fuel_intraday_packets] ([transaction_date], [transaction_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuel_intraday_packets_transaction_date_and_number_and_xfacetype] ON [dbo].[fuel_intraday_packets] ([transaction_date], [transaction_number], [xfacetype]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuel_intraday_packets_transaction_number] ON [dbo].[fuel_intraday_packets] ([transaction_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuel_intraday_packets_xfacetype] ON [dbo].[fuel_intraday_packets] ([xfacetype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuel_intraday_packets] TO [public]
GO
GRANT INSERT ON  [dbo].[fuel_intraday_packets] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuel_intraday_packets] TO [public]
GO
GRANT SELECT ON  [dbo].[fuel_intraday_packets] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuel_intraday_packets] TO [public]
GO
