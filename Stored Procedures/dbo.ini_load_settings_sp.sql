SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create procedure [dbo].[ini_load_settings_sp]
(
    @userid varchar(20)
)
as


/************************************************************************************
 NAME:		ini_load_settings_sp
 DOS NAME:	tmwsp_ini_load_settings_sp.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:   Load information into PB for the FSS application
 DEPENDANCIES:
 PROCESS:
 exec ini_load_settings_sp 'LLEHMANN'
 ---------------------------------------------------------------------------
REVISION LOG

DATE	       WHO		   REASON
----	       ---		   ------
Jan-16-2002   LLEHMANN    Initial Creation
Jun-18-2002   TDRYSDALE   Grant access to tt_db_tmw_update_role instead of public
Nov-01-2007   MROIK       PTS # 38837 - Migrated from Sybase to MS SQL Server
Apr-30-2008	  JD		  Merge Trimac and TMW models.	
*************************************************************************************/
declare @brn_id varchar(12)
declare @grp_id varchar(20)
declare @li_count int
declare @li_validateok int 

select @li_validateok = 0  -- set this to 1 if the ini file is valid (i.e. has all the sections required)
Create table #temp
(
	[file_name] varchar(255),
	section_name varchar(255),
	item_name varchar(255),
	value_setting varchar(1024)
)

Create table #groups
(grp_id char(20) not null,inivaluesexist int not null)

create table #branches
(brn_id varchar(12) not null, inivaluesexist int not null)



if exists (select * from ini_values where group_level is null) -- for TRIMAC this field will have null values.
	Insert into #temp
	select f.[file_name], 
	       g.section_name, 
	       e.item_name,
	       a.value_setting
	from ini_values a
	     inner join ini_xref_file_section_item c
	        on a.file_section_item_id = c.file_section_item_id
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_item e
	        on e.item_id = c.item_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
	where 
		a.usr_userid = @userid
Else
Begin
	-- branches support both Transfreight and Ryder models. TF wins.
--	if exists (select * from usertypeassignment where usr_userid = @userid and uta_type1 <> 'UNK'
--		insert  into #branches(brn_id,inivaluesexist)
--		select uta_type1,0 from usertypeassignment where usr_userid = @userid and uta_type1 <> 'UNK'
--	else
--		insert into #branches(brn_id,inivaluesexist)
--		select	brn_id,0 from branch_assignedtype where bat_type = 'USERS' and bat_value = @userid and bat_active = 'Y'	

	--PTS 51073 JD just look at the ttsusers table for user branch association.	
	insert into #branches(brn_id,inivaluesexist) 
	select usr_booking_terminal,0 from ttsusers where usr_userid = @userid and isnull(usr_booking_terminal,'UNK') <> 'UNK'

	-- groups table
	insert into #groups(grp_id,inivaluesexist)
		select grp_id,0 from ttsgroupasgn where usr_userid = @userid
	
	--select * from ttsgroupasgn
	
	update #groups set inivaluesexist =1 where exists (select * from ini_values where group_level = 2 and #groups.grp_id = ini_values.usr_userid)
	update #branches set inivaluesexist =1 where exists (select * from ini_values where group_level = 1 and #branches.brn_id = ini_values.usr_userid)
	
	--select * from #groups
	--select * from #branches
	

	Insert into #temp
	select f.[file_name], 
	       g.section_name, 
	       e.item_name,
	       a.value_setting
	from ini_values a
	     inner join ini_xref_file_section_item c
	        on a.file_section_item_id = c.file_section_item_id
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_item e
	        on e.item_id = c.item_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
	where 
		a.group_level = 0

	-- BRANCH LEVEL OVERRIDES	
	--select @brn_id = min(brn_id) from branch_assignedtype where bat_type = 'USERS' and bat_value = @userid and bat_active = 'Y'
	select @li_count = count(*) from #branches where inivaluesexist= 1
	if @li_count <= 1
	BEGIN
		select @brn_id = brn_id from #branches where inivaluesexist = 1
--		if exists (select * from ini_values where group_level = 1 and usr_userid = @brn_id)
		Update #temp
		 set #temp.value_setting = a.value_setting
		from ini_values a
		     inner join ini_xref_file_section_item c
		        on a.file_section_item_id = c.file_section_item_id
		     inner join ini_xref_file_section d
		        on d.file_section_id = c.file_section_id
		     inner join ini_item e
		        on e.item_id = c.item_id
		     inner join ini_file f
		        on f.file_id = d.file_id
		     inner join ini_section g
		        on g.section_id = d.section_id
		where 
			a.group_level = 1 and 
			a.usr_userid = @brn_id and
			#temp.[file_name] =  f.[file_name] and
		    #temp.section_name = g.section_name and
			#temp.item_name =   e.item_name
	END -- end group check	

	-- GROUP LEVEL OVERRIDES	
--	select @grp_id = min(grp_id) from ttsgroupasgn where usr_userid = @userid
		select @li_count = count(*) from #groups where inivaluesexist= 1
	IF @li_count < = 1
	BEGIN
		select @grp_id = grp_id from #groups where inivaluesexist = 1
--		if exists (select * from ini_values where group_level = 2 and usr_userid = @grp_id)
		Update #temp
		 set #temp.value_setting = a.value_setting
		from ini_values a
		     inner join ini_xref_file_section_item c
		        on a.file_section_item_id = c.file_section_item_id
		     inner join ini_xref_file_section d
		        on d.file_section_id = c.file_section_id
		     inner join ini_item e
		        on e.item_id = c.item_id
		     inner join ini_file f
		        on f.file_id = d.file_id
		     inner join ini_section g
		        on g.section_id = d.section_id
		where 
			a.group_level = 2 and 
			a.usr_userid = @grp_id and
			#temp.[file_name] =  f.[file_name] and
		    #temp.section_name = g.section_name and
			#temp.item_name =   e.item_name
	
	END


	-- USER LEVEL OVERRIDES	

	if exists (select * from ini_values where group_level = 3 and usr_userid = @userid)
	Update #temp
	 set #temp.value_setting = a.value_setting
	from ini_values a
	     inner join ini_xref_file_section_item c
	        on a.file_section_item_id = c.file_section_item_id
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_item e
	        on e.item_id = c.item_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
	where 
		a.group_level = 3 and 
		a.usr_userid = @userid and
		#temp.[file_name] =  f.[file_name] and
	    #temp.section_name = g.section_name and
		#temp.item_name =   e.item_name
	

End

if exists (select * from #temp where section_name = 'ORDER')
	if exists (select * from #temp where section_name = 'DISPATCH')
		if exists (select * from #temp where section_name = 'INVOICE')
			if exists (select * from #temp where section_name = 'SETTLEMENT')
				select @li_validateok = 1

if @li_validateok = 1
	select [file_name], section_name,item_name, value_setting from #temp
else
	select [file_name], section_name,item_name, value_setting from #temp where 1 = 2

GO
GRANT EXECUTE ON  [dbo].[ini_load_settings_sp] TO [public]
GO
