SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  Procedure [dbo].[SSRS_RB_CONFIRM_PAYDETAILS_02]
		
	@p_lghnumber int

AS

 
SELECT		ISNULL(	paydetail.pyd_amount,0)as pyd_amount,
			paytype.pyt_description,
			paydetail.pyd_quantity,
			paydetail.pyd_rate,
			paydetail.pyt_itemcode,
			paydetail.pyd_unit,
			paydetail.pyd_refnum,
			paydetail.pyd_amount,
			paydetail.pyt_fee1,
			paydetail.pyt_fee2,
			paydetail.tar_tarriffnumber,
			paydetail.pyd_carinvnum,
			paydetail.pyd_authcode
	

        
FROM
			paydetail
			join paytype on paytype.pyt_itemcode=Paydetail.pyt_itemcode
         

WHERE		Paydetail.lgh_number = @p_lghnumber
          	AND paydetail.asgn_type = 'CAR'
			AND paydetail.pyd_amount <> 0




GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_CONFIRM_PAYDETAILS_02] TO [public]
GO
