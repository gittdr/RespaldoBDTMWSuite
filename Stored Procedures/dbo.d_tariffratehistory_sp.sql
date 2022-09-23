SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_tariffratehistory_sp](@pl_tarnum int) as -- ,@pl_trc_number_row int, @pl_trc_number_col int) as
	select trh_number,tar_number,trc_number_row,trc_number_col,trh_fromdate,trh_todate,tra_rate,
		   trh_createdby,trh_createddate,trh_updatedby,trh_updateddate,(select  case when getdate() >= trh_fromdate and getdate() <= trh_todate then 1 else 0 end) as trh_activerow
	from   tariffratehistory
	where  tar_number = @pl_tarnum -- and trc_number_row = @pl_trc_number_row and trc_number_col = @pl_trc_number_col


GO
GRANT EXECUTE ON  [dbo].[d_tariffratehistory_sp] TO [public]
GO
