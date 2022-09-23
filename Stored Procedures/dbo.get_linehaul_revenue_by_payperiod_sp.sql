SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_linehaul_revenue_by_payperiod_sp] (@pl_pyhnumber int,@pdec_lhrevenue money out)
AS
/**
 * 
 * NAME:
 * dbo.get_linehaul_revenue_by_payperiod_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return linehaul charges from the invoices for this payperiod 
 *
 * RETURNS:
 * Linehaul revenue money as an output parm
 *
 * RESULT SETS: 
*   None *
 * PARAMETERS:
 * 001 - @pl_pyhnumber int 
 * 002 - @pdec_lhrevenue money output
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 01/31/06 JD  Created PTS 29579
 * 03/04/2014	PTS 75812:	CreditMemo/Rebill causes backed out pay/ select by move results in doubled values (too much pay)
 *
 **/
-- select @pdec_lhrevenue = sum(ivh_charge) from invoiceheader where mov_number in 
--(select distinct mov_number from paydetail where pyh_number = @pl_pyhnumber and mov_number > 0)
 
 declare @payHeaderCount	int
 select @payHeaderCount = count(distinct(pyh_number)) 
							from paydetail 
							where mov_number in ( (select distinct mov_number from paydetail where pyh_number = @pl_pyhnumber and mov_number > 0)  )

set @pdec_lhrevenue = 0							
if @payHeaderCount > 1 
	begin		
		select @pdec_lhrevenue = sum(ivh_charge) from invoiceheader where ivh_hdrnumber in 
		(select distinct pyd_ivh_hdrnumber from paydetail where pyh_number = @pl_pyhnumber and mov_number > 0 and pyd_ivh_hdrnumber > 0)
		if @pdec_lhrevenue is NULL select @pdec_lhrevenue = 0
	end							
else
	begin 
	--  ORIGINAL CODE (should be OK if count = 1)	
			select @pdec_lhrevenue = sum(ivh_charge) from invoiceheader where mov_number in 
			(select distinct mov_number from paydetail where pyh_number = @pl_pyhnumber and mov_number > 0)
			if @pdec_lhrevenue is NULL select @pdec_lhrevenue = 0
end

return @pdec_lhrevenue 
GO
GRANT EXECUTE ON  [dbo].[get_linehaul_revenue_by_payperiod_sp] TO [public]
GO
