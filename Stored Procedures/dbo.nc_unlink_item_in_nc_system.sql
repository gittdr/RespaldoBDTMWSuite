SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nc_unlink_item_in_nc_system]
( 
    @item_type varchar(3),   
    @parent_id varchar(8),
    @cmp_id    varchar(8),
    @group_id   int,
    @contact_id int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Unlink a email recipient or a company/group  from its parent

exec nc_unlink_item_in_nc_system 'cmp', 'B', 0

*/

BEGIN

    begin transaction
    
    if @item_type = 'idv' and @contact_id > 0
    begin
        if @group_id > 0
            delete nce_group_membership
             where ncem_email_person_id = @contact_id
               and ncem_group_id = @group_id
    
        else if @cmp_id <> null and  @cmp_id <> ''
        begin
    
            delete nce_company_info
            where ncec_cmp_child_id = convert(varchar(8), @contact_id)
            and ncec_cmp_parent_id = @parent_id
    
        end
        else
            return -1
    
    end
    else if @item_type = 'grp' and @cmp_id <> null and  @cmp_id <> '' and @group_id > 0
    
        delete nce_company_info
        where ncec_cmp_child_id = convert(varchar(8), @group_id)
        and ncec_cmp_parent_id = @parent_id
    
    else if @item_type = 'cmp' and @parent_id <> null and 
        @parent_id <> ''  and @cmp_id <> null and  @cmp_id <> ''
    begin
        begin transaction
    
        delete nce_company_info
        where ncec_cmp_child_id = convert(varchar(8), @cmp_id)
        and ncec_cmp_parent_id = @parent_id
    
        if @@error <> 0 begin
           rollback transaction
           return
        end
    
        -- reset the parent
        update nce_company_info
        set ncec_cmp_parent_id = @parent_id
        where ncec_cmp_parent_id = @cmp_id
       
        if @@error <> 0 begin
           rollback transaction
           return
        end
    
        -- As a result of the above, the Root may have contacts associated with it
        -- which is incorrect. This statement will delete these...
    
        delete nce_company_info
        where ncec_cmp_parent_id = 'UNKNOWN'
        and ncec_contact_type in ('G','I')
    
        if @@error <> 0
        begin
          rollback transaction
          return
        end
        else
          commit transaction
    end
    else
        return -2
    
    /****************************************************************************/
    
    if @@error <> 0 begin
        rollback
        return -3
    end
    else
        commit
    
    return 0

END
GO
GRANT EXECUTE ON  [dbo].[nc_unlink_item_in_nc_system] TO [public]
GO
