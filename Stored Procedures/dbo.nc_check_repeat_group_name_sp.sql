SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[nc_check_repeat_group_name_sp] 
(
    @group_id int, 
    @group_name varchar(255)
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Check if the given name is already used.

exec nc_check_repeat_group_name_sp 2, 'Second Group'

*/

BEGIN

    declare @ret int
    
    If exists (select 1 from  nce_groups where nceg_group_name = @group_name and nceg_group_id <> @group_id)
        select @ret = 1
    Else
        select @ret = 0
    
    return @ret

END
GO
GRANT EXECUTE ON  [dbo].[nc_check_repeat_group_name_sp] TO [public]
GO
