SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nc_remove_item_from_nc_system] 
(
    @item_type varchar(3), 
    @cmp_id varchar(8), @num_id int
)

AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Remove a email recipient or a company/group from the nc email system.

exec nc_remove_item_from_nc_system 'cmp', 'B', 0

*/

BEGIN

    if @item_type = 'idv'
    begin
        begin transaction
        delete nce_email_info where ncee_email_person_id = @num_id
        if @@error <> 0 begin
            rollback transaction
            return
        end
    
        delete nce_group_membership where ncem_email_person_id = @num_id
        if @@error <> 0 begin
            rollback transaction
            return
        end
    
        delete nce_company_info
        where ncec_cmp_child_id = convert(varchar(8), @num_id)
       
        if @@error <> 0 begin
            rollback transaction
            return
        end
        else
            commit transaction
    end
    else if @item_type = 'grp'
    begin
        begin transaction
        delete nce_groups where nceg_group_id = @num_id
        if @@error <> 0 begin
            rollback transaction
            return
        end
    
        delete nce_group_membership where ncem_group_id = @num_id
        if @@error <> 0 begin
            rollback transaction
            return
        end
    
        delete nce_company_info
        where ncec_cmp_child_id = convert(varchar(8), @num_id)
    
        if @@error <> 0 begin
            rollback transaction
            return
        end
        else
            commit transaction
    end
    else if @item_type = 'cmp'
    begin
        begin transaction
        delete nce_company_info where ncec_cmp_child_id = @cmp_id
        if @@error <> 0 begin
            rollback transaction
            return
        end
    
        update nce_company_info
           set ncec_cmp_parent_id = 'UNKNOWN'
         where ncec_cmp_parent_id = @cmp_id
    
        if @@error <> 0 begin
            rollback transaction
            return
        end
        else
            commit transaction
    end
    
    return 0
END

GO
GRANT EXECUTE ON  [dbo].[nc_remove_item_from_nc_system] TO [public]
GO
