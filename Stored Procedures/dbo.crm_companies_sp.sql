SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[crm_companies_sp] (@branch as varchar(12),@SupportCompanyWorkTable as bit=0, @revtype1 as varchar(6), @revtype2 as varchar(6), @revtype3 as varchar(6), @revtype4 as varchar(6))
as
begin
	-- JET - 12/10/09 - PTS 50060, row level security 
	--PTS80770 JJF 20140723
	--DECLARE @comp varchar(8) 
	--DECLARE @rowsecurity char(1)
	--DECLARE @tbl_cmprestrictedbyuser TABLE(Value VARCHAR(8))
	--END PTS80770 JJF 20140723
	--DECLARE @tbl_cmpwrkrestrictedbyuser TABLE(Value VARCHAR(8))
	DECLARE @insertsql nvarchar(4000)
	DECLARE @selectsql nvarchar(4000)
	DECLARE @fromsql   nvarchar(4000)
	DECLARE @wheresql  nvarchar(4000)
	DECLARE @sql nvarchar(4000)
	DECLARE @revRestrictionsByUser char(1)
	DECLARE @rootBranch char(1)
	
	if @revtype1 = 'UNK' and @revtype2 = 'UNK' and @revtype3 = 'UNK' and @revtype4 = 'UNK' and @branch = 'UNKNOWN'
		SET @rootBranch = 'Y'
	else
		SET @rootBranch = 'N'
	
	--PTS80770 JJF 20140723	
	--SELECT @rowsecurity = ISNULL(gi_string1, 'N'), @comp = ''
 	--  FROM generalinfo 
	-- WHERE gi_name = 'RowSecurity'

	--IF @rowsecurity = 'Y' 
		--BEGIN
		--INSERT INTO @tbl_cmprestrictedbyuser
		--SELECT * FROM  rowrestrictbyuser_company_fn(@comp)
		--INSERT INTO @tbl_cmprestrictedbyuser --@tbl_cmpwrkrestrictedbyuser
		--SELECT * FROM  rowrestrictbyuser_companycrmwork_fn(@comp)
		--END
	--END PTS80770 JJF 20140723
	-- JET - 12/10/09 - PTS 50060
	
	select @revRestrictionsByUser = ISNULL(gi_string1, 'N') 
	  from generalinfo 
	 where gi_name = 'CrmRevenueTypesByUser'
	
	create table #temp 
		(id varchar(8), 
		 name varchar(100), 
         address varchar(100), 
         city varchar(30), 
         state varchar(6), 
         zip varchar(10), 
		 master_company varchar(8), 
		 master_company_name varchar(100), 
		 booking_terminal varchar(12), 
		 booking_terminal_name varchar(100), 
		 crm_type varchar(6), 
		 active char(1), 
		 parent char(1), 
		 billto char(1), 
		 shipper char(1), 
		 consignee char(1), 
		 first_open_activity datetime, 
		 last_complete_activity datetime, 
         other_type1 varchar(6), 
         other_type2 varchar(6), 
         crm_questionnaire_field1 int,
         crm_questionnaire_field2 int,
         crm_questionnaire_field3 int,
         crm_questionnaire_field4 int,
         crm_questionnaire_field5 int,
         crm_questionnaire_field6 int,
         crm_questionnaire_field7 int,
         crm_questionnaire_field8 int,
         crm_questionnaire_field9 int,
         crm_questionnaire_field10 int,
         crm_questionnaire_field11 int,
         crm_questionnaire_field12 int,
         crm_questionnaire_field13 int,
         crm_questionnaire_field14 int,
         crm_questionnaire_field15 int,
         crm_questionnaire_field16 int,
         crm_questionnaire_field17 int,
         crm_questionnaire_field18 int,
         crm_questionnaire_field19 int,
         crm_questionnaire_field20 int,
         WorkFlag bit,
         taskLinkEntityTableId int
	)
	create index tmp_mastercompany on #temp (master_company)
	create index pk_IDWork on #temp (id,WorkFlag)
	
	if @branch is null 
		set @branch = 'UNKNOWN' 
	
	declare @cmptaskLinkEntityTableId int
	declare @cmpwrktaskLinkEntityTableId int

	select @cmptaskLinkEntityTableId = TASK_LINK_ENTITY_TABLE_ID 
	  from TASK_LINK_ENTITY_TABLE 
	 where TABLE_NAME = 'COMPANY' 
	 
	select @cmpwrktaskLinkEntityTableId = TASK_LINK_ENTITY_TABLE_ID 
	  from TASK_LINK_ENTITY_TABLE 
	 where TABLE_NAME = 'COMPANYCRMWORK' 

	 
	declare @CRMBillToOnly varchar(30)
	set @CRMBillToOnly = 'Y'
	select @CRMBillToOnly = LEFT(ISNULL(gi_string1,'Y'), 1) from generalinfo where gi_name = 'CRMBillToOnly'

	declare @CRMExcludeUnassigned varchar(30)
	set @CRMExcludeUnassigned = 'Y'
	select @CRMExcludeUnassigned = LEFT(ISNULL(gi_string1,'Y'), 1) from generalinfo where gi_name = 'CRMExcludeUnassigned'

	-- generalized insert statement
	select @insertsql = ''
	select @insertsql = @insertsql + ' insert into #temp (id, name, address, city, state, zip, '
	select @insertsql = @insertsql + ' master_company, master_company_name, booking_terminal, booking_terminal_name,'
	select @insertsql = @insertsql + ' crm_type, active, parent, billto, shipper, consignee, other_type1, other_type2,'
	select @insertsql = @insertsql + ' crm_questionnaire_field1, crm_questionnaire_field2, crm_questionnaire_field3, crm_questionnaire_field4,'
	select @insertsql = @insertsql + ' crm_questionnaire_field5, crm_questionnaire_field6, crm_questionnaire_field7, crm_questionnaire_field8,'
	select @insertsql = @insertsql + ' crm_questionnaire_field9, crm_questionnaire_field10, crm_questionnaire_field11, crm_questionnaire_field12,'
	select @insertsql = @insertsql + ' crm_questionnaire_field13, crm_questionnaire_field14, crm_questionnaire_field15, crm_questionnaire_field16,'
	select @insertsql = @insertsql + ' crm_questionnaire_field17, crm_questionnaire_field18, crm_questionnaire_field19, crm_questionnaire_field20,'
	select @insertsql = @insertsql + ' WorkFlag, taskLinkEntityTableId)'
	-- generalized select statement
	select @selectsql = ''
	select @selectsql = @selectsql + ' select distinct c.cmp_id, isnull(c.cmp_name, ''''), isnull(c.cmp_address1, ''''),'
	select @selectsql = @selectsql + ' case when city.cty_name is NULL or city.cty_name = ''UNKNOWN'''
	select @selectsql = @selectsql + ' then '''' else city.cty_name end,'
	select @selectsql = @selectsql + ' case when c.cmp_state is NULL or c.cmp_state = ''UN'' or c.cmp_state = ''XX'''
	select @selectsql = @selectsql + ' then '''' else c.cmp_state end, isnull(c.cmp_zip, ''''),'
	select @selectsql = @selectsql + ' case when c.cmp_mastercompany is NULL or c.cmp_mastercompany = ''UNKNOWN'''
	select @selectsql = @selectsql + ' then '''' else c.cmp_mastercompany end, '''','
	select @selectsql = @selectsql + ' case when c.cmp_bookingterminal is NULL or c.cmp_bookingterminal in (''UNK'', ''UNKNOWN'')'
	select @selectsql = @selectsql + ' then '''' else c.cmp_bookingterminal end,'
	select @selectsql = @selectsql + ' case when b.brn_name is NULL or upper(b.brn_name) = ''UNKNOWN'''
	select @selectsql = @selectsql + ' then '''' else b.brn_name end,'
	select @selectsql = @selectsql + ' case when c.cmp_crmtype is NULL or c.cmp_crmtype = ''UNK'' or rtrim(c.cmp_crmtype) = '''''
	select @selectsql = @selectsql + ' then ''zzzzzz'' else c.cmp_crmtype end,'
	select @selectsql = @selectsql + ' isnull(c.cmp_active, ''N''), isnull(c.cmp_parent, ''N''), isnull(c.cmp_billto, ''N''),'
	select @selectsql = @selectsql + ' isnull(c.cmp_shipper, ''N''), isnull(c.cmp_consingee, ''N''),'
	select @selectsql = @selectsql + ' case when c.cmp_otherType1 is NULL or c.cmp_otherType1 = ''UNK'''
	select @selectsql = @selectsql + ' then '''' else c.cmp_otherType1 end, '
	select @selectsql = @selectsql + ' case when c.cmp_otherType2 is NULL or c.cmp_otherType2 = ''UNK'''
	select @selectsql = @selectsql + ' then '''' else c.cmp_otherType2 end,'
	select @selectsql = @selectsql + ' isnull(UserDefined1, 0) crm_questionnaire_field1,'
	select @selectsql = @selectsql + ' isnull(UserDefined2, 0) crm_questionnaire_field2,'
	select @selectsql = @selectsql + ' isnull(UserDefined3, 0) crm_questionnaire_field3,'
	select @selectsql = @selectsql + ' isnull(UserDefined4, 0) crm_questionnaire_field4,'
	select @selectsql = @selectsql + ' isnull(UserDefined5, 0) crm_questionnaire_field5,'
	select @selectsql = @selectsql + ' isnull(UserDefined6, 0) crm_questionnaire_field6,'
	select @selectsql = @selectsql + ' isnull(UserDefined7, 0) crm_questionnaire_field7,'
	select @selectsql = @selectsql + ' isnull(UserDefined8, 0) crm_questionnaire_field8,'
	select @selectsql = @selectsql + ' isnull(UserDefined9, 0) crm_questionnaire_field9,'
	select @selectsql = @selectsql + ' isnull(UserDefined10, 0) crm_questionnaire_field10,'
	select @selectsql = @selectsql + ' isnull(UserDefined11, 0) crm_questionnaire_field11,'
	select @selectsql = @selectsql + ' isnull(UserDefined12, 0) crm_questionnaire_field12,'
	select @selectsql = @selectsql + ' isnull(UserDefined13, 0) crm_questionnaire_field13,'
	select @selectsql = @selectsql + ' isnull(UserDefined14, 0) crm_questionnaire_field14,'
	select @selectsql = @selectsql + ' isnull(UserDefined15, 0) crm_questionnaire_field15,'
	select @selectsql = @selectsql + ' isnull(UserDefined16, 0) crm_questionnaire_field16,'
	select @selectsql = @selectsql + ' isnull(UserDefined17, 0) crm_questionnaire_field17,'
	select @selectsql = @selectsql + ' isnull(UserDefined18, 0) crm_questionnaire_field18,'
	select @selectsql = @selectsql + ' isnull(UserDefined19, 0) crm_questionnaire_field19,'
	select @selectsql = @selectsql + ' isnull(UserDefined20, 0) crm_questionnaire_field20,'
	-- generalized from statement
	select @fromsql = ''
	select @fromsql = @fromsql + ' join city on c.cmp_city = city.cty_code '
	select @fromsql = @fromsql + ' left outer join CompanyCrmQuestionnaire q on c.cmp_id = q.CompanyId and q.OwnerType = ''CMP'' '
	-- generalized where statement
	select @wheresql = ''
	select @wheresql = @wheresql + ' where c.cmp_id <> ''UNKNOWN'''
	--if @rowsecurity = 'Y'
	--begin
	--	select @wheresql = @wheresql + ' and EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE c.cmp_id = cmpres.value)'
	--	select @wheresql = @wheresql + ' and c.cmp_id in (select value FROM @tbl_cmprestrictedbyuser)'
	--end
	if @CRMBillToOnly = 'Y'
		select @wheresql = @wheresql + ' and cmp_billto = ''Y'''
	if @CRMExcludeUnassigned = 'Y'
		select @wheresql = @wheresql + ' and isnull(cmp_bookingterminal, ''UNKNOWN'') not in (''UNK'', ''UNKNOWN'')'
	if @branch <> 'UNKNOWN' or (@branch = 'UNKNOWN' and @rootBranch = 'Y')
		select @wheresql = @wheresql + ' and isnull(c.cmp_bookingterminal, ''UNKNOWN'') = ''' + @branch + ''''
	if @revtype1 <> 'UNK'
		select @wheresql = @wheresql + ' and cmp_revtype1 = ''' + @revtype1 + ''''
	if @revtype1 <> 'UNK' and @revRestrictionsByUser = 'Y'
		select @wheresql = @wheresql + ' and cmp_revtype1 in (select cru_value from CrmRevenueUserRelationship where cru_type = ''RevType1'' and cru_user = SUser_Name())'
	if @revtype2 <> 'UNK'
		select @wheresql = @wheresql + ' and cmp_revtype2 = ''' + @revtype2 + ''''
	if @revtype2 <> 'UNK' and @revRestrictionsByUser = 'Y'
		select @wheresql = @wheresql + ' and cmp_revtype2 in (select cru_value from CrmRevenueUserRelationship where cru_type = ''RevType2'' and cru_user = SUser_Name())'
	if @revtype3 <> 'UNK'
		select @wheresql = @wheresql + ' and cmp_revtype3 = ''' + @revtype3 + ''''
	if @revtype3 <> 'UNK' and @revRestrictionsByUser = 'Y'
		select @wheresql = @wheresql + ' and cmp_revtype3 in (select cru_value from CrmRevenueUserRelationship where cru_type = ''RevType3'' and cru_user = SUser_Name())'
	if @revtype4 <> 'UNK'
		select @wheresql = @wheresql + ' and cmp_revtype4 = ''' + @revtype4 + ''''
	if @revtype4 <> 'UNK' and @revRestrictionsByUser = 'Y'
		select @wheresql = @wheresql + ' and cmp_revtype4 in (select cru_value from CrmRevenueUserRelationship where cru_type = ''RevType4'' and cru_user = SUser_Name())'

	select @sql = @insertsql + @selectsql + '0, ' + convert(varchar(3), @cmptaskLinkEntityTableId) + ' from company c inner join RowRestrictValidAssignments_company_fn() rsva on (c.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) right outer join branch b on c.cmp_bookingterminal = b.brn_id ' + @fromsql + @wheresql
	exec sp_executesql @sql 

	--insert into #temp (id, name, address, city, state, zip, 
	--	                 master_company, master_company_name, booking_terminal, booking_terminal_name, 
	--	                 crm_type, active, parent, billto, shipper, consignee, other_type1, other_type2, 
	--	                 crm_questionnaire_field1, crm_questionnaire_field2, crm_questionnaire_field3, crm_questionnaire_field4, 
	--	                 crm_questionnaire_field5, crm_questionnaire_field6, crm_questionnaire_field7, crm_questionnaire_field8, 
	--	                 crm_questionnaire_field9, crm_questionnaire_field10, crm_questionnaire_field11, crm_questionnaire_field12, 
	--	                 crm_questionnaire_field13, crm_questionnaire_field14, crm_questionnaire_field15, crm_questionnaire_field16, 
	--	                 crm_questionnaire_field17, crm_questionnaire_field18, crm_questionnaire_field19, crm_questionnaire_field20, 
	--	                 WorkFlag, taskLinkEntityTableId) 
	--select distinct c.cmp_id, isnull(c.cmp_name, ''), isnull(c.cmp_address1, ''), 
	--	     case when city.cty_name is NULL or city.cty_name = 'UNKNOWN' 
	--		      then '' else city.cty_name end, 
	--	     case when c.cmp_state is NULL or c.cmp_state = 'UN' or c.cmp_state = 'XX' 
	--		      then '' else c.cmp_state end, isnull(c.cmp_zip, ''), 
	--	     case when c.cmp_mastercompany is NULL or c.cmp_mastercompany = 'UNKNOWN' 
	--		      then '' else c.cmp_mastercompany end, '', 
	--	     case when c.cmp_bookingterminal is NULL or c.cmp_bookingterminal in ('UNK', 'UNKNOWN') 
	--		      then '' else c.cmp_bookingterminal end, 
	--	     case when b.brn_name is NULL or upper(b.brn_name) = 'UNKNOWN' 
	--		      then '' else b.brn_name end, 
	--	     case when c.cmp_crmtype is NULL or c.cmp_crmtype = 'UNK' or rtrim(c.cmp_crmtype) = '' 
	--		      then 'zzzzzz' else c.cmp_crmtype end, 
	--	     isnull(c.cmp_active, 'N'), isnull(c.cmp_parent, 'N'), isnull(c.cmp_billto, 'N'), 
	--	     isnull(c.cmp_shipper, 'N'), isnull(c.cmp_consingee, 'N'), 
	--	     case when c.cmp_otherType1 is NULL or c.cmp_otherType1 = 'UNK' 
	--		      then '' else c.cmp_otherType1 end, 
	--	     case when c.cmp_otherType2 is NULL or c.cmp_otherType2 = 'UNK' 
	--		      then '' else c.cmp_otherType2 end, 
	--	     ISNULL(UserDefined1, 0) crm_questionnaire_field1, 
	--	     ISNULL(UserDefined2, 0) crm_questionnaire_field2, 
	--	     ISNULL(UserDefined3, 0) crm_questionnaire_field3, 
	--	     ISNULL(UserDefined4, 0) crm_questionnaire_field4, 
	--	     ISNULL(UserDefined5, 0) crm_questionnaire_field5, 
	--	     ISNULL(UserDefined6, 0) crm_questionnaire_field6, 
	--	     ISNULL(UserDefined7, 0) crm_questionnaire_field7, 
	--	     ISNULL(UserDefined8, 0) crm_questionnaire_field8, 
	--	     ISNULL(UserDefined9, 0) crm_questionnaire_field9, 
	--	     ISNULL(UserDefined10, 0) crm_questionnaire_field10, 
	--	     ISNULL(UserDefined11, 0) crm_questionnaire_field11, 
	--	     ISNULL(UserDefined12, 0) crm_questionnaire_field12, 
	--	     ISNULL(UserDefined13, 0) crm_questionnaire_field13, 
	--	     ISNULL(UserDefined14, 0) crm_questionnaire_field14, 
	--	     ISNULL(UserDefined15, 0) crm_questionnaire_field15, 
	--	     ISNULL(UserDefined16, 0) crm_questionnaire_field16, 
	--	     ISNULL(UserDefined17, 0) crm_questionnaire_field17, 
	--	     ISNULL(UserDefined18, 0) crm_questionnaire_field18, 
	--	     ISNULL(UserDefined19, 0) crm_questionnaire_field19, 
	--	     ISNULL(UserDefined20, 0) crm_questionnaire_field20,
	--	     0,
	--	     @cmptaskLinkEntityTableId
	--  from company c right outer join branch b on c.cmp_bookingterminal = b.brn_id 
	--	               join city on c.cmp_city = city.cty_code 
	--	               left outer join CompanyCrmQuestionnaire q on c.cmp_id = q.CompanyId and q.OwnerType = 'CMP'
	-- where c.cmp_id <> 'UNKNOWN' 
	--   and (isnull(c.cmp_bookingterminal, 'UNKNOWN') = @branch or @branch = 'UNKNOWN')
	--   and (EXISTS(select * FROM @tbl_cmprestrictedbyuser cmpres WHERE c.cmp_id = cmpres.value) or @rowsecurity <> 'Y') 
	--   and (c.cmp_id in (select value FROM @tbl_cmprestrictedbyuser) or @rowsecurity <> 'Y') 
	--   and (cmp_billto = 'Y' or @CRMBillToOnly <> 'Y')
	--   and (ISNULL(cmp_bookingterminal, 'UNKNOWN') not in ('UNK', 'UNKNOWN') or @CRMExcludeUnassigned <> 'Y' 
	--    or (@CRMExcludeUnassigned = 'Y' and (@revtype1 <> 'UNK' or @revtype2 <> 'UNK' or @revtype3 <> 'UNK' or @revtype4 <> 'UNK')))
	--   and (cmp_revtype1 = @revtype1 or @revtype1 = 'UNK')
	--   and (cmp_revtype2 = @revtype2 or @revtype2 = 'UNK')
	--   and (cmp_revtype3 = @revtype3 or @revtype3 = 'UNK')
	--   and (cmp_revtype4 = @revtype4 or @revtype4 = 'UNK')
	   
IF @SupportCompanyWorkTable	= 1  
begin
	select @sql = @insertsql + @selectsql + '1, ' + convert(varchar(3), @cmpwrktaskLinkEntityTableId) + ' from companycrmwork c inner join RowRestrictValidAssignments_companycrmwork_fn() rsva on (c.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) right outer join branch b on c.cmp_bookingterminal = b.brn_id ' + @fromsql + @wheresql
	exec sp_executesql @sql 
end

	--insert into #temp (id, name, address, city, state, zip, 
	--	                 master_company, master_company_name, booking_terminal, booking_terminal_name, 
	--	                 crm_type, active, parent, billto, shipper, consignee, other_type1, other_type2, 
	--	                 crm_questionnaire_field1, crm_questionnaire_field2, crm_questionnaire_field3, crm_questionnaire_field4, 
	--	                 crm_questionnaire_field5, crm_questionnaire_field6, crm_questionnaire_field7, crm_questionnaire_field8, 
	--	                 crm_questionnaire_field9, crm_questionnaire_field10, crm_questionnaire_field11, crm_questionnaire_field12, 
	--	                 crm_questionnaire_field13, crm_questionnaire_field14, crm_questionnaire_field15, crm_questionnaire_field16, 
	--	                 crm_questionnaire_field17, crm_questionnaire_field18, crm_questionnaire_field19, crm_questionnaire_field20,
	--	                 WorkFlag, taskLinkEntityTableId) 
	--select distinct c.cmp_id, isnull(c.cmp_name, ''), isnull(c.cmp_address1, ''), 
	--	     case when city.cty_name is NULL or city.cty_name = 'UNKNOWN' 
	--		      then '' else city.cty_name end, 
	--	     case when c.cmp_state is NULL or c.cmp_state = 'UN' or c.cmp_state = 'XX' 
	--		      then '' else c.cmp_state end, isnull(c.cmp_zip, ''), 
	--	     case when c.cmp_mastercompany is NULL or c.cmp_mastercompany = 'UNKNOWN' 
	--		      then '' else c.cmp_mastercompany end, '', 
	--	     case when c.cmp_bookingterminal is NULL or c.cmp_bookingterminal in ('UNK', 'UNKNOWN') 
	--		      then '' else c.cmp_bookingterminal end, 
	--	     case when b.brn_name is NULL or upper(b.brn_name) = 'UNKNOWN' 
	--		      then '' else b.brn_name end, 
	--	     case when c.cmp_crmtype is NULL or c.cmp_crmtype = 'UNK' or rtrim(c.cmp_crmtype) = '' 
	--		      then 'zzzzzz' else c.cmp_crmtype end, 
	--	     isnull(c.cmp_active, 'N'), isnull(c.cmp_parent, 'N'), isnull(c.cmp_billto, 'N'), 
	--	     isnull(c.cmp_shipper, 'N'), isnull(c.cmp_consingee, 'N'), 
	--	     case when c.cmp_otherType1 is NULL or c.cmp_otherType1 = 'UNK' 
	--		      then '' else c.cmp_otherType1 end, 
	--	     case when c.cmp_otherType2 is NULL or c.cmp_otherType2 = 'UNK' 
	--		      then '' else c.cmp_otherType2 end, 
	--	     ISNULL(UserDefined1, 0) crm_questionnaire_field1, 
	--	     ISNULL(UserDefined2, 0) crm_questionnaire_field2, 
	--	     ISNULL(UserDefined3, 0) crm_questionnaire_field3, 
	--	     ISNULL(UserDefined4, 0) crm_questionnaire_field4, 
	--	     ISNULL(UserDefined5, 0) crm_questionnaire_field5, 
	--	     ISNULL(UserDefined6, 0) crm_questionnaire_field6, 
	--	     ISNULL(UserDefined7, 0) crm_questionnaire_field7, 
	--	     ISNULL(UserDefined8, 0) crm_questionnaire_field8, 
	--	     ISNULL(UserDefined9, 0) crm_questionnaire_field9, 
	--	     ISNULL(UserDefined10, 0) crm_questionnaire_field10, 
	--	     ISNULL(UserDefined11, 0) crm_questionnaire_field11, 
	--	     ISNULL(UserDefined12, 0) crm_questionnaire_field12, 
	--	     ISNULL(UserDefined13, 0) crm_questionnaire_field13, 
	--	     ISNULL(UserDefined14, 0) crm_questionnaire_field14, 
	--	     ISNULL(UserDefined15, 0) crm_questionnaire_field15, 
	--	     ISNULL(UserDefined16, 0) crm_questionnaire_field16, 
	--	     ISNULL(UserDefined17, 0) crm_questionnaire_field17, 
	--	     ISNULL(UserDefined18, 0) crm_questionnaire_field18, 
	--	     ISNULL(UserDefined19, 0) crm_questionnaire_field19, 
	--	     ISNULL(UserDefined20, 0) crm_questionnaire_field20,
	--	     1,
	--	     @cmpwrktaskLinkEntityTableId 
	--  from companycrmwork c right outer join branch b on c.cmp_bookingterminal = b.brn_id 
	--	               join city on c.cmp_city = city.cty_code 
	--	               left outer join CompanyCrmQuestionnaire q on c.cmp_id = q.CompanyId and q.OwnerType = 'CMPWRK'
	-- where c.cmp_id <> 'UNKNOWN' 
	--   and isnull(c.cmp_bookingterminal, 'UNKNOWN') = @branch 
	--   and (EXISTS(select * FROM @tbl_cmpwrkrestrictedbyuser cmpres WHERE c.cmp_id = cmpres.value) or @rowsecurity <> 'Y') 
	--   and (cmp_billto = 'Y' or @CRMBillToOnly <> 'Y')
	--   and (ISNULL(cmp_bookingterminal, 'UNKNOWN') not in ('UNK', 'UNKNOWN') or @CRMExcludeUnassigned <> 'Y' 
	--    or (@CRMExcludeUnassigned = 'Y' and (@revtype1 <> 'UNK' or @revtype2 <> 'UNK' or @revtype3 <> 'UNK' or @revtype4 <> 'UNK')))
	--   and (cmp_revtype1 = @revtype1 or @revtype1 = 'UNK')
	--   and (cmp_revtype2 = @revtype2 or @revtype2 = 'UNK')
	--   and (cmp_revtype3 = @revtype3 or @revtype3 = 'UNK')
	--   and (cmp_revtype4 = @revtype4 or @revtype4 = 'UNK')
	
	update #temp 
       set master_company_name =  c.cmp_name 
      from company c 
     where c.cmp_id = #temp.master_company 
	
	update #temp 
       set first_open_activity = isnull((select min(DUE_DATE) 
                                           from TASK 
                                          where STATUS = 'OPEN' 
                                            and TASK_LINK_ENTITY_VALUE = #temp.id 
                                            and TASK_LINK_ENTITY_TABLE_ID = #temp.taskLinkEntityTableId), 
                                        convert(datetime, '20491231 23:59')) 
	update #temp 
       set last_complete_activity = isnull((select max(COMPLETED_DATE) 
                                              from TASK 
                                             where STATUS = 'COMPLT' 
                                               and TASK_LINK_ENTITY_VALUE = #temp.id 
                                               and TASK_LINK_ENTITY_TABLE_ID = #temp.taskLinkEntityTableId), 
                                           convert(datetime, '19500101 00:00')) 

	select id, 
	       name, 
	       address, 
	       city, 
	       state, 
	       zip, 
	       master_company, 
	       master_company_name, 
	       booking_terminal, 
	       booking_terminal_name, 
	       crm_type, 
	       active, 
	       parent, 
	       billto, 
	       shipper, 
	       consignee, 
	       first_open_activity, 
	       last_complete_activity, 
	       other_type1, 
	       other_type2, 
	       crm_questionnaire_field1, 
	       crm_questionnaire_field2, 
	       crm_questionnaire_field3, 
	       crm_questionnaire_field4, 
	       crm_questionnaire_field5, 
	       crm_questionnaire_field6, 
	       crm_questionnaire_field7, 
	       crm_questionnaire_field8, 
	       crm_questionnaire_field9, 
	       crm_questionnaire_field10, 
	       crm_questionnaire_field11, 
	       crm_questionnaire_field12, 
	       crm_questionnaire_field13, 
	       crm_questionnaire_field14, 
	       crm_questionnaire_field15, 
	       crm_questionnaire_field16, 
	       crm_questionnaire_field17, 
	       crm_questionnaire_field18, 
	       crm_questionnaire_field19, 
	       crm_questionnaire_field20,
	       WorkFlag
	  from #temp 
	  --PTS80770 JJF 20140723
	 --where (@rowsecurity = 'N') 
	 --   or (@rowsecurity = 'Y' and id in (select value FROM @tbl_cmprestrictedbyuser))
	 --END PTS80770 JJF 20140723
	order by booking_terminal, master_company, crm_type, id
  	
	drop table #temp
end
GO
GRANT EXECUTE ON  [dbo].[crm_companies_sp] TO [public]
GO
