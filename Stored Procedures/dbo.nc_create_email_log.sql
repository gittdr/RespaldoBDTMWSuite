SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[nc_create_email_log] 
(
    @ord_hdrnumber int,
    @sf_sequence int
)

AS

/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Used to log details of Non-conformance emails sent.


exec nc_create_email_log 7500620, 1

*/

BEGIN

    create table #contact_log
    (   cmp_id          varchar(8)      null,
        cmp_name        varchar(30)     null,
        stp_type        varchar(10)     null,
        stp_seq         int             null,
        cmp_id2         varchar(8)      null,
        contact_name    varchar(255)    null,
        email_address   varchar(255)    null,
        email_type      char(1)         null,
        contact_id      int             null
    )
    
    --populate temp table by SP call...  
    insert #contact_log EXEC d_get_nc_contacts_for_an_order @ord_hdrnumber
    
    insert nce_email_log
    (   ncee_email_person_id,
        orig_cmp_id,
        parent_cmp_id,
        ord_hdrnumber,  
        sf_sequence_number,  
        ncee_email_address,    
        created,
        created_by  )
   select 
        contact_id,
        cmp_id,
        cmp_id2,
        @ord_hdrnumber,
        @sf_sequence,
        email_address,
        GETDATE(),
        SUSER_SNAME()
   from #contact_log
    
   drop table #contact_log
       
END
GO
GRANT EXECUTE ON  [dbo].[nc_create_email_log] TO [public]
GO
