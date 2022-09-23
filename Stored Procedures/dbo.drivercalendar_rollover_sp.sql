SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[drivercalendar_rollover_sp]
	(@dc	VARCHAR(6))
AS
DECLARE	@getdate	DATETIME

declare @li_count	int,
	@li_try		int,
	@pyd_number	int,
	@li_number	int

declare	@ls_brn_id			varchar(6),
	@ldec_brn_hourlyrate 		money

create table #temp_paydetail
	(row_id			int		identity,
	pyd_number		int		not null,
 	asgn_id			varchar(8)	null,
	pyd_prorap		char(1) 	null,
	pyd_payto		varchar(12) 	null,
   	pyt_itemcode		varchar(6)	null,
  	pyd_description		varchar(30)	null,
 	pyd_quantity		float		null,
 	pyd_rateunit		varchar(6)	null,
 	pyd_unit		varchar(6)	null,
 	pyd_rate		money		null,
 	pyd_amount		money		null, 
	pyd_pretax		char(1)		null,
	pyd_glnum		varchar(32) 	null,
 	pyt_fee1		money		null,
	pyt_fee2		money		null,
	pyd_transdate		datetime	null)

SELECT @getdate = GETDATE()

select	@ls_brn_id = right('000'+convert(varchar,code),3)
from	labelfile
where	abbr = @dc
and	labeldefinition = 'Terminal'

select	@ldec_brn_hourlyrate = brn_hourlyrate
from	branch
where	brn_id = @ls_brn_id

--	LOR	PTS# 21113
If (select count(*) 
	from drivercalendar d, manpowerprofile m
--	where d.drc_bid_type in ('VAC', 'PD', 'SK') and
	where d.drc_week1_type in (select cpt_calendar_basis from calendar_paytypes) and
		m.mpp_id = d.mpp_id AND
		m.mpp_terminal = @dc) > 0
begin
	insert into #temp_paydetail 
	select		0 pyd_number,
			d.mpp_id ,
			m.mpp_actg_type pyd_prorap,
			m.mpp_payto pyd_payto,
			c.pyt_itemcode,
			p.pyt_description pyd_description,
			drc_week1_hours pyd_quantity,
			p.pyt_rateunit pyd_rateunit,
			p.pyt_unit pyd_unit,
			IsNull(coalesce(mpp_avghourlypay,@ldec_brn_hourlyrate),0) pyd_rate,
			(IsNull(coalesce(mpp_avghourlypay,@ldec_brn_hourlyrate),0) * drc_week1_hours) pyd_amount,
			p.pyt_pretax pyd_pretax,
			case m.mpp_actg_type
				when 'A' then IsNull(p.pyt_ap_glnum, '')
				when 'P' then IsNull(p.pyt_pr_glnum, '')
			end pyd_glnum,
			pyt_fee1,
        		pyt_fee2,
			DATEADD(day, -1, (DATEADD(day, drc_week1_dow, drc_week))) pyd_transdate
	from calendar_paytypes c, drivercalendar d, manpowerprofile m, paytype p
	where c.cpt_calendar_basis = d.drc_week1_type and
			m.mpp_id = d.mpp_id and 
			c.pyt_itemcode = p.pyt_itemcode
--select * from #temp_paydetail 

	-- Get new pyd_number
	select @li_count = count(*) 
	from #temp_paydetail
	
	select @li_try = 1	
	while @li_try <= @li_count
	Begin
		EXEC @pyd_number = getsystemnumber 'PYDNUM', ''   
	
		update #temp_paydetail
		set	pyd_number = @pyd_number
		where	row_id = @li_try
	
		select @li_try = @li_try + 1
	End
