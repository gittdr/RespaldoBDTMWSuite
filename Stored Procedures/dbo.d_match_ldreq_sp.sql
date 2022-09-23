SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_match_ldreq_sp]
	@lghnumber int,
	@movnumber int, 
	--PTS 31953 JJF 3/10/06
	@ord_hdrnumber int
	--END PTS 31953 JJF 3/10/06 
as

-- PTS 18488 -- BL (start)
DECLARE
	@lgh_startdate datetime, @lgh_enddate datetime
-- PTS 18488 -- BL (end)

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
	id_type_str varchar(13) null,
	-- PTS 18488 -- BL (start)
	lrq_expire_date		datetime	NULL)
	-- PTS 18488 -- BL (end)
	
--PTS 31953 JJF 3/10/06 
IF ISNULL(@lghnumber, 0) > 0 BEGIN
	-- PTS 18488 -- BL (start)
	--    Get the start and end dates for the LEG
	SELECT 	@lgh_startdate = lgh_startdate,
		@lgh_enddate = lgh_enddate
	FROM legheader
	WHERE lgh_number = @lghnumber
	-- PTS 18488 -- BL (end)
END
ELSE IF ISNULL(@ord_hdrnumber, 0) > 0 BEGIN
	--Assume this comes from ticket order entry, which does not yet have a leg defined
	SELECT 	@lgh_startdate = toep.toep_delivery_date,
		@lgh_enddate = toep.toep_delivery_date
	FROM	ticket_order_entry_plan toep 
	WHERE	toep.ord_hdrnumber = @ord_hdrnumber
END
--END PTS 31953 JJF 3/10/06 

-- Get the load requirements for leg header or move into the temp table
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
	'',
	-- PTS 18488 -- BL (start)
	l.lrq_expire_date
	-- PTS 18488 -- BL (end)
from loadrequirement l
where l.mov_number = @movnumber
-- PTS 18488 -- BL (start)
AND ISNULL(l.lrq_expire_date,'20491231 23:59:59') >= @lgh_startdate
AND ISNULL(l.lrq_default, 'N') IN ('Y','N')
-- PTS 18488 -- BL (end)

if (select count(*) from #temp) > 0
	begin

-- Get asset type name
	update #temp
		set equip_type_str = isnull(labelfile.name, '')
		from labelfile, #temp
		where labelfile.labeldefinition = 'AssType'
		and labelfile.abbr = #temp.lrq_equip_type

-- Get requirement type name
	update #temp
		set type_str = isnull(labelfile.name, '')
		from labelfile, #temp
		where labelfile.labeldefinition in ('TrlAcc', 'TrcAcc', 'DrvAcc')
		and labelfile.abbr = #temp.lrq_type

-- Get manditory name
	update #temp
		set manditory_str = ' should'
			where lrq_manditory = 'N'
	update #temp
		set manditory_str = ' must'
			where lrq_manditory = 'Y'

-- Get not name
	update #temp
		set not_str = ' have/be'
			where lrq_not = 'Y'
	update #temp
		set not_str = ' not have/be'
			where lrq_not = 'N'

-- Get id type
	update #temp
		set id_type_str = 'Pickup '
			where def_id_type = 'PUP'
	update #temp
		set id_type_str = 'Drop '
			where def_id_type = 'DRP'
	update #temp
		set id_type_str = 'Pickup & Drop '
			where def_id_type = 'BOTH'

-- Parse the load requirement string
	update #temp
		set requirement = 'At ' + id_type_str + ' ' + equip_type_str + manditory_str + not_str + ' ' + type_str + ' ' + convert(char(3), lrq_quantity)

	end

select DISTINCT requirement,
	lrq_equip_type,
	lrq_not,
	lrq_type,
	lrq_manditory,
	assign_id,
	-- PTS 18488 -- BL (start)
	lrq_expire_date,
	@lgh_enddate,
	-- PTS 18488 -- BL (end)
	-- 06/12/2007 MDH PTS: 37170: Added @lgh_startdate <<START>>
	@lgh_startdate
	-- 06/12/2007 MDH PTS: 37170: Added @lgh_startdate <<END>>
from #temp

GO
GRANT EXECUTE ON  [dbo].[d_match_ldreq_sp] TO [public]
GO
