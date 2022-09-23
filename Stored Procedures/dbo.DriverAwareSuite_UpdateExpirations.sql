SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE       Procedure [dbo].[DriverAwareSuite_UpdateExpirations] (@Exp_key int,
						 @Exp_ID varchar(13)='UNKNOWN',
						 @Exp_IDType char(3)='',
						 @Exp_expirationdate datetime,
						 @Exp_compldate datetime,
						 @Exp_Code varchar(6)='UNK',
						 @Exp_completed char(1) = 'N',
						 @Exp_priority varchar(6)='1',	
						 @Exp_description varchar(100)='',
						 @Exp_city int = 0,
						 @Exp_routeto varchar(255)='UNKNOWN',
						 @Exp_updateby varchar(255)=''
						)
As

Set NOCount On

if exists (select exp_key from expiration (NOLOCK) where exp_key = @Exp_key)

	Update expiration
	Set    exp_id = Exp_ID,
	       exp_idtype = @Exp_IDType,
	       exp_expirationdate = @Exp_expirationdate,
	       exp_compldate = @Exp_compldate,
	       exp_code = @Exp_Code,
	       exp_completed = @Exp_completed,
	       exp_priority = @Exp_priority,
	       exp_description = @Exp_description,
	       exp_city = @Exp_City,
	       exp_routeto = @Exp_RouteTo,
	       exp_updateby = @Exp_updateby,
	       exp_updateon = getdate()
        Where  exp_key = @Exp_key
	       
else
	Insert into expiration (exp_id,exp_idtype,exp_expirationdate,exp_compldate,exp_code,exp_completed,exp_priority,exp_description,exp_city,exp_routeto,exp_updateby,exp_updateon,exp_creatdate) 
	Values (@Exp_ID,@Exp_IDType,@Exp_expirationdate,@Exp_compldate,@Exp_code,@Exp_completed,@Exp_priority,@Exp_description,@Exp_city,@Exp_routeto,@Exp_updateby,getdate(),getdate())
    





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_UpdateExpirations] TO [public]
GO
