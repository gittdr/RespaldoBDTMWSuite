SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE        Procedure [dbo].[WatchDogPopulateSessionIDParamaters](@CurrencyDateTypeOfCharge varchar(255),@WatchName varchar(255))

As
SET NOCOUNT ON
Declare @DefaultCurrencyKey varchar(255)
Declare @DefaultCurrencyValue varchar(255)
Declare @CurrencyDateTypeKey varchar(255)
Declare @CurrencyDateTypeValue varchar(255)

Set @DefaultCurrencyKey = 'ActiveTargetedCurrency'
Set @DefaultCurrencyValue = (Select DefaultCurrency from WatchDogItem where WatchName = @WatchName)
Set @CurrencyDateTypeKey = 'CurrencyDateType' + @CurrencyDateTypeOfCharge
Set @CurrencyDateTypeValue = (Select CurrencyDateType from WatchDogItem where WatchName = @WatchName)

--Delete any previous entries for the session id we are about to use before inserting
Delete from MR_SessionID where ses_SPID = @@SPID
Delete from MR_SessionID where ses_SPID = @@SPID   
      

Insert into MR_SessionID (ses_SPID,ses_key,ses_value) Values (@@SPID,@DefaultCurrencyKey,@DefaultCurrencyValue)
Insert into MR_SessionID (ses_SPID,ses_key,ses_value) Values (@@SPID,@CurrencyDateTypeKey,@CurrencyDateTypeValue)



GO
