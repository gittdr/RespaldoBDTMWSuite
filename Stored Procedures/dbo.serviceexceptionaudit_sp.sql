SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[serviceexceptionaudit_sp] (@pl_mov int, @sxn_sequence_number int) as

if @pl_mov > 0
begin
select sxn_mov_number,sxn_sequence_number,sxa_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm,'C'
from serviceexceptionaudit where sxn_mov_number = @pl_mov
union
select sxn_mov_number,sxn_sequence_number,0,'Deleted!',sxn_asgn_type,sxn_asgn_id, sxn_deletedby,sxn_deleteddate,'D'
from serviceexception where sxn_mov_number = @pl_mov and sxn_delete_flag = 'Y'
end
else
begin
select sxn_mov_number,sxn_sequence_number,sxa_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm,'C'
from serviceexceptionaudit where sxn_sequence_number = @sxn_sequence_number
union
select sxn_mov_number,sxn_sequence_number,0,'Deleted!',sxn_asgn_type,sxn_asgn_id, sxn_deletedby,sxn_deleteddate,'D'
from serviceexception where sxn_sequence_number = @sxn_sequence_number and sxn_delete_flag = 'Y'
end
GO
GRANT EXECUTE ON  [dbo].[serviceexceptionaudit_sp] TO [public]
GO
