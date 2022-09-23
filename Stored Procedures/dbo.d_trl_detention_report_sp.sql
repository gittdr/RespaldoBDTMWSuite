SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- create procedure
CREATE PROCEDURE [dbo].[d_trl_detention_report_sp]
	@det_start_begin    datetime, 
	@det_end_begin		datetime,
	@det_end_end       	datetime,
	@billto				varchar(8),
	@drp_location_cmp	varchar(8),
	@drp_location_ctymnstct	varchar(30)
AS	

select e1.evt_trailer1, 
	(select o.ord_number from orderheader o where o.ord_hdrnumber = e1.ord_hdrnumber) ord_number, 
	e1.evt_status, 
	e1.evt_sequence, 
	e1.evt_mov_number, 
	DateDiff(d, e2.evt_startdate, e1.evt_enddate) 'trl_detention_days', 
	e2.evt_startdate 'trl_drop_st_date', 
	e2.evt_enddate 'trl_drop_end_date', 
	e1.evt_startdate 'trl_pul_startdate', 
	e1.evt_enddate 'trl_pul_enddate',
	s1.cmp_id  'trl_location',
	s1.cmp_name 'trl_location_name',
	s1.stp_city 'trl_location_city',
	c.cty_nmstct  'trl_location_cty_nmstct',
	isNull(ord_billto,'UNKNOWN') ord_billto,
	(select c.cmp_name from company c inner join orderheader o on c.cmp_id = o.ord_billto where o.ord_hdrnumber = e2.ord_hdrnumber) 'ord_billto_name',
	e1.evt_status 'pul_status',
	e2.evt_status 'drop_status',
	1 sort_by_billto,
	cast(@det_start_begin as datetime) 'start_det_calc_date'
from event e1 inner join
	(select * from event se1
	where se1.evt_sequence = 1 
		and evt_status = 'DNE' 
		and exists (select 1 from event se2 
					where se2.evt_eventcode = 'PUL' 
						and se1.stp_number = se2.stp_number)) e2
	on e1.stp_number = e2.stp_number
	join stops s1 on s1.stp_number = e1.stp_number 
	left join orderheader o on e2.ord_hdrnumber = o.ord_hdrnumber
	left join city c on s1.stp_city = c.cty_code
where e1.evt_eventcode = 'PUL'
	and ((e1.evt_status <>'DNE')  OR (e1.evt_status = 'DNE' AND e2.evt_enddate > @det_start_begin ))
	and ((e1.evt_status = 'DNE' AND e1.evt_enddate between @det_end_begin and @det_end_end ) OR (e1.evt_status = 'OPN'))
	and ((@billto	 = 'UNKNOWN') OR isNull(ord_billto,'UNKNOWN') = @billto	)
	and (@drp_location_cmp = 'UNKNOWN' OR isNull(s1.cmp_id,'UNKNOWN') = @drp_location_cmp)
	and (@drp_location_ctymnstct = 'UNKNOWN' OR c.cty_nmstct = @drp_location_ctymnstct)
order by e1.evt_enddate



GO
GRANT EXECUTE ON  [dbo].[d_trl_detention_report_sp] TO [public]
GO
