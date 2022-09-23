SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TotPayForMove]
(
	@MoveNumber int,
	@ExcludePayTypeListOnly varchar(255),
	@IncludePayTypeListOnly varchar (255)
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

	SELECT @IncludePayTypeListOnly = Case When Left(@IncludePayTypeListOnly,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludePayTypeListOnly, ''))) + ',' Else @IncludePayTypeListOnly End
	SELECT @ExcludePayTypeListOnly = Case When Left(@ExcludePayTypeListOnly,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludePayTypeListOnly, ''))) + ',' Else @ExcludePayTypeListOnly End

	Set @Pay = IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) 
				from   paydetail (NOLOCK) 
				where  mov_number=@movenumber 
               			and 
               			pyd_minus = 1
	       			and
					(@IncludePayTypeListOnly =',,' OR CHARINDEX(',' + RTRIM( pyt_itemcode ) + ',', @IncludePayTypeListOnly) >0)
					and
	       			(@ExcludePayTypeListOnly = ',,' OR Not (CHARINDEX(',' + RTRIM( pyt_itemcode ) + ',', @ExcludePayTypeListOnly) > 0)) 
			)
	,0.00)

			

	Return @Pay


END

GO
GRANT EXECUTE ON  [dbo].[fnc_TotPayForMove] TO [public]
GO
