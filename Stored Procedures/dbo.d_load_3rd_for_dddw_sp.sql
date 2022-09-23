SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_load_3rd_for_dddw_sp] @ord_hdrnumber int
as

select distinct tpr_id
from thirdpartyassignment
where ord_number = (select ord_number from orderheader where ord_hdrnumber = @ord_hdrnumber)
and tpa_status <> 'DEL'
order by tpr_id


GO
GRANT EXECUTE ON  [dbo].[d_load_3rd_for_dddw_sp] TO [public]
GO
