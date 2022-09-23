SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE     FUNCTION [dbo].[fnc_PayForLeg]
	(@lgh_number int)

RETURNS Money
AS
BEGIN


Declare @LegPay Money

--Base Level Code
--Set @LegPay =(Select sum(pyd_amount) from paydetail (NOLOCK) where lgh_number=@lgh_number and pyd_minus = 1)

--2000 and higher Currency Convert Code
Set @LegPay = IsNull((select sum(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0)) from paydetail (NOLOCK) where lgh_number=@lgh_number and pyd_minus = 1),0.00) 


Return @LegPay


END






GO
