CREATE TABLE [dbo].[carrierfilter]
(
[caf_id] [int] NOT NULL IDENTITY(1, 1),
[caf_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type1_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type2_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type3_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_car_type4_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_liability_limit] [money] NULL,
[caf_liability_limit_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_cargo_limit] [money] NULL,
[caf_cargo_limit_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_rate_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_lane] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_lane_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_orig_state] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_orig_state_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_orig_city] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_orig_city_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_dest_state] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_dest_state_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_dest_city] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_dest_city_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_ins_cert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_ins_cert_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_w9] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_w9_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_contract] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_contract_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_service_rating] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_service_rating_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_carrier_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_history_only] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_history_only_def] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_viewid] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_viewname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_branch] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_RateOnFile_only] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierfilter] ADD CONSTRAINT [PK_carrierfilter] PRIMARY KEY CLUSTERED ([caf_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierfilter] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierfilter] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierfilter] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierfilter] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierfilter] TO [public]
GO
