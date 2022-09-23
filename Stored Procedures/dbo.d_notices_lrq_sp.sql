SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_notices_lrq_sp] @drv1 char(8), @drv2 char(8), @trc char(8), @trl1 char(13), 
@trl2 char(13), @car char(8), @reldate datetime, @lghnumber int, @movnumber int
AS
/**
 * 
 * NAME:
 * dbo.d_notices_lrq_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * PTS 3436 PG 1/8/98 Performance Enhancement added NOLOCK on expiration and loadrequirement
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/

Declare @drv1_pri1soon int, @drv1_pri2soon int, @drv1_pri1now int, @drv1_pri2now int,
	@drv2_pri1soon int, @drv2_pri2soon int, @drv2_pri1now int, @drv2_pri2now int,
	@trc_pri1soon int,  @trc_pri2soon int,  @trc_pri1now int,  @trc_pri2now int,
	@trl1_pri1soon int, @trl1_pri2soon int, @trl1_pri1now int, @trl1_pri2now int,
	@trl2_pri1soon int, @trl2_pri2soon int, @trl2_pri1now int, @trl2_pri2now int,
	@varchar varchar(80)

SELECT @varchar = ' '

If @drv1 <> 'UNKNOWN' AND @drv1 <> ''
Begin
NO_LOCK1:
	SELECT @drv1_pri1soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK1
NO_LOCK2:
	SELECT @drv1_pri2soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK2
NO_LOCK3:
	SELECT @drv1_pri1now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK3
NO_LOCK4:
	SELECT @drv1_pri2now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK4
End

If @drv2 <> 'UNKNOWN' AND @drv2 <> ''
Begin
NO_LOCK5:
	SELECT @drv2_pri1soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK5
NO_LOCK6:
	SELECT @drv2_pri2soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK6
NO_LOCK7:
	SELECT @drv2_pri1now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK7
NO_LOCK8:
	SELECT @drv2_pri2now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'DRV' AND
				exp_id = @drv2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK8
End

If @trc <> 'UNKNOWN' AND @trc <> ''
Begin
NO_LOCK9:
	SELECT @trc_pri1soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK9
NO_LOCK10:
	SELECT @trc_pri2soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK10
NO_LOCK11:
	SELECT @trc_pri1now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK11
NO_LOCK12:
	SELECT @trc_pri2now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRC' AND
				exp_id = @trc AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK12
End

If @trl1 <> 'UNKNOWN' AND @trl1 <> ''
Begin
NO_LOCK13:
	SELECT @trl1_pri1soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK13
NO_LOCK14:
	SELECT @trl1_pri2soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK14
NO_LOCK15:
	SELECT @trl1_pri1now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK15
NO_LOCK16:
	SELECT @trl1_pri2now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl1 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK16
End

If @trl2 <> 'UNKNOWN' AND @trl2 <> ''
Begin
NO_LOCK17:
	SELECT @trl2_pri1soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK17
NO_LOCK18:
	SELECT @trl2_pri2soon = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= @reldate AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK18
NO_LOCK19:
	SELECT @trl2_pri1now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority = '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK19
NO_LOCK20:
	SELECT @trl2_pri2now = ( SELECT count (*) 
			FROM expiration (NOLOCK)
			WHERE exp_idtype = 'TRL' AND
				exp_id = @trl2 AND
				exp_expirationdate <= GetDate ( ) AND
				exp_completed = 'N' AND
				exp_priority > '1' )
	IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK20
End

-- Create a temp table to select into
create table #temp (requirement varchar(80) null,
	lrq_equip_type varchar(6) null,
	lrq_not char(1) null,
	lrq_type varchar(6) null,
	lrq_manditory char(1) null,
	assign_id varchar(13) null,
	lrq_quantity int null,
	def_id_type varchar(6) null,
	equip_type_str varchar(20) null,
	not_str varchar(12) null,
	type_str varchar(20) null,
	manditory_str varchar(7) null,
	id_type_str varchar(13) null)

/* pts6419 lrqs are now related to move
-- Get the load requirements for leg header or move into the temp table
select @movnumber = isnull(@movnumber,-1)
select  @lghnumber = isnull(@lghnumber,-1)
NO_LOCK21:
insert into #temp
select distinct '',
	l.lrq_equip_type,
	l.lrq_not,
	l.lrq_type,
	l.lrq_manditory,
	'',
	isnull(l.lrq_quantity, 0),
	l.def_id_type,
	'',
	'',
	'',
	'',
	''
from loadrequirement l (NOLOCK)
where l.lgh_number = @lghnumber
or (l.mov_number = @movnumber
and l.lrq_equip_type = 'TRL')
IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) 
		GOTO NO_LOCK21
*/
     -- create a temp table of all cmp/stoptype/ commod combinations on leg
