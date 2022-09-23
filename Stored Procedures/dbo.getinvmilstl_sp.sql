SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[getinvmilstl_sp] (@pl_invnumber int,@pdec_miles money out) 
as


 select 	@pdec_miles = sum(ivd_distance) 
	from 	invoicedetail
	where 	ivh_hdrnumber = @pl_invnumber and
			cht_itemcode = 'DEL'			

GO
GRANT EXECUTE ON  [dbo].[getinvmilstl_sp] TO [public]
GO
