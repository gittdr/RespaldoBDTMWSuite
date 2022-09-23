SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[ap_transfer_to_flatfile_sp]	@pyh_pyhnumber	int
as

declare	@gross_pretax	money,
	@gross_aftertax	money

select  @gross_pretax = 0,
	@gross_aftertax = 0

select 	m.mpp_id employee_number, 
	m.mpp_otherid alt_id,
	m.mpp_lastfirst employee_name, 
	pt.pyt_description pay_item,
	sum(pyd_amount) gross_pretax,
	@gross_aftertax gross_aftertax,
	o.ord_hdrnumber,
	pt.pyt_ap_glnum gl_segment1,
	' ' gl_segment2,
	c.cmp_altid gl_segment3,
	'00' gl_segment4
into	#temp_ap_transfer
from	manpowerprofile m, paydetail pd, orderheader o, paytype pt, company c
where	pd.pyh_number = @pyh_pyhnumber and
	m.mpp_id = pd.asgn_id and
	pt.pyt_itemcode = pd.pyt_itemcode and
	o.ord_hdrnumber = pd.ord_hdrnumber and
	c.cmp_id = o.ord_shipper and
	pt.pyt_pretax = 'Y' 
group by m.mpp_id, o.ord_hdrnumber, pt.pyt_description, m.mpp_otherid, m.mpp_lastfirst, pt.pyt_ap_glnum, c.cmp_altid
order by m.mpp_id, o.ord_hdrnumber, pt.pyt_description

insert into #temp_ap_transfer
select 	m.mpp_id employee_number, 
	m.mpp_otherid alt_id,
	m.mpp_lastfirst employee_name,  
	pt.pyt_description pay_item,
	@gross_pretax gross_pretax,
	sum(pyd_amount) gross_aftertax,
	o.ord_hdrnumber,
	pt.pyt_ap_glnum gl_segment1,
	' ' gl_segment2,
	c.cmp_altid gl_segment3,
	'00' gl_segment4
from	manpowerprofile m, paydetail pd, orderheader o, paytype pt, company c
where	pd.pyh_number = @pyh_pyhnumber and
	m.mpp_id = pd.asgn_id and
	pt.pyt_itemcode = pd.pyt_itemcode and
	o.ord_hdrnumber = pd.ord_hdrnumber and
	c.cmp_id = o.ord_shipper and
	pt.pyt_pretax = 'N' 
group by m.mpp_id, o.ord_hdrnumber, pt.pyt_description, m.mpp_otherid, m.mpp_lastfirst, pt.pyt_ap_glnum, c.cmp_altid
order by m.mpp_id, o.ord_hdrnumber, pt.pyt_description

insert into #temp_ap_transfer
select 	m.mpp_id employee_number, 
	m.mpp_otherid alt_id,
	m.mpp_lastfirst employee_name,   
	pt.pyt_description pay_item,
	sum(pyd_amount) gross_pretax,
	0 gross_aftertax,
	0 ord_hdrnumber,
	pt.pyt_ap_glnum gl_segment1,
	' ' gl_segment2,
	'99999' gl_segment3,
	'00' gl_segment4
from	manpowerprofile m, paydetail pd, paytype pt
where	pd.pyh_number = @pyh_pyhnumber and
	m.mpp_id = pd.asgn_id and
	pt.pyt_itemcode = pd.pyt_itemcode and
	(pd.ord_hdrnumber is null or pd.ord_hdrnumber = 0) and
	pt.pyt_pretax = 'Y' 
group by m.mpp_id, pt.pyt_description, m.mpp_otherid, m.mpp_lastfirst, pt.pyt_ap_glnum
order by m.mpp_id, pt.pyt_description

insert into #temp_ap_transfer
select 	m.mpp_id employee_number, 
	m.mpp_otherid alt_id, 
	m.mpp_lastfirst employee_name, 
	pt.pyt_description pay_item,
	0 gross_pretax,
	sum(pyd_amount) gross_aftertax,
	0 ord_hdrnumber,
	pt.pyt_ap_glnum gl_segment1,
	' ' gl_segment2,
	'99999' gl_segment3,
	'00' gl_segment4
from	manpowerprofile m, paydetail pd, paytype pt
where	pd.pyh_number = @pyh_pyhnumber and
	m.mpp_id = pd.asgn_id and
	pt.pyt_itemcode = pd.pyt_itemcode and
	(pd.ord_hdrnumber is null or pd.ord_hdrnumber = 0) and
	pt.pyt_pretax = 'N' 
group by m.mpp_id, pt.pyt_description, m.mpp_otherid, m.mpp_lastfirst, pt.pyt_ap_glnum
order by m.mpp_id, pt.pyt_description

select * from #temp_ap_transfer

GO
GRANT EXECUTE ON  [dbo].[ap_transfer_to_flatfile_sp] TO [public]
GO
