SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[PopulateSessionIDParamatersInProc]
(
	@CurrencyDateTypeOfCharge varchar(255),
	@MetricCode varchar(255)
)

As

Declare @DefaultCurrencyKey varchar(255)
Declare @DefaultCurrencyValue varchar(255)
Declare @CurrencyDateTypeKey varchar(255)
Declare @CurrencyDateTypeValue varchar(255)

Set @DefaultCurrencyKey = 'ActiveTargetedCurrency'
Set @DefaultCurrencyValue = (Select RNIDefaultCurrency from MetricItem where MetricCode = @MetricCode)
Set @CurrencyDateTypeKey = 'CurrencyDateType' + @CurrencyDateTypeOfCharge
Set @CurrencyDateTypeValue = (Select RNICurrencyDateType from MetricItem where MetricCode = @MetricCode)

--Delete any previous entries for the session id we are about to use before inserting
Delete from MR_SessionID where ses_SPID = @@SPID

Insert into MR_SessionID (ses_SPID,ses_key,ses_value) Values (@@SPID,@DefaultCurrencyKey,@DefaultCurrencyValue)
Insert into MR_SessionID (ses_SPID,ses_key,ses_value) Values (@@SPID,@CurrencyDateTypeKey,@CurrencyDateTypeValue)

--Execute MetricProcessing
GO
GRANT EXECUTE ON  [dbo].[PopulateSessionIDParamatersInProc] TO [public]
GO
