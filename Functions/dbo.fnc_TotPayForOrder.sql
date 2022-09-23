SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TotPayForOrder]
(
	@OrderHeaderNumber int,
	@ExcludePayTypeListOnly varchar(255)
)

--Revision History
--1. Added Currency Converting Logic Ver 5.4 LBK
 

RETURNS Money
AS
BEGIN

	Declare @LghMiles float
	Declare @MovMiles float
	Declare @PercentMilesThisSeg float
	Declare @OrdHdrnumber int
	Declare @OrdRev money
	Declare @CountLegHeaderNoMiles int
	Declare @Pay money

	Declare @AllocatedRev money
	Declare @IncludeChargesOnly money

	SELECT @ExcludePayTypeListOnly = Case When Left(@ExcludePayTypeListOnly,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludePayTypeListOnly, ''))) + ',' End

	Set @Pay = IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  ord_hdrnumber=@OrderHeaderNumber
               			and 
               			pyd_minus = 1
	       			and
	       			(@ExcludePayTypeListOnly = ',,' OR Not (CHARINDEX(',' + RTRIM( rtrim(pyt_itemcode) ) + ',', @ExcludePayTypeListOnly) > 0)) 
			)
	,0.00)

			

	Return @Pay


END

GO
GRANT EXECUTE ON  [dbo].[fnc_TotPayForOrder] TO [public]
GO
