CREATE TABLE [dbo].[tck_account]
(
[tck_account_number] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tck_auto_update_trip_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_unassign_trip_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_update_tractor_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_unassign_tractor_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_update_trailer_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_unassign_trailer_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_update_driver_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_auto_unassign_driver_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_inactive_trip_card_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_force_cash_advance_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_allow_off_network_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_allow_volume_override] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_default_assignment] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_driver_required_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_drivercdl_required_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_tractor_required_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_trailer_required_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_advance_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_debitdollar_paytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_updated_on] [datetime] NULL,
[tck_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tck_created_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tck_account] ADD CONSTRAINT [PK_tck_account_number] PRIMARY KEY NONCLUSTERED ([tck_account_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tck_account] TO [public]
GO
GRANT INSERT ON  [dbo].[tck_account] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tck_account] TO [public]
GO
GRANT SELECT ON  [dbo].[tck_account] TO [public]
GO
GRANT UPDATE ON  [dbo].[tck_account] TO [public]
GO
