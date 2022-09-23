CREATE TABLE [dbo].[companycustomparms]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccp_dt_rate] [money] NULL,
[ccp_dt_free_per_stop] [decimal] (15, 6) NULL,
[ccp_dt_free_per_order] [decimal] (15, 6) NULL,
[ccp_dt_cumulative_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccp_pd_rate] [money] NULL,
[ccp_pd_free_per_stop] [decimal] (15, 6) NULL,
[ccp_pd_free_per_order] [decimal] (15, 6) NULL,
[ccp_pd_cumulative_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccp_jockey_rate] [money] NULL,
[ccp_jockey_free_per_stop] [decimal] (15, 6) NULL,
[ccp_jockey_free_per_order] [decimal] (15, 6) NULL,
[ccp_so_rate] [money] NULL,
[ccp_custom_billing_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccp_created_date] [datetime] NOT NULL,
[ccp_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccp_modified_date] [datetime] NOT NULL,
[ccp_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccp_fuel_price] [money] NULL,
[ccp_peg_price] [money] NULL,
[ccp_allowance] [decimal] (14, 5) NULL,
[ccp_per_change] [decimal] (14, 5) NULL,
[ccp_secure_static_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccp_tractor_count] [int] NULL,
[ccp_trailer_count] [int] NULL,
[ccp_supervisor_charge] [money] NULL,
[extra_info_1_charge] [money] NULL,
[extra_info_2_charge] [money] NULL,
[extra_info_3_charge] [money] NULL,
[ccp_tractor_charge] [money] NULL,
[ccp_vehicle_insurance] [money] NULL,
[ccp_trailer_charge] [money] NULL,
[ccp_trailer_rebate] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companycustomparms] ADD CONSTRAINT [PK_companycustomparms] PRIMARY KEY NONCLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companycustomparms] TO [public]
GO
GRANT INSERT ON  [dbo].[companycustomparms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[companycustomparms] TO [public]
GO
GRANT SELECT ON  [dbo].[companycustomparms] TO [public]
GO
GRANT UPDATE ON  [dbo].[companycustomparms] TO [public]
GO
