SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE      Procedure [dbo].[sp_TTSTMWObjectScannerDecisionLayer](@SituationToTest varchar(255),@nameconvention as varchar(8000)='vTTSTMW',@objecttype as varchar (25)= 'V',@formattype as varchar(8000)='<TTS!*!TMW>')
--Exec sp_TTSTMWObjectScannerDecisionLayer 'EnablingCurrencyFunctionality'

As

Declare @tokenkey varchar(8000)
Declare @errornumber int
Declare @ExecuteScanYN char(1)

Set     @tokenkey = '' 
Set     @ExecuteScanYN = 'N'

Select  @tokenkey =

	--Decide on Activating token key based on the situation
	Case When @SituationToTest = 'EnablingCurrencyFunctionality' Then
			--Test to see if currency is enabled and the SQL Version 
			--is higher then SQL 7(Run Scanner if > 7 and currency is enabled)
			Case When (Select gi_value from MR_GeneralInfo where gi_key = 'EnableCurrencyConverting') = 'True' and Left(Substring(@@version,23,4),1) <> '7' Then  
				'SQLVersion'
			Else
				''
			End
	     
	     When @SituationToTest = 'EnableEuroFeaturePack' Then
		      --Test to see if we need to enable euro feature pack functionality	
			Case When (Select min(language) from TMWReportActiveLanguage) = 'Euro' Then  
				'FeaturePack'
			Else
				''
			End			
	     When @SituationToTest = 'SQLOptimizedForVersion' Then
			Case When Left(Substring(@@version,23,4),1) <> '7' Then  
				'SQLOptimizedForVersion'
			Else
				''
			End

	End


	If @tokenkey = ''
	   Begin
		Set @ExecuteScanYN = 'N'
		--scan didn't run
	   End	
	   Else
	   Begin
		Set @ExecuteScanYN = 'Y'
		exec sp_TTSTMWObjectScanner @nameconvention,@objecttype,@tokenkey,'' 
	   End

	IF (@@ERROR <> 0)  --Return error if any
	   Begin
   		SET @errornumber = @@ERROR
	   End
        
        IF @@Error = 0 --No errors so set error message = 0
	   Begin
		Set @errornumber = 0
	   End
	
	
	Select @errornumber as ErrNumber,@ExecuteScanYN as ExecuteScanYN
	









GO
