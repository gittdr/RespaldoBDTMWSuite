SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














CREATE     Procedure [dbo].[sp_TTSTMWGetAvailableCurrencies]
As

--*************************************************************************
--This Proc will allow users to see what 
--currencies are available to be converted into
--*************************************************************************



Select Distinct cex_to_curr from currency_exchange

union

select 'None'














GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWGetAvailableCurrencies] TO [public]
GO
