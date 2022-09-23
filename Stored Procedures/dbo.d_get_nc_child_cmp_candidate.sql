SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[d_get_nc_child_cmp_candidate]  
(
    @cur_cmpid varchar(8)
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get name for all the nc companies excluding the given cmp and its children 

exec d_get_nc_child_cmp_candidate 'ALLMID'

*/

BEGIN
    create table #parents ( cmp_id varchar(8))
    
    declare @child varchar(8), @parent varchar(8)
    
    select @parent = @cur_cmpid
    
    while @parent <> null and @parent <>  'UNKNOWN'
    begin
        insert #parents (cmp_id) values (@parent)
        select @parent = ncec_cmp_parent_id from nce_company_info where ncec_cmp_child_id = @parent 
    end
    
    select ncec_cmp_child_id  child_id, 
           ncec_cmp_parent_id parent_id,
           c.cmp_name         child_name,
           p.cmp_name         parent_name,
           c.cmp_billto       billto,
           c.cmp_shipper      shipper
    from nce_company_info a
        INNER JOIN company p 
            ON a.ncec_cmp_parent_id = p.cmp_id
        INNER JOIN company c 
            ON a.ncec_cmp_child_id  = c.cmp_id
    where a.ncec_contact_type = 'N'
       and not exists (select 1 from #parents pr where pr.cmp_id = a.ncec_cmp_child_id)
       and not exists (select 1 from nce_company_info b 
                        where b.ncec_cmp_child_id = a.ncec_cmp_child_id 
                          and (b.ncec_cmp_parent_id = @cur_cmpid or
                               b.ncec_cmp_child_id  = @cur_cmpid 
                               ))
    
    return 0
END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_child_cmp_candidate] TO [public]
GO
