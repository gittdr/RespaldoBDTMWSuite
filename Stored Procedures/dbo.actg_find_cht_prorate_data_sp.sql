SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create proc [dbo].[actg_find_cht_prorate_data_sp]
        @p_cht_itemcode varchar(6),
        @p_ivd_lghnum int,
        @p_ivh_ordhdrnum int,
        @p_final_alloc_method varchar(6) OUT,
        @p_final_alloc_criteria varchar(6) OUT,
        @p_final_alloc_data varchar(30) OUT
as
exec dbo.actg_find_cht_prorate_data2_sp
        @p_cht_itemcode,
        @p_ivd_lghnum,
        @p_ivh_ordhdrnum,
		0,
        @p_final_alloc_method OUT,
        @p_final_alloc_criteria OUT,
        @p_final_alloc_data OUT
GO
GRANT EXECUTE ON  [dbo].[actg_find_cht_prorate_data_sp] TO [public]
GO
