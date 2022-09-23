SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  Procedure [dbo].[SSRS_RB_CONFIRM_PAYDETAILS_01]
	@p_lghnumber int
AS
 
SELECT	ISNULL(	pd.pyd_amount,0)as pyd_amount,
		pt.pyt_description,
		pd.pyd_quantity,
		pd.pyd_rate,
		pd.pyt_itemcode,
		pd.pyd_unit,
		pd.pyd_refnum,
		pd.pyd_amount,
		pd.pyt_fee1,
		pd.pyt_fee2,
		pd.tar_tarriffnumber,
		pd.pyd_carinvnum,
		pd.pyd_authcode
FROM paydetail pd 
JOIN paytype pt
	ON pd.pyt_itemcode = pt.pyt_itemcode
WHERE pd.lgh_number = @p_lghnumber
AND pd.asgn_type = 'CAR'
AND pd.pyd_amount <> 0


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_CONFIRM_PAYDETAILS_01] TO [public]
GO
