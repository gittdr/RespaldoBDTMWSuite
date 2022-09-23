SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 
MODIFICATION LOG

PTS 11689 state field on database changed to 6 pos,must trucate for flat file

*/
CREATE PROCEDURE [dbo].[edi_210_record_id_4_sp] 
	@ord_hdrnumber integer,
	@trpid varchar(20)
 as

declare @emptystring varchar(30)

select @emptystring=''

-- put data into temp table for massaging
select
	s.stp_number,
	e.edicode,
	weight=@emptystring,
	quantity=@emptystring,
	city_name=ci.cty_name,
	state=SUBSTRING(s.stp_state,1,2),
	zip=isnull(co.cmp_zip,ci.cty_zip),
	co.cmp_name
into #210_stops_temp
from stops s, company co, city ci, eventcodetable e
	where s.ord_hdrnumber=@ord_hdrnumber and
	co.cmp_id=s.cmp_id and
	s.stp_city=ci.cty_code and
	e.abbr=s.stp_event

-- massage
select
	quantity=RIGHT(CONVERT(varchar(12),CONVERT(int,SUM(ISNULL(f.fgt_count,0)))),6),
	weight=RIGHT(CONVERT(varchar(12),CONVERT(int,SUM(ISNULL(f.fgt_weight,0)))),6),
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

update #210_stops_temp set
	edicode=isnull(edicode,''),
	quantity=isnull(quantity,''),
	zip=isnull(zip,'')

-- return the row from the temp table
INSERT edi_210
SELECT 
data_col = '4' +		-- Record ID
'10' +				-- Record Version
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
trp_id=@trpid
FROM #210_stops_temp
GO
GRANT EXECUTE ON  [dbo].[edi_210_record_id_4_sp] TO [public]
GO
