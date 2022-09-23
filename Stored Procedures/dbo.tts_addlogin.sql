SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.tts_addlogin    Script Date: 6/1/99 11:54:05 AM ******/
create procedure [dbo].[tts_addlogin]( 	@user_id varchar(20),
									  			@user_pw varchar(20),
									  			@default_db varchar(20))		
as

declare
	@sp_status			int,
	@errmsg				varchar(80)


/* ADD NEW LOGIN ID TO DTATBASE. IF ERROR OCCURS RETURN */
	exec @sp_status = sp_addlogin @user_id, @user_pw, @default_db 
	if @sp_status != 0 
		begin
		select @errmsg = @errmsg + "Error Executing sp_addlogin. New user has not been addded. Return code: " + CONVERT(char(2),@sp_status)
		RAISERROR 30000 @errmsg
		return -1	
		end


/* IF ADDLOGIN SUCCEEDS ADD USER TO DATABASE. IF AN ERROR OCCURS ATTEMPT TO DROP THE 
	LOGIN AND RETURN */

	exec @sp_status =  sp_adduser @user_id
	if @sp_status != 0 
		BEGIN
		select @errmsg = "Error Executing sp_adduser. User has not been Added. Return Code: " +  CONVERT(varchar(20),@sp_status)
		RAISERROR 30000 @errmsg 		
		
		exec @sp_status = sp_droplogin @user_id
		if @sp_status != 0 
			BEGIN
			select @errmsg = "Sp_adduser Error. User Login " + @user_id + " has been added but not the user id.  Return code: " +  CONVERT(varchar(20),@sp_status)
			RAISERROR 30001 @errmsg 			
			end

		RETURN -1
		end 


return 0



GO
GRANT EXECUTE ON  [dbo].[tts_addlogin] TO [public]
GO
