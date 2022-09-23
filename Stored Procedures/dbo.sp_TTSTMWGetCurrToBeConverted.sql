SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE    Procedure [dbo].[sp_TTSTMWGetCurrToBeConverted](@targeted_currency as char(20))
as

--*************************************************************************
--Get All Currencies that will be more then likely converted to
--a given targeted currency or base currency
--*************************************************************************

Select Distinct ord_currency from OrderHeader
Where ord_currency is Not Null and ord_currency <> '?' and ord_currency <> @targeted_currency












GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWGetCurrToBeConverted] TO [public]
GO
