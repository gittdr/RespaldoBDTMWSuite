SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






















CREATE                    Function [dbo].[fnc_checkforvalidcurrencyconversion](@charge money,@currency varchar(25),@typeofcharge varchar(255),@referencnumber int,@currencydate datetime='',@shipdate datetime='',@deliverydate datetime='',@billdate datetime='',@revenuedate datetime='',@transferdate datetime='',@bookdate datetime='',@printdate datetime='',@transactiondate datetime='',@workperioddate datetime='',@payperioddate datetime='')	
RETURNS varchar (40)
AS
BEGIN

Declare @targeted_currency varchar(25)
Declare @currencydatetype as varchar(100)
Declare @transdate datetime --Date that transaction took place
			    --we will set this based on the
			    --type of the date the 
			    --user wants(what they consider
			    --the transaction date or date
			    --they want to use to look up
			    --exchange rate)
Declare @conversionstatus as varchar(255)
Declare @rate money

--Grab Targeted Currency from General Info (What currency we want to turn into)
Set @targeted_currency = (select ses_value from MR_SessionID where ses_key = 'ActiveTargetedCurrency' and ses_SPID = @@SPID )

--If the user has specified not to convert currency Or
--if the currency is the same as the targeted currency
--(doesn't need to be converted) then
--return the charge as it was passsed in and exit
If @targeted_currency = 'None' or @currency = @targeted_currency
Begin
	
	Set @conversionstatus = 'No Conversion Needed'
       
End
Else
Begin

	  --Set the type of charge variable so we can look up
	  --the correct date type based on if the lookup
	  --is either a billing charge or settlement pay
	  --or something else
	  Set @typeofcharge = 'CurrencyDateType' +  @typeofcharge

	  --Detect the date type we are using to convert currency
	  Set @currencydatetype = (select ses_value from MR_SessionID where ses_key = @typeofcharge and ses_SPID = @@SPID )

	  --Set the date were going to use to look up
	  --currency exchage rate information based on
	  --the date type the user has selected
	  SELECT @transdate =
	  	CASE @currencydatetype 
      	 		WHEN 'Currency Date' THEN @currencydate
			WHEN 'Ship Date' THEN @shipdate
			WHEN 'Delivery Date' THEN @deliverydate
			WHEN 'Bill Date' THEN @billdate
			WHEN 'Revenue Date' THEN @revenuedate
			When 'Transfer Date' THEN @transferdate
      	  		When 'Book Date' THEN @transferdate
			When 'Print Date' THEN @printdate
			When 'Transaction Date' THEN @transactiondate
			When 'Work Period Date' THEN @workperioddate
			When 'Pay Period Date' THEN @payperioddate
			Else @currencydate --use currency date if nothing is found
		END 
		

	 Select @conversionstatus =
	 Case When (Select cex_rate from currency_exchange a 
                                                where a.cex_date = 
                                                                 (Select  Max(cex_date) from currency_exchange b
                                                                  where @transdate >= cex_date and cex_from_curr = @currency and cex_to_curr = @targeted_currency )
					        and
					        cex_from_curr = @currency
                                                and 
                                                cex_to_curr = @targeted_currency) Is Null Then 'Conversion Successful' Else 'Currency Rate Not Available' End
	 

		
						
End
	  
   Return @conversionstatus
	
End





















GO
