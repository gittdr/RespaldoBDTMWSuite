SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.tts_droplogin    Script Date: 6/1/99 11:54:05 AM ******/
create procedure [dbo].[tts_droplogin]( 	@user_id varchar(20),
												@user_pw varchar(20), 
												@default_db varchar(20))

as
declare

@errmsg 				varchar(40),
@sp_status			int

	exec @sp_status = sp_dropuser @user_id 
	if @sp_status != 0 
		begin
		select @errmsg =  "Error Executing sp_dropuser. Return code: 'CONVERT(varchar(20),@sp_status)'"
		RAISERROR 30000 @errmsg
		return -1
		end


	exec @sp_status = sp_droplogin  @user_id 
	if @sp_status != 0 
		BEGIN
		select @errmsg = "Error Executing sp_droplogin. User has not been dropped. Return Code: " +  CONVERT(varchar(20),@sp_status)
		RAISERROR 30000 @errmsg 		
		
		exec @sp_status = sp_adduser @user_id, @user_pw, @default_db
		if  @sp_status != 0 
			BEGIN
			select @errmsg = "Sp_droplogin Error. User id " + @user_id + " has been dropped but not the login id.  Return code: " +  CONVERT(varchar(20),@sp_status)
			RAISERROR 30001 @errmsg 			
			end

		return -1
		END

	return 0



GO
GRANT EXECUTE ON  [dbo].[tts_droplogin] TO [public]
GO
