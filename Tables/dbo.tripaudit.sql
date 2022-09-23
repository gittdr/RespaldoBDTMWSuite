CREATE TABLE [dbo].[tripaudit]
(
[upd_date] [datetime] NULL,
[upd_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upd_app] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[customer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[lgh_outstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_city] [int] NULL,
[arrivaldate] [datetime] NULL,
[departuredate] [datetime] NULL,
[evt_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_sequence] [int] NULL,
[stp_sequence] [int] NULL,
[driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mfh_mileage] [int] NULL,
[ord_mileage] [int] NULL,
[lgh_mileage] [int] NULL,
[weight] [float] NULL,
[cnt] [int] NULL,
[volume] [float] NULL,
[quantity] [float] NULL,
[tare_weight] [float] NULL,
[stp_number] [int] NULL,
[fgt_number] [int] NULL,
[evt_number] [int] NULL,
[evt_sequence] [int] NULL,
[fgt_sequence] [smallint] NULL,
[tripaudit_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tripaudit] ADD CONSTRAINT [prkey_tripaudit] PRIMARY KEY CLUSTERED ([tripaudit_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tripaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[tripaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tripaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[tripaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[tripaudit] TO [public]
GO
