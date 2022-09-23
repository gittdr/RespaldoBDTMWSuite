SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[nc_get_all_contacts_for_a_comp]
(
    @cmp_id     varchar(8),
    @ord_branch varchar(6)
)
AS


/* Change Control

TGRIFFIT 38834 02/12/2008 created this stored procedure. Get all contacts from the given company and its parent company


create table #contact
(   ori_cmp_id    varchar(8)   null,
    cmp_id        varchar(8)   null,
    contact_name  varchar(255) null,
    email_address varchar(255) null,
    email_type    char(1)      null,
    contact_id    int          null 
)

exec nc_get_all_contacts_for_a_comp 'Z10CAL'

select * from #contact

drop table #contact


*/

BEGIN

    declare
        @seq_no numeric(5, 0),
        @parent_id varchar(8),
        @contact_type char(1),
        @contact_id int,
        @match_level  char(1)
    
    create table #company
    (seq_no numeric(5,0) IDENTITY NOT NULL,
     parent_id varchar(8)NOT NULL,
     contact_type char(1) NOT NULL,
     contact_id int NOT NULL
    )
    
    insert into #company (parent_id, contact_type, contact_id)
    Select  ncec_cmp_parent_id,
            ncec_contact_type,
            convert(int, ncec_cmp_child_id)
      from  nce_company_info
     where  ncec_cmp_parent_id = @cmp_id
       and 	ncec_contact_type in ('I','G')
    
    If @@rowcount < 1 return 0
    
    select @seq_no = 0
    
    select @seq_no = min(seq_no)
      from #company
    
    while (@seq_no <> null)
    begin
    
        select 	@parent_id = parent_id,
                @contact_type = contact_type,
                @contact_id  = contact_id
        from	#company
        where   seq_no = @seq_no
    
        If upper(@contact_type) = 'I'
             insert into #contact
             select null,
                    @cmp_id,
                    case when ncee_email_type = 'I'
                         then ncee_int_usr_userid
                         else ncee_ext_description end,
                    ncee_email_address,
                    ncee_email_type,
                    @contact_id
               from nce_email_info
              where ncee_email_person_id = @contact_id
        else
        BEGIN
             insert into #contact
             select null,
                    @cmp_id,
                    ncee_ext_description,
                    ncee_email_address,
                    ncee_email_type,
                    @contact_id 
               from nce_email_info
                   INNER JOIN nce_group_membership
                   ON ncee_email_person_id = ncem_email_person_id
              where ncem_group_id = @contact_id
                and ncee_email_type = 'E'
    
            select @match_level = isnull(upper(match_level), 'N')
              from nce_groups
             where nceg_group_id = @contact_id
    
            If @match_level = 'B'
    
                 insert into #contact
                 select null,
                        @cmp_id,
                        ncee_int_usr_userid,
                        ncee_email_address,
                        ncee_email_type,
                        @contact_id 
                   from nce_email_info
                        INNER JOIN nce_group_membership
                        ON ncee_email_person_id = ncem_email_person_id
                        INNER JOIN ttsusers
                        ON ncee_int_usr_userid  = usr_userid
                  where ncee_email_type      = 'I'
                    and usr_type1            = @ord_branch
                    and ncem_group_id        = @contact_id
    
             Else if @match_level = 'R'
                 insert into #contact
                 select null,
                        @cmp_id,
                        ncee_int_usr_userid,
                        ncee_email_address,
                        ncee_email_type,
                        @contact_id 
                   from nce_email_info
                        INNER JOIN nce_group_membership
                        ON ncee_email_person_id = ncem_email_person_id
                        INNER JOIN ttsusers
                        ON ncee_int_usr_userid  = usr_userid
                        INNER JOIN branch userbranch
                        ON usr_type1 = userbranch.brn_id
                        INNER JOIN branch orderbranch
                        ON userbranch.brn_orgtype2 = orderbranch.brn_orgtype2
                  where ncee_email_type      = 'I'
                    and orderbranch.brn_id   = @ord_branch
                    and ncem_group_id        = @contact_id
    
             Else if @match_level = 'D'
                 insert into #contact
                 select null,
                        @cmp_id,
                        ncee_int_usr_userid,
                        ncee_email_address,
                        ncee_email_type,
                        @contact_id 
                   from nce_email_info
                        INNER JOIN nce_group_membership
                        ON ncee_email_person_id = ncem_email_person_id
                        INNER JOIN ttsusers 
                        ON ncee_int_usr_userid = usr_userid
                        INNER JOIN branch userbranch
                        ON usr_type1  = userbranch.brn_id
                        INNER JOIN branch orderbranch
                        ON userbranch.brn_orgtype3 = orderbranch.brn_orgtype3 
                  where ncee_email_type      = 'I'
                    and orderbranch.brn_id   = @ord_branch
                    and ncem_group_id        = @contact_id
             Else
                 insert into #contact
                 select null,
                        @cmp_id,
                        ncee_int_usr_userid,
                        ncee_email_address,
                        ncee_email_type,
                        @contact_id 
                   from nce_email_info
                        INNER JOIN nce_group_membership
                        ON ncee_email_person_id = ncem_email_person_id
                  where ncee_email_type      = 'I'
                    and ncem_group_id        = @contact_id
    
        END  -- else for If @contact_type = 'I'
    
        select @seq_no = min(seq_no)
          from #company
         where seq_no > @seq_no
    end
    
    drop table #company
    
    Select  @parent_id = ncec_cmp_parent_id
      from  nce_company_info
     where  ncec_cmp_child_id = @cmp_id
    
    if @parent_id <> 'UNKNOWN'
    begin
        EXEC nc_get_all_contacts_for_a_comp @parent_id, @ord_branch
    end
    
    return 0

END
GO
GRANT EXECUTE ON  [dbo].[nc_get_all_contacts_for_a_comp] TO [public]
GO
