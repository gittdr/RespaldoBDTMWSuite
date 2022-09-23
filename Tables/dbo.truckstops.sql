CREATE TABLE [dbo].[truckstops]
(
[ts_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ts_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_address] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_city] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_zip_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_phone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_authorized] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[time_bad] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_cty] [int] NULL,
[timestamp] [timestamp] NULL,
[ts_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_truckstops_ts_payto] DEFAULT ('UNKNOWN'),
[ts_gp_payableaccount] [varchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_truckstops_ts_company] DEFAULT ('UNK'),
[ts_fax_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_email_address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_rebate_percentage] [decimal] (7, 4) NOT NULL CONSTRAINT [ts_rebate_percentage] DEFAULT (100.0000)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[truckstops] ADD CONSTRAINT [pk_truckstops] PRIMARY KEY CLUSTERED ([ts_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[truckstops] TO [public]
GO
GRANT INSERT ON  [dbo].[truckstops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[truckstops] TO [public]
GO
GRANT SELECT ON  [dbo].[truckstops] TO [public]
GO
GRANT UPDATE ON  [dbo].[truckstops] TO [public]
GO
