CREATE TABLE [dbo].[driveraccident]
(
[mpp_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dra_accidentdate] [datetime] NOT NULL,
[dra_filenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_points] [int] NULL,
[dra_description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_preventable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_cost] [money] NULL,
[dra_location] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_dispatcher] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_reserve] [money] NULL,
[dra_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_accidentNbr] [int] NOT NULL IDENTITY(1, 1),
[dra_dateClosed] [datetime] NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[dra_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_policeDept] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_ticketNbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_weather] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_profitLoss] [money] NULL,
[dra_createdDate] [datetime] NULL,
[dra_createdBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dra_lastUpdatedDate] [datetime] NULL,
[dra_lastUpdatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_dra_drvdate] ON [dbo].[driveraccident] ([mpp_id], [dra_accidentdate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driveraccident] TO [public]
GO
GRANT INSERT ON  [dbo].[driveraccident] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driveraccident] TO [public]
GO
GRANT SELECT ON  [dbo].[driveraccident] TO [public]
GO
GRANT UPDATE ON  [dbo].[driveraccident] TO [public]
GO