--select * from #temp_paydetail 

	insert into paydetail (
		pyd_number,
		pyh_number,
	  	lgh_number,
	  	asgn_number,
	 	asgn_type,
	 	asgn_id,
		pyd_prorap,
		pyd_payto,
	    pyt_itemcode,
		mov_number,
	  	pyd_description,
	 	pyd_quantity,
	 	pyd_rateunit,
	 	pyd_unit,
	 	pyd_rate,
	 	pyd_amount, 
		pyd_pretax,
		pyd_glnum,
	 	pyd_currencydate, 
		pyd_status,
	    pyh_payperiod,
	    pyd_workperiod,
	    pyd_transdate,
		pyd_minus,
	   	pyd_sequence,
	 	ord_hdrnumber,
	 	pyt_fee1,
	    pyt_fee2,
	    pyd_grossamount,
	 	pyd_updatedon)
	select	d.pyd_number,
		0,
		0,
		0,
	 	'DRV' ,
	 	d.asgn_id,
		d.pyd_prorap,
		d.pyd_payto,
	    d.pyt_itemcode,
		0,
	  	d.pyd_description,
	 	d.pyd_quantity,
	 	d.pyd_rateunit,
	 	d.pyd_unit,
	 	d.pyd_rate,
	 	d.pyd_amount, 
		d.pyd_pretax,
		d.pyd_glnum,
	 	getdate() , 
		'PND' ,
	    '2049-12-31',
	    '2049-12-31',
	    d.pyd_transdate,
		1,
	   	999 ,
		0,
	 	d.pyt_fee1,
	    d.pyt_fee2,
	    d.pyd_amount,
	 	getdate() 
	from  #temp_paydetail d
end

INSERT	drivercalendarhistory
		(mpp_id,
		 dch_sequence,
		 dch_week,
		 dch_week1_dow,
		 dch_week1_starttime,
		 dch_week1_hours,
		 dch_week1_type,
		 dch_week1_store,
		 dch_week1_route,
		 dch_week2_dow,
		 dch_week2_starttime,
		 dch_week2_hours,
		 dch_week2_type,
		 dch_week2_store,
		 dch_week2_route,
		 dch_bid_dow,
		 dch_bid_starttime,
		 dch_bid_hours,
		 dch_bid_type,
		 dch_bid_store,
		 dch_bid_route)
SELECT	drivercalendar.mpp_id,
			drivercalendar.drc_sequence,
			CASE 
				WHEN ISNULL(drivercalendar.drc_week, '19000101') = '19000101' THEN DATEADD(dd, -7, @getdate)
				ELSE drivercalendar.drc_week
			END,			
			drivercalendar.drc_week1_dow,
			drivercalendar.drc_week1_starttime,
			drivercalendar.drc_week1_hours,
			drivercalendar.drc_week1_type,
			drivercalendar.drc_week1_store,
			drivercalendar.drc_week1_route,
			drivercalendar.drc_week2_dow,
			drivercalendar.drc_week2_starttime,
			drivercalendar.drc_week2_hours,
			drivercalendar.drc_week2_type,
			drivercalendar.drc_week2_store,
			drivercalendar.drc_week2_route,
			drivercalendar.drc_bid_dow,
			drivercalendar.drc_bid_starttime,
			drivercalendar.drc_bid_hours,
			drivercalendar.drc_bid_type,
			drivercalendar.drc_bid_store,
			drivercalendar.drc_bid_route
FROM	drivercalendar, manpowerprofile
WHERE	manpowerprofile.mpp_id = drivercalendar.mpp_id AND
				manpowerprofile.mpp_terminal = @dc

UPDATE	drivercalendar
   SET	drc_week1_dow = drc_week2_dow,
		drc_week1_starttime = drc_week2_starttime,
		drc_week1_hours = drc_week2_hours,
		drc_week1_type = drc_week2_type,
		drc_week1_store = drc_week2_store,
		drc_week1_route = drc_week2_route,
		drc_week2_dow = drc_bid_dow, 
		drc_week2_starttime = drc_bid_starttime,
		drc_week2_hours = drc_bid_hours,
		drc_week2_type = drc_bid_type,
		drc_week2_store = drc_bid_store,
		drc_week2_route = drc_bid_route,
		drc_week = @getdate
  FROM	manpowerprofile
 WHERE	manpowerprofile.mpp_id = drivercalendar.mpp_id AND
		manpowerprofile.mpp_terminal = @dc

DELETE	drivercalendar
 WHERE	((drc_week1_dow IS NULL OR 
		  drc_week1_starttime IS NULL) AND
		  (drc_week1_type <> 'ONCALL')) AND
		((drc_week2_dow IS NULL OR 
		  drc_week2_starttime IS NULL) AND
		  (drc_week2_type <> 'ONCALL')) AND
		((drc_bid_dow IS NULL OR 
		  drc_bid_starttime IS NULL) AND
		 (drc_bid_type <> 'ONCALL'))






GO
GRANT EXECUTE ON  [dbo].[drivercalendar_rollover_sp] TO [public]
GO
