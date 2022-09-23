SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nc_get_parent_cmpid_candidate] 
(
    @cmp_id varchar(8)
)
AS


/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get all NC cmp_id excluding the given cmp_id and its children.


exec nc_get_parent_cmpid_candidate 'X'

*/

BEGIN

    declare   @parent_id varchar(8)
    
    create table #children
    (   cmp_id    varchar(8)   not null,
        checked   char(1)      not null
    )
    
    insert #children values (@cmp_id, 'N')
    
    select @parent_id = @cmp_id
    
    while @parent_id <> null
    begin
        insert #children
        select ncec_cmp_child_id, 'N' from nce_company_info where ncec_cmp_parent_id = @parent_id
    
        update #children set checked = 'Y' where cmp_id = @parent_id
    
        select @parent_id = min(cmp_id) from #children where checked = 'N'
    end
    
    select ncec_cmp_child_id
    from nce_company_info p
    where not exists (select 1 from #children where  cmp_id = p.ncec_cmp_child_id)
    
    union
    select 'UNKNOWN'
    
    return 0
    
END
GO
GRANT EXECUTE ON  [dbo].[nc_get_parent_cmpid_candidate] TO [public]
GO
