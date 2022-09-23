SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



















CREATE                  Function [dbo].[fnc_convertcharge](@charge money,@currency varchar(25),@typeofcharge varchar(255),@referencnumber int,@currencydate datetime='',@shipdate datetime='',@deliverydate datetime='',@billdate datetime='',@revenuedate datetime='',@transferdate datetime='',@bookdate datetime='',@printdate datetime='',@transactiondate datetime='',@workperioddate datetime='',@payperioddate datetime='')	
RETURNS Money
AS
BEGIN

Declare @ConvertedCharge money
Declare @targeted_currency varchar(25)
Declare @multiplyordivide varchar(30)
Declare @rate money
Declare @currencydatetype as varchar(100)
Declare @transdate datetime --Date that transaction took place
			    --we will set this based on the
			    --type of the date the 
			    --user wants(what they consider
			    --the transaction date or date
			    --they want to use to look up
			    --exchange rate)

--Grab Targeted Currency from General Info (What currency we want to turn into)
Set @targeted_currency = (select ses_value from MR_SessionID where ses_key = 'ActiveTargetedCurrency' and ses_SPID = @@SPID )

--If the user has specified not to convert currency Or
--if the currency is the same as the targeted currency
--(doesn't need to be converted) then
--return the charge as it was passsed in and exit
If @targeted_currency = 'None' or @currency = @targeted_currency
Begin
	
	Set @ConvertedCharge = @charge
       
End
Else
Begin

	  --See if we are going to multiply or divide the currency
	  --Retrieve from our Management Reporting General Info Table
	  Set @multiplyordivide = (select gi_value from MR_GeneralInfo where RTrim(gi_key) = 'CurrencyMultiplyOrDivide')

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
		


	  --Table Source represents if it came from billing,settlements,etc.
	  --Determine the transaction date type General Info
	  --Determine the transacation date by knowing the trans date type
	  --select to appropriate table by tying the reference number
	  --Determine if we should mutliply or divide the currency 		
	  --Gen Info

	  Set @rate =  IsNull((Select cex_rate from currency_exchange a 
                                                where a.cex_date = 
                                                                 (Select  Max(cex_date) from currency_exchange b
                                                                  where @transdate >= cex_date and cex_from_curr = @currency and cex_to_curr = @targeted_currency )
					        and
					        cex_from_curr = @currency
                                                and 
                                                cex_to_curr = @targeted_currency),1.00)

	  --Multiply or Divide based on general info setting
	  --Default install is Multiply
	  
	  --Divide if the user specified to divide in MR Gen Info
	  --They actually committed to one or another in the MR UI
	  --Actually stored in the MR Gen Info
	  If RTrim(@multiplyordivide) = 'Divide'
	  Begin
	     	--Check for Division by zero
		If @rate = 0
		Begin
		    --Since division by zero is not permitted just
		    --return the charge As Is
		    Set @ConvertedCharge = @charge
	  	End
		Else
		Begin
		    Set @ConvertedCharge = (@charge / @rate)
		End
	  End
          Else --We are defaulting to multiply if the 
	       --gen info setting is something other divide 
	  Begin	  
   	     Set @ConvertedCharge = (@charge * @rate)
	  End
		

	End

	Return @ConvertedCharge


End


















GO
