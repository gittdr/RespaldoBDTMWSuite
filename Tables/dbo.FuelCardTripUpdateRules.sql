CREATE TABLE [dbo].[FuelCardTripUpdateRules]
(
[fctur_id] [int] NOT NULL IDENTITY(1, 1),
[fctur_vendor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fctur_acct_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_acct] DEFAULT ('ALL'),
[fctur_cust_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_cust] DEFAULT ('ALL'),
[fctur_lgh_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fctur_drv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_drv] DEFAULT ('N'),
[fctur_trc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_trc] DEFAULT ('N'),
[fctur_trl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_trl] DEFAULT ('N'),
[fctur_trip] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_trip] DEFAULT ('N'),
[fctur_fp_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_fpflag] DEFAULT ('D'),
[fctur_adv_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_advflag] DEFAULT ('D'),
[fctur_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_fctur_status] DEFAULT ('D'),
[fctur_pending_adv_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fctur_calc_fplimit_mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fctur_calc_fplimit_logic] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fctur_policy_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelCardTripUpdateRules] ADD CONSTRAINT [pk_fctur] PRIMARY KEY CLUSTERED ([fctur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelCardTripUpdateRules] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelCardTripUpdateRules] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelCardTripUpdateRules] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelCardTripUpdateRules] TO [public]
GO
