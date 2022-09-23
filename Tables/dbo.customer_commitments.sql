CREATE TABLE [dbo].[customer_commitments]
(
[cmc_sn] [int] NOT NULL IDENTITY(1, 1),
[cmc_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmc_seq] [int] NULL,
[cmc_orig_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_city] [int] NULL,
[cmc_orig_ctynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_partialzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_orig_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_city] [int] NULL,
[cmc_dest_ctynmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_partialzip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_region1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_region2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_region3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_dest_region4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_effectivedate] [datetime] NULL,
[cmc_expirationdate] [datetime] NULL,
[cmc_loads_weekly] [int] NULL,
[cmc_loads_sun] [int] NULL,
[cmc_loads_mon] [int] NULL,
[cmc_loads_tue] [int] NULL,
[cmc_loads_wed] [int] NULL,
[cmc_loads_thr] [int] NULL,
[cmc_loads_fri] [int] NULL,
[cmc_loads_sat] [int] NULL,
[cmc_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmc_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_customer_commitments_cmp_id] ON [dbo].[customer_commitments] ([cmc_cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[customer_commitments] TO [public]
GO
GRANT INSERT ON  [dbo].[customer_commitments] TO [public]
GO
GRANT REFERENCES ON  [dbo].[customer_commitments] TO [public]
GO
GRANT SELECT ON  [dbo].[customer_commitments] TO [public]
GO
GRANT UPDATE ON  [dbo].[customer_commitments] TO [public]
GO
