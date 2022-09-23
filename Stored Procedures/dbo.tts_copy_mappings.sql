SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.tts_copy_mappings    Script Date: 6/1/99 11:54:41 AM ******/
create procedure [dbo].[tts_copy_mappings]	@copy_user 	varchar(20),
													@user_id 	varchar(20) 
as

INSERT INTO ttsmappings  
    ( userid,   
      moduleid,   
      programid)  
           


select @user_id,
		 moduleid,
		 programid
from ttsmappings a
where a.userid = @copy_user 
		and not exists (select *
					 		from ttsmappings b
					 		where b.userid = @user_id
	 				 		and a.moduleid = b.moduleid 
					      and a.programid = b.programid)

return 



GO
GRANT EXECUTE ON  [dbo].[tts_copy_mappings] TO [public]
GO
