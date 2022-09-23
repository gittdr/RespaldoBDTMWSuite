CREATE TABLE [dbo].[actg_temp_workrevalloc]
(
[sp_id] [int] NULL,
[ivh_number] [int] NULL,
[ivd_number] [int] NULL,
[lgh_number] [int] NULL,
[thr_id] [int] NULL,
[ral_proratequantity] [money] NULL,
[ral_totalprorates] [money] NULL,
[ral_rate] [money] NULL,
[ral_amount] [money] NULL,
[cur_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_conversion_rate] [money] NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_sequence] [int] NULL,
[ral_converted_rate] [money] NULL,
[ral_converted_amount] [money] NULL,
[ral_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ral_prorateitem] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[actg_temp_workrevalloc] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_temp_workrevalloc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_temp_workrevalloc] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_temp_workrevalloc] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_temp_workrevalloc] TO [public]
GO
