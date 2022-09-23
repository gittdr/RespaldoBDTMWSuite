CREATE TABLE [dbo].[backofficeview]
(
[bov_appid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_id] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bov_billto] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_booked_revtype1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_rev_type4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_lgh_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_bookedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_source] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_paperwork_received] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ord_orderedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_shipper] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_consignee] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_fleet] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_division] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_terminal] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_acct_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_driver_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_driver_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_type4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tractor_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tractor_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_type4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trailer_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trailer_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_type4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_carrier_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_carrier_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_type4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tpr_incl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tpr_id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_tpr_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_inv_status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_ivh_rev_type1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_dedicated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_master_bill] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_freight_bill] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_none] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_cmp_othertype1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_cmp_othertype2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_cmp_othertype3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_cmp_othertype4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_mpp_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trc_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_trl_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bov_car_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_id_type] ON [dbo].[backofficeview] ([bov_id], [bov_type]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[backofficeview] TO [public]
GO
GRANT INSERT ON  [dbo].[backofficeview] TO [public]
GO
GRANT SELECT ON  [dbo].[backofficeview] TO [public]
GO
GRANT UPDATE ON  [dbo].[backofficeview] TO [public]
GO
