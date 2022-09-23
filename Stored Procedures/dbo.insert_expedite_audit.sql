SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46566 JJF 20121009 - add exp_idtype/id
create proc [dbo].[insert_expedite_audit] @activity varchar(20), @update_note varchar(255),
		 @key_value varchar(100), @join_to_table_name varchar(40), @exp_idtype varchar(3) = NULL, @exp_id varchar(13) = NULL as

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--PTS 46566 JJF 20121009 - add exp_idtype/id
insert into expedite_audit
			(ord_hdrnumber
			,updated_by
			,activity
			,updated_dt
			,update_note
			,key_value
			,mov_number
			,lgh_number
			,join_to_table_name
			,exp_idtype
			,exp_id)
values
			(0
			,@tmwuser
			,@activity
			,getdate()
			,@update_note
			,@key_value
			,0
			,0
			,@join_to_table_name
			,@exp_idtype
			,@exp_id)


GO
GRANT EXECUTE ON  [dbo].[insert_expedite_audit] TO [public]
GO
