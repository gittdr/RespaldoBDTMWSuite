SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	PTS 11689 dpete state changed to 6 char on database, must truncate for flat file (also noticed count was summed
       from freightdetail ,but weight was not - fixed
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 **/


CREATE PROCEDURE [dbo].[edi_210_record_id_4_34_sp] 
	@ord_hdrnumber integer,
	@trpid varchar(20),
	@docid varchar(30)
 as

declare @emptystring varchar(30)
declare @datacol varchar(250)

SELECT @trpID = ISNULL(@trpid,'NOVALUE')

select @emptystring=''

-- put data into temp table for massaging
select
	s.stp_number,
	LEFT(ISNULL(e.edicode,'  '),2) edicode,
	weight=@emptystring,
	quantity=@emptystring,
	city_name=LEFT(ISNULL(ci.cty_name,'  '),18),
	state= SUBSTRING(s.stp_state,1,2),
	zip=LEFT(REPLACE(ISNULL(isnull(co.cmp_zip,ci.cty_zip),'  '),'-',''),9),
	LEFT(ISNULL(co.cmp_name,'  '),30) cmp_name
into #210_stops_temp
from stops s LEFT OUTER JOIN  eventcodetable e ON e.abbr=s.stp_event, 
	company co, city ci
where s.ord_hdrnumber=@ord_hdrnumber and
	co.cmp_id=s.cmp_id and
	s.stp_city=ci.cty_code 
	--e.abbr=*s.stp_event

-- problem if weight or count is recorded in decimal places, ff only shows whole number
select
	quantity=RIGHT(convert(varchar(12),CONVERT(int,sum(f.fgt_count))),6),
	weight = RIGHT(convert(varchar(12),CONVERT(int,sum(f.fgt_weight))),6),
	t.stp_number
into #210_fgt_temp
from #210_stops_temp t,freightdetail f where
	t.stp_number=f.stp_number
	group by t.stp_number

update #210_stops_temp set
	#210_stops_temp.quantity=#210_fgt_temp.quantity,
	#210_stops_temp.weight=#210_fgt_temp.weight
from #210_fgt_temp where
	#210_stops_temp.stp_number=#210_fgt_temp.stp_number


INSERT edi_210
SELECT data_col = '4' +		-- Record ID
'34' +				-- Record Version
edicode +
	replicate(' ',2-datalength(edicode)) +
	replicate('0',6-datalength(weight)) +
weight +
	replicate('0',6-datalength(quantity)) +
quantity +
city_name +
	replicate(' ',18-datalength(city_name)) +
state +
	replicate(' ',2-datalength(state)) +
zip +
	replicate(' ',9-datalength(zip)) +
cmp_name +
	replicate(' ',30-datalength(cmp_name)),
 trp_id = @trpid,
doc_id = @docid
FROM #210_stops_temp




GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_4_34_sp] TO [public]
GO