SELECT DISTINCT cmp_id = stops.cmp_id, stp_type = stops.stp_type, cmd_code = ISNULL(freightdetail.cmd_code,'UNKNOWN')
INTO #cmpcmdstop
FROM legheader lgh, stops, freightdetail
WHERE lgh.lgh_number = @lghnumber
AND  stops.mov_number = lgh.mov_number
AND stops.lgh_number = @lghnumber
AND stops.stp_type in ('PUP','DRP')
AND freightdetail.stp_number = stops.stp_number

	-- create a temp table of all cmp / stop type on leg
SELECT DISTINCT cmp_id, stp_type
INTO #cmpstop
FROM #cmpcmdstop

	-- create a temp table of all distinct commod on leg
SELECT distinct cmd_code
INTO #cmd
FROM #cmpcmdstop
WHERE cmd_code <> 'UNKNOWN'

-- collect the commodity related loadrequirements 
insert into #temp
select  '',
	lrq_equip_type,
	lrq_not,
	lrq_type,
	lrq_manditory,
	'',
	isnull(lrq_quantity, 0),
	def_id_type,
	'',
	'',
	'',
	'',
	''
FROM loadrequirement 
WHERE loadrequirement.mov_number = @movnumber
AND   loadrequirement.cmd_code IN (SELECT cmd_code FROM #cmd)
AND   ISNULL(loadrequirement.cmp_id,'UNKNOWN') = 'UNKNOWN' 
AND   ISNULL(loadrequirement.lrq_default,'N') <> 'X'   -- disabled default lrq

-- add the company / stop type  related loadrequirements 
insert into #temp
select  '',
	lrq_equip_type,
	lrq_not,
	lrq_type,
	lrq_manditory,
	'',
	isnull(lrq_quantity, 0),
	def_id_type,
	'',
	'',
	'',
	'',
	''
FROM loadrequirement , #cmpstop
WHERE loadrequirement.mov_number = @movnumber
AND   ISNULL(loadrequirement.cmd_code,'UNKNOWN') = 'UNKNOWN'
AND   ISNULL(loadrequirement.cmp_id,'UNKNOWN') = #cmpstop.cmp_id
AND   ISNULL(loadrequirement.def_id_type,'BOTH') IN ( #cmpstop.stp_type,'BOTH')
AND   ISNULL(loadrequirement.lrq_default,'N') <> 'X'   -- disabled default lrq

-- add the company / stop type / commodity  related loadrequirements 
insert into #temp
select '',
	lrq_equip_type,
	lrq_not,
	lrq_type,
	lrq_manditory,
	'',
	isnull(lrq_quantity, 0),
	def_id_type,
	'',
	'',
	'',
	'',
	''
FROM loadrequirement , #cmpcmdstop
WHERE loadrequirement.mov_number = @movnumber
-- RE PTS 8349
-- AND   ISNULL(loadrequirement.cmd_code,'UNKNOWN') = 'UNKNOWN'
AND   ISNULL(loadrequirement.cmp_id,'UNKNOWN') = #cmpcmdstop.cmp_id
-- RE PTS 8349
-- AND   ISNULL(loadrequirement.def_id_type,'BOTH') = #cmpcmdstop.stp_type
AND   ISNULL(loadrequirement.def_id_type,'BOTH') IN (#cmpcmdstop.stp_type, 'BOTH')
AND   ISNULL(loadrequirement.cmd_code,'UNKNOWN') = #cmpcmdstop.cmd_code
AND   ISNULL(loadrequirement.lrq_default,'N') <> 'X'   -- disabled default lrq

-- re pts 8706 collect all the loadrequirements not returned by previous selects
insert into #temp

select  '',
	lrq_equip_type,
	lrq_not,
	lrq_type,
	lrq_manditory,
	'',
	isnull(lrq_quantity, 0),
	def_id_type,
	'',
	'',
	'',
	'',
	''
FROM loadrequirement 
WHERE loadrequirement.mov_number = @movnumber 
AND   ISNULL(loadrequirement.cmd_code, 'UNKNOWN') = 'UNKNOWN'
AND   ISNULL(loadrequirement.def_id_type, 'BOTH') = 'BOTH'
AND   ISNULL(loadrequirement.cmp_id, 'UNKNOWN') NOT IN (SELECT cmp_id FROM #cmpstop)
AND   ISNULL(loadrequirement.lrq_default,'N') <> 'X'   -- disabled default lrq

-- now get the distinct values
select DISTINCT requirement = @varchar,
	lrq_equip_type,
	lrq_not,
	lrq_type,
	lrq_manditory,
	assign_id = @varchar,
	lrq_quantity = isnull(lrq_quantity, 0),
	def_id_type,
	equip_type_str = @varchar,
	not_str = @varchar,
	type_str = @varchar,
	manditory_str = @varchar,
	id_type_str = @varchar
INTO #distinctlrq
FROM #temp
              
if (select count(*) from #distinctlrq) > 0
	begin

-- Get asset type name
	update #distinctlrq
		set equip_type_str = isnull(labelfile.name, '')
		from labelfile, #distinctlrq
		where labelfile.labeldefinition = 'AssType'
		and labelfile.abbr = #distinctlrq.lrq_equip_type

-- Get requirement type name
	update #distinctlrq
		set type_str = isnull(labelfile.name, '')
		from labelfile, #distinctlrq
		where labelfile.labeldefinition in ('TrlAcc', 'TrcAcc', 'DrvAcc')
		and labelfile.abbr = #distinctlrq.lrq_type

-- Get code names
	update #distinctlrq
		set manditory_str = 
        		 CASE lrq_manditory
 	   		   WHEN 'y' then ' must'
	  		   ELSE ' should'
			 END,
		id_type_str = 
			CASE def_id_type
			  WHEN 'PUP' then 'Pickup '
			  WHEN 'DRP' THEN 'Drop '
			  ELSE 'Both '
			END,
		not_str =
	 		 CASE lrq_not
	    			WHEN 'N' THEN ' not have/be'
           			 ELSE ' have/be'
          		 END


-- Parse the load requirement string
	update #distinctlrq
		set requirement = 'At ' + id_type_str + ' ' + equip_type_str + manditory_str 
				   + not_str + ' ' + type_str + ' ' 
				   + convert(char(3), lrq_quantity)

	end

if (select count(*) from #distinctlrq) > 0
	select 	@drv1 drv1, @drv1_pri1soon drv1_pri1soon, @drv1_pri2soon drv1_pri2soon, 
		@drv1_pri1now drv1_pri1now, @drv1_pri2now drv1_pri2now, 
		@drv2 drv2, @drv2_pri1soon drv2_pri1soon, @drv2_pri2soon drv2_pri2soon,
		@drv2_pri1now drv2_pri1now, @drv2_pri2now drv2_pri2now, 
		@trc trc, @trc_pri1soon trc_pri1soon, @trc_pri2soon trc_pri2soon,  
		@trc_pri1now trc_pri1now,  @trc_pri2now trc_pri2now,
		@trl1 trl1, @trl1_pri1soon trl1_pri1soon, @trl1_pri2soon trl1_pri2soon, 
		@trl1_pri1now trl1_pri1now, @trl1_pri2now trl1_pri2now, 
		@trl2 trl2, @trl2_pri1soon trl2_pri1soon, @trl2_pri2soon trl2_pri2soon,
		@trl2_pri1now trl2_pri1now, @trl2_pri2now trl2_pri2now, 
		lrq_equip_type, lrq_not, lrq_type, lrq_manditory, requirement, 
		convert(char(13), '') asgn_id  
        from #distinctlrq
else
	select 	@drv1 drv1, @drv1_pri1soon drv1_pri1soon, @drv1_pri2soon drv1_pri2soon, 
		@drv1_pri1now drv1_pri1now, @drv1_pri2now drv1_pri2now, 
		@drv2 drv2, @drv2_pri1soon drv2_pri1soon, @drv2_pri2soon drv2_pri2soon,
		@drv2_pri1now drv2_pri1now, @drv2_pri2now drv2_pri2now, 
		@trc trc, @trc_pri1soon trc_pri1soon, @trc_pri2soon trc_pri2soon,  
		@trc_pri1now trc_pri1now,  @trc_pri2now trc_pri2now,
		@trl1 trl1, @trl1_pri1soon trl1_pri1soon, @trl1_pri2soon trl1_pri2soon, 
		@trl1_pri1now trl1_pri1now, @trl1_pri2now trl1_pri2now, 
		@trl2 trl2, @trl2_pri1soon trl2_pri1soon, @trl2_pri2soon trl2_pri2soon,
		@trl2_pri1now trl2_pri1now, @trl2_pri2now trl2_pri2now,		
		convert(char(6), '') lrq_equip_type, ' ' lrq_not, convert(char(6), '') lrq_type,
		' ' lrq_manditory, convert(char(80), '') requirement, 
		convert(char(13), '') asgn_id

GO
GRANT EXECUTE ON  [dbo].[d_notices_lrq_sp] TO [public]
GO
