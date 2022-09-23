CREATE TABLE [dbo].[golivecheck_orderentry]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_orders] [int] NULL,
[glc_cnt_orders_cmp] [int] NULL,
[glc_cnt_orders_noncmp] [int] NULL,
[glc_cnt_orders_copy] [int] NULL,
[glc_cnt_orders_noncopy] [int] NULL,
[glc_cnt_orders_noncopy_tdy] [int] NULL,
[glc_cnt_orders_noncopy_nty] [int] NULL,
[glc_cnt_orders_mst] [int] NULL,
[glc_cnt_orders_cpy_from_mst] [int] NULL,
[glc_cnt_users_create_orders] [int] NULL,
[glc_cnt_orders_imported] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_orderentry] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_orderentry] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_orderentry] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_orderentry] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_orderentry] TO [public]
GO
