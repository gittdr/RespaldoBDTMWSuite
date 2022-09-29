CREATE TABLE [dbo].[terminaltravelservice]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[serviced] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[service_pickup] [datetime] NULL,
[advance_serviced] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_days] [float] NULL,
[arr_adv_terminal] [datetime] NULL,
[dep_adv_terminal] [datetime] NULL,
[linehaul_serviced] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[linehaul_days] [float] NULL,
[beyond_serviced] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[arr_bey_terminal] [datetime] NULL,
[dep_bey_terminal] [datetime] NULL,
[beyond_days] [float] NULL,
[service_delivery] [datetime] NULL,
[total_days] [float] NULL,
[last_updated] [datetime] NULL,
[svclevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bill_to] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_override] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_override] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_city] [int] NULL,
[advance_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_city] [int] NULL,
[beyond_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requestor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__terminalt__INS_T__76D655F9] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [terminaltravelservice_INS_TIMESTAMP] ON [dbo].[terminaltravelservice] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [termtravserv_ord_hdrnumber] ON [dbo].[terminaltravelservice] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaltravelservice] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaltravelservice] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaltravelservice] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaltravelservice] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaltravelservice] TO [public]
GO
