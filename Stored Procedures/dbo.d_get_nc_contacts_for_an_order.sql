SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[d_get_nc_contacts_for_an_order]
(
    @ordnum int
)
AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get all the nc email recipients for an order

exec d_get_nc_contacts_for_an_order 3250303

*/

BEGIN

    create table #comp
    (   cmp_id   varchar(8)      null,
        cmp_name varchar(30)     null,
        stp_type varchar(10)     null,
        stp_seq  int             null
    )
    
    create table #contact
    (   ori_cmp_id    varchar(8)   null,
        cmp_id        varchar(8)   null,
        contact_name  varchar(255) null,
        email_address varchar(255) null,
        email_type    char(1)      null,
        contact_id    int          null --TGRIFFIT 21FEB08 used for logging purposes
    )
    
    declare @cmp_id varchar(8),
            @seq int,
            @brn_id varchar(6)
            
    /*******************************************************************************************************/
    Insert into #comp
    select distinct ord_billto, cmp_name, 'Bill To', 0
      from orderheader
      INNER JOIN company
      ON orderheader.ord_billto = company.cmp_id
     where orderheader.ord_hdrnumber = @ordnum
    
    Insert into #comp
    select cmp_id, cmp_name, stp_type, stp_mfh_sequence
      from stops
     where ord_hdrnumber = @ordnum
       and stp_type in ('PUP', 'DRP')
    
    -- Get Branch id
    select @brn_id = ord_revtype1 
      from orderheader
     where ord_hdrnumber = @ordnum
    
    -- processing each cmp_id
    
    select @seq = min(stp_seq) 
     from #comp
    
    while @seq is not null
    begin
    
        select @cmp_id = cmp_id 
          from #comp 
         where stp_seq = @seq
    
        exec nc_get_all_contacts_for_a_comp @cmp_id, @brn_id
    
        update #contact 
           set ori_cmp_id = @cmp_id 
         where ori_cmp_id is null
    
        select @seq = min(stp_seq) 
          from #comp 
         where stp_seq > @seq
    end
    
    
    insert #contact
    select cmp_id,
           cmp_id,
           'UNKNOWN',
           'UNKNOWN',
           '',
           0 
     from #comp 
    where not exists (select 1 
                        from #contact 
                       where ori_cmp_id = #comp.cmp_id)
    
    select distinct
           #comp.cmp_id,
           #comp.cmp_name,
           #comp.stp_type,
           #comp.stp_seq,
           #contact.cmp_id,
           contact_name,
           email_address,
           email_type,
           contact_id 
      from #comp
        INNER JOIN #contact
        ON #comp.cmp_id = #contact. ori_cmp_id
    
    drop table #comp
    drop table #contact
    
    return 0
END

GO
GRANT EXECUTE ON  [dbo].[d_get_nc_contacts_for_an_order] TO [public]
GO
