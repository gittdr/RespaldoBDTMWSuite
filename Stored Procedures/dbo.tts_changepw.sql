SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.tts_changepw    Script Date: 6/1/99 11:54:05 AM ******/
create procedure [dbo].[tts_changepw] (@old_pw 	varchar(20),
											 @new_pw		varchar(20))

as

declare 
		@sp_status 		int,
		@errmsg			varchar(80)

exec @sp_status = sp_password @old_pw, @new_pw

	if @sp_status != 0 
		begin
		select @errmsg =  "Error Executing sp_password. Old: " + @old_pw + " new: " + @new_pw
		RAISERROR 30000 @errmsg
		return -1
		end


return 0



GO
GRANT EXECUTE ON  [dbo].[tts_changepw] TO [public]
GO
