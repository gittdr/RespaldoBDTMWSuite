SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[d_eta_labels_sp]
as

/**
 * 
 * NAME:
 * dbo.d_eta_labels_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure builds the restriction drop downs for the ETA Agent
 *
 * RETURNS:
 * A return value of zero indicates success. A non-zero return value
 * indicates a failure of some type
 *
 * RESULT SETS: 
 * column_name 		-	The column name of the restriction type ex:  mpp_teamleader, ord_revtype1
 * labeldefinition	-	The labeldefinition in which the column_name is defined ex: TeamLeader, RevType1	
 * name					-	User Defined Header name of the labelfile entry  ex:  Terminal is definied by RevType1
 * abbr					-  Abbreviation of the labelfile entry
 * code					-  Order in DropDown
 * userlabelname		-	User Definded name of the label entry   ex:  Cleveland is a value for Terminal/RevType1
 * seq					-  sequencing number used by the dropdown
 * app_seq				-  sequencing number used by the dropdown
 *
 * PARAMETERS:
 *  NONE
 *
 * 
 * REVISION HISTORY:
 * 08/01/2005 - Jason Bauwin - utilize ETACMPRESTRICT GI setting to increase performance
 * 09/02/2005 - Jason Bauwin - Set the Transaction Isolation level to ignore locked tables 
 *                            so the agent does not get deadlocked because of other locking in the database
 *
 **/


--PTS 29667
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

create table #col_lbl
		(column_name		varchar(20)		null
		,labeldefinition	varchar(20)		null
		,app_seq			smallint		null)

create table #col_lbl_2
		(column_name		varchar(20)		null
		,labeldefinition	varchar(20)		null
		,min_seq			numeric(7, 0)	null)

create table #lf
		(column_name		varchar(20)		null
		,labeldefinition	varchar(20)		null
		--vmj1+	Change data types so company info may be stored..
		,name				varchar(100)		null
		,abbr				varchar(8)		null
--		,name				varchar(20)		null
--		,abbr				varchar(6)		null
		--vmj1-
		,code				int				null
		,userlabelname		varchar(20)		null
		,raw_seq			numeric(7, 0)	identity
		,seq				numeric(7, 0)	null
		,app_seq			smallint		null)


--Populate the list of label definitions we're interested in..
insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('mpp_teamleader'
		,'TeamLeader'
		,1)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('ord_revtype1'
		,'RevType1'
		,2)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('ord_revtype2'
		,'RevType2'
		,3)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('ord_revtype3'
		,'RevType3'
		,4)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('ord_revtype4'
		,'RevType4'
		,5)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('ord_originregion1'
		,'Regions'
		,6)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('ord_destregion1'
		,'Regions'
		,7)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('mpp_type1'
		,'DrvType1'
		,8)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('mpp_type2'
		,'DrvType2'
		,9)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('mpp_type3'
		,'DrvType3'
		,10)

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('mpp_type4'
		,'DrvType4'
		,11)

--vmj1+
insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('cmp_id'
		,'Company ID'
		,12)
--vmj1-

insert	#col_lbl
		(column_name
		,labeldefinition
		,app_seq)
  values ('Catch-All'
		,'Catch-All'
		--vmj1+
		,13)
--		,12)
		--vmj1-


--Load all labelfile rows..
insert 	#lf
		(column_name
		,labeldefinition
		,name
		,abbr
		,code
		,userlabelname
		,app_seq)
  select cl.column_name
		,cl.labeldefinition
		,lf.name
		,lf.abbr
		,lf.code
		,lf.userlabelname
		,cl.app_seq
  from	#col_lbl cl
   join labelfile lf on lf.labeldefinition = cl.labeldefinition
  where isnull(lf.retired, 'N') = 'N' 
  order by cl.app_seq
		,cl.labeldefinition
		,lf.code

if (select isnull(upper(gi_string1),'OFF') from generalinfo where gi_name = 'ETACMPRESTRICT') = 'ON'
begin
	--vmj1+	Add the Company ID rows to #lf..
	insert 	#lf
			(column_name
			,labeldefinition
			,name
			,abbr
			,code
			,userlabelname
			,app_seq)
	  select cl.column_name
			,cl.labeldefinition
			,c.cmp_name
			,c.cmp_id
			,0
			,'Company ID'
			,cl.app_seq
	  from	#col_lbl cl
     right outer join company c on cl.column_name = 'cmp_id'
	  order by cl.app_seq
			,cl.labeldefinition
			,c.cmp_id
end
--Add the 'Catch-All' row to #lf..
insert 	#lf
		(column_name
		,labeldefinition
		,name
		,abbr
		,code
		,userlabelname
		,app_seq)
  select cl.column_name
		,cl.labeldefinition
		,''
		,''
		,0
		,''
		,cl.app_seq
  from	#col_lbl cl
  where	cl.column_name = 'Catch-All'
--vmj1-


--Now sequence each label within column_name, labeldefinition combination..
insert	#col_lbl_2
		(column_name
		,labeldefinition
		,min_seq)
  select column_name
		,labeldefinition
		,min(raw_seq)
  from	#lf
  group by column_name
		,labeldefinition

update	#lf
   set	seq = l.raw_seq - c.min_seq + 1
  from	#lf l
  join   #col_lbl_2 c ON c.column_name = l.column_name AND c.labeldefinition = l.labeldefinition


--vmj1+	Provide a value for code column for Companies..
update	#lf
  set	code = seq
  where	column_name = 'cmp_id'
--vmj1-


--Replace userlabelname with more descriptive text for Origin and Dest Region..
update	#lf
  set	userlabelname = 'Origin Region'
  where	column_name = 'ord_originregion1'

update	#lf
  set	userlabelname = 'Dest Region'
  where	column_name = 'ord_destregion1'


--Fill in Catch-All columns..
update	#lf
  set	name = '*'
		,abbr = '*'
		,code = 0
		,userlabelname = 'Catch-All'
  where	column_name = 'Catch-All'


--Return the result set..
select	column_name
		,labeldefinition
		,name
		,abbr
		,code
		,userlabelname
		,seq
		,app_seq
  from	#lf
  order by app_seq
		,labeldefinition
		,seq

--PTS 29667
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

GO
GRANT EXECUTE ON  [dbo].[d_eta_labels_sp] TO [public]
GO
