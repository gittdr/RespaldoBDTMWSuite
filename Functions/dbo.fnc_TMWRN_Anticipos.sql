SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_TMWRN_Anticipos] 
(
	@Mode varchar(255) = 'Segment',
	@MilesToAllocate int = Null,
	@MoveMiles int = Null,
	@MoveNumber int = Null,
	@OrderHeaderNumber int = Null,
	@LegHeaderNumber int = Null,
	@IncludePayTypeList varchar(255) = '',
	@ExcludePayTypeList  varchar(255) = '',
	@PreTax char(1) = 'Y', --set to NULL if trying to get all postive and negative paydetails,
	--Y is for all taxable compensation paydetails
	--N is for all non taxable paydetails
	@MinusFlag int = NULL --set to 1 if trying to get all positive paydetails regardless if it is taxed
	--set to -1 if trying to get all negative paydetails regardless  if it is taxed
	
)

RETURNS Money
AS

/*	Revision History
		5/21/2008: Corrected initialization of @IncludePayTypeList and @ExcludePayTypeList
*/

BEGIN

	SELECT @IncludePayTypeList =	Case When Left(@IncludePayTypeList,1) <> ',' Then 
										',' + LTRIM(RTRIM(ISNULL(@IncludePayTypeList, ''))) + ',' 
									Else
										@IncludePayTypeList
									End
	SELECT @ExcludePayTypeList =	Case When Left(@ExcludePayTypeList,1) <> ',' Then 
										',' + LTRIM(RTRIM(ISNULL(@ExcludePayTypeList, ''))) + ',' 
									Else
										@ExcludePayTypeList
									End


	Declare @Pay Money



	--2000 and higher Currency Convert Code
	Set @Pay = IsNull((
				select (-1) * (sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) )
				from paydetail (NOLOCK) 
				where ((@Mode = 'Segment' or @Mode = 'LegHeader') And lgh_number=@LegHeaderNumber)
					
                   --And	(
					--		(@PreTax Is Not Null And pyd_pretax = @PreTax)
					--			Or
					--		(@PreTax Is Null)
					--	)

                    And pyt_itemcode in ('VIATIC','ANTOP','ANTER','ANTMAN')
					And	(
							(@MinusFlag Is Not Null and pyd_minus = @MinusFlag)
								Or
							(@MinusFlag Is Null)
						)
					And (@ExcludePayTypeList = ',,' OR Not (CHARINDEX(',' + RTRIM( pyt_itemcode ) + ',', @ExcludePayTypeList) > 0)) 
					And (@IncludePayTypeList = ',,' OR (CHARINDEX(',' + RTRIM( pyt_itemcode ) + ',', @IncludePayTypeList) > 0)) 
				),0.00) 

	Return @Pay


END

GO
