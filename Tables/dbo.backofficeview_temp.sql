CREATE TABLE [dbo].[backofficeview_temp]
(
[bov_identity] [int] NOT NULL IDENTITY(1, 1),
[bov_appid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_id] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tmwuser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_ord_bookedby] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_source] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_status] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_orderedby] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_shipper] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_consignee] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_billto] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_acct_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_booked_revtype1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type3] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type4] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_lgh_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_company] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_fleet] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_division] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_terminal] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_paperwork_received] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_driver_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_driver_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type3] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type4] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tractor_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tractor_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type3] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type4] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trailer_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trailer_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type3] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type4] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_carrier_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_carrier_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type3] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type4] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tpr_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tpr_id] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tpr_type] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_inv_status] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ivh_rev_type1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[backofficeview_temp] ADD CONSTRAINT [pk_backofficeview_temp] PRIMARY KEY CLUSTERED ([bov_identity]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_backofficeview_temp_bov_id_bov_type_tmwuser] ON [dbo].[backofficeview_temp] ([bov_id], [bov_type], [tmwuser]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[backofficeview_temp] TO [public]
GO
GRANT INSERT ON  [dbo].[backofficeview_temp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[backofficeview_temp] TO [public]
GO
GRANT SELECT ON  [dbo].[backofficeview_temp] TO [public]
GO
GRANT UPDATE ON  [dbo].[backofficeview_temp] TO [public]
GO
