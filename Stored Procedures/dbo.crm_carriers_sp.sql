SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[crm_carriers_sp] (@branch as varchar(12))
as
begin
	DECLARE @rowsecurity char(1)
	DECLARE @tbl_carrestrictedbyuser TABLE(Value VARCHAR(8))
	
	SELECT @rowsecurity = ISNULL(gi_string1, 'N') 
 	  FROM generalinfo 
	 WHERE gi_name = 'RowSecurity'

	IF @rowsecurity = 'Y' BEGIN
		INSERT INTO @tbl_carrestrictedbyuser
		SELECT * FROM  RowRestrictValidAssignments_carrier_fn()
	END
	
	create table #temp 
		(id varchar(8) primary key, 
		 name varchar(100), 
         address varchar(100), 
         city varchar(30), 
         state varchar(6), 
         zip varchar(10), 
		 agent_id varchar(8), 
		 agent_name varchar(100), 
		 executing_terminal varchar(12), 
		 executing_terminal_name varchar(100), 
		 crm_type varchar(6),
		 mcnumber varchar(12), 
		 active char(1), 
		 insurance_certificate char(1), 
		 insurance_certificate_w9 char(1), 
		 insurance_contract char(1), 
		 board char(1), 
		 first_open_activity datetime, 
		 last_complete_activity datetime, 
         type1 varchar(6), 
         type2 varchar(6), 
         type3 varchar(6), 
         type4 varchar(6) 
        )
	create index tmp_agent on #temp (agent_id)
	
	if @branch is null 
		set @branch = 'UNKNOWN' 
	
	declare @taskLinkEntityTableId int

	select @taskLinkEntityTableId = TASK_LINK_ENTITY_TABLE_ID 
	  from TASK_LINK_ENTITY_TABLE 
	 where TABLE_NAME = 'CARRIER' 

	declare @CRMExcludeUnassigned varchar(30)
	set @CRMExcludeUnassigned = 'N'
	select @CRMExcludeUnassigned = ISNULL(gi_string1,'N') from generalinfo where gi_name = 'CRMExcludeUnassigned'
	 
	insert into #temp (id, name, address, city, state, zip, 
		               agent_id, agent_name, executing_terminal, executing_terminal_name, crm_type, 
		               mcnumber, active, insurance_certificate, insurance_certificate_w9, insurance_contract, board, type1, type2, type3, type4) 
	select distinct c.car_id, isnull(c.car_name, ''), isnull(c.car_address1, ''), 
           case when city.cty_name is NULL or city.cty_name = 'UNKNOWN' 
                then '' else city.cty_name end, 
           case when city.cty_state is NULL or city.cty_state = 'UN' or city.cty_state = 'XX' 
                then '' else city.cty_state end, isnull(c.car_zip, ''), 
		   case when c.car_agent is NULL or c.car_agent = 'UNKNOWN' 
				then '' else c.car_agent end, 
		   case when c.car_agent is NULL or c.car_agent = 'UNKNOWN' 
		        then '' else t.tpr_name end, 
		   case when c.car_branch is NULL or c.car_branch in ('UNK', 'UNKNOWN') 
				then '' else c.car_branch end, 
		   case when b.brn_name is NULL or upper(b.brn_name) = 'UNKNOWN' 
				then '' else b.brn_name end, 
		   case when c.car_crmtype is NULL or c.car_crmtype = 'UNK' 
				then 'zzzzzz' else c.car_crmtype end, 
		   case when c.car_iccnum is NULL or c.car_iccnum = 'UNK' or rtrim(c.car_iccnum) = '' 
				then '' else c.car_iccnum end, 
           case when c.car_status is NULL or c.car_status = 'ACT' 
				then 'Y' else 'N' end, 
           isnull(c.car_ins_certificate, 'N'), isnull(c.car_ins_w9, 'N'), 
		   isnull(c.car_ins_contract, 'N'), isnull(c.car_board, 'N'), 
		   case when c.car_type1 is NULL or c.car_type1 = 'UNK' 
				then '' else c.car_type1 end, 
		   case when c.car_type2 is NULL or c.car_type2 = 'UNK' 
                then '' else c.car_type2 end, 
		   case when c.car_type3 is NULL or c.car_type3 = 'UNK' 
                then '' else c.car_type3 end, 
		   case when c.car_type4 is NULL or c.car_type4 = 'UNK' 
                then '' else c.car_type4 end 
	  from carrier c right outer join branch b on c.car_branch = b.brn_id 
                     join city on c.cty_code = city.cty_code
                     left outer join thirdpartyprofile t on c.car_agent = t.tpr_id  
                     left outer join CompanyCrmQuestionnaire q on c.car_id = q.CompanyId 
     where c.car_id <> 'UNKNOWN' 
       and isnull(c.car_branch, 'UNKNOWN') = @branch 
       and (EXISTS(select * FROM @tbl_carrestrictedbyuser carres WHERE c.car_id = carres.value) or @rowsecurity <> 'Y') 
	   and (ISNULL(car_branch, 'UNKNOWN') not in ('UNK', 'UNKNOWN') or @CRMExcludeUnassigned <> 'Y')
	
	update #temp 
       set first_open_activity = isnull((select min(DUE_DATE) 
                                           from TASK 
                                          where STATUS = 'OPEN' 
                                            and TASK_LINK_ENTITY_VALUE = #temp.id 
                                            and TASK_LINK_ENTITY_TABLE_ID = @taskLinkEntityTableId), 
                                        convert(datetime, '20491231 23:59')) 
	update #temp 
       set last_complete_activity = isnull((select max(COMPLETED_DATE) 
                                              from TASK 
                                             where STATUS = 'COMPLT' 
                                               and TASK_LINK_ENTITY_VALUE = #temp.id 
                                               and TASK_LINK_ENTITY_TABLE_ID = @taskLinkEntityTableId), 
                                           convert(datetime, '19500101 00:00')) 
	select id, 
           name, 
           address, 
           city, 
           state, 
           zip, 
           agent_id, 
           agent_name, 
           executing_terminal, 
           executing_terminal_name, 
           mcnumber, 
           active, 
           insurance_certificate, 
           insurance_certificate_w9, 
           insurance_contract, 
           board, 
           first_open_activity, 
           last_complete_activity, 
           type1, 
           type2, 
           type3, 
           type4, 
           crm_type  
      from #temp 
  order by executing_terminal, id, mcnumber, agent_id
	
	drop table #temp
end
GO
GRANT EXECUTE ON  [dbo].[crm_carriers_sp] TO [public]
GO
