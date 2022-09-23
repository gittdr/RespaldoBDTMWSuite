SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_rtd_adjusted_sp] @pdt_payperiod datetime, @psd_asgn_id varchar(8), @terminal varchar(6), @rtd_id integer
as  

/*
	PTS 43872 - DJM - 3/09/2008 - Proc return information for RTD records and Legheader Minimum Pay information that have been processed.
*/

declare @rtddata Table(
	rpt_seq		integer					not null	identity,
	rtd_id		integer					not null,
	rtd_trcid	varchar(25)				not null,
	rtd_payperiod	datetime			null,
	rtd_terminal	varchar(6)			null,
	rtd_createby	varchar(255)		null,
	rtd_createdt	datetime			null,
	rtd_lastupdateby	varchar(255)	null,
	rtd_lastupdatedt	datetime		null,
	lgh_number			integer			not null,
	lgh_startdate		datetime		null,
	rtd_pay_ineligible	char(1)			null,
	ord_hdrnumber		integer			null,
	ivh_hdrnumber		int				null,
	ivh_invoicenumber	varchar(12)		null,
	ivd_number			integer			null,
	ivd_description		varchar(60)		null,
	cht_itemcode		varchar(6)		null,
	ivd_charge			money			null, 
	ivh_billdate		datetime		null,
	ivh_invoicestatus	varchar(6)		null,
	pyd_number			int				null,
	pyt_itemcode		varchar(6)		null,
	pyd_description		varchar(75)		null,
	pyd_amount			money			null,
	pyh_payperiod		datetime		null,
	pyd_workperiod		datetime		null,
	pyd_status			varchar(6)		null,
	lgh_pay				money			null,
	lgh_min_pay_amt		money			null,
	lgh_miles			integer			null,
	mod_type			integer			null,
	rtd_pay_total		decimal			null,
	rtd_pay_min			decimal			null
)

/*
	Get the GI setting values that control the calculation
*/
Declare @CPM	as money,
	@ExcludePT	as	varchar(60)

Select @CPM = (gi_integer1 * .01),
	@ExcludePT = gi_string1
from Generalinfo
Where gi_name = 'TRCRTDMinPayCalcValues'

SELECT @ExcludePT = ',' + LTRIM(RTRIM(ISNULL(@ExcludePT, '')))  + ','  

/*
*	Get the Paytype code used for the RTD Minimum Pay adjustment.
*/
Declare @paytype varchar(8)
select @paytype = gi_string1 from generalinfo where gi_name = 'TRCRTDMinPayType'

/*
*	Insert rows for Revenue added for Orderes on any of the Trip Segments attached to the RTD
*/
insert into @rtddata (	rtd_id,
	rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	lgh_number,
	lgh_startdate,
	rtd_pay_ineligible,
	ord_hdrnumber,
	ivh_hdrnumber,
	ivd_number,
	ivd_description,
	cht_itemcode,
	ivd_charge, 
	ivh_billdate,
	ivh_invoicestatus,
	ivh_invoicenumber,
	lgh_miles,
	mod_type)
Select rtd_id,rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	leg.lgh_number,
	leg.lgh_startdate,
	rtd_pay_ineligible,
	ih.ord_hdrnumber,
	ih.ivh_hdrnumber,
	id.ivd_number,
	id.ivd_description,
	id.cht_itemcode,
	id.ivd_charge,
	ih.ivh_billdate,
	ih.ivh_invoicestatus,
	ivh_invoicenumber,
	isNull(leg.lgh_miles,0),
	2
from tractor_rtd join legheader leg on tractor_rtd.rtd_id = leg.lgh_rtd_id
		join (select lgh_number, ord_hdrnumber from stops where stops.ord_hdrnumber > 0 group by lgh_number, ord_hdrnumber) stpord on stpord.lgh_number = leg.lgh_number
		join invoiceheader ih on ih.ord_hdrnumber = stpord.ord_hdrnumber
		join invoicedetail id on ih.ivh_hdrnumber = id.ivh_hdrnumber
where rtd_payperiod is not null 
	and isNull(rtd_payperiod,'1900-01-01') = @pdt_payperiod
	and isNull(rtd_pay_ineligible,0) = 0
	and CHARINDEX(@psd_asgn_id, 'UNKNOWN,' + isnull(tractor_rtd.rtd_trcid,'')) > 0  
	and CHARINDEX(@terminal, 'UNK,' + isnull(tractor_rtd.rtd_terminal,'')) > 0  
	and (Case
			when @rtd_id > 0 then @rtd_id
			else tractor_rtd.rtd_id
		end ) = tractor_rtd.rtd_id
	and exists (select 1 from invoiceheader ih join stops on ih.ord_hdrnumber = stops.ord_hdrnumber 
				where ih.ivh_billdate > rtd_payperiod
					and rtd_id = leg.lgh_rtd_id
					and stops.lgh_number = leg.lgh_number)
					
					


/*
*	Insert rows for Pay added for any Trip Segments attached to the RTD
*/
insert into @rtddata (	
	rtd_id,
	rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	lgh_number,
	lgh_startdate,
	rtd_pay_ineligible,
	ord_hdrnumber,
	pyd_number,
	pyt_itemcode,
	pyd_description,
	pyd_amount,
	pyh_payperiod,
	pyd_workperiod,
	lgh_pay,
	pyd_status,
	lgh_miles,
	mod_type)
Select rtd_id,rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	leg.lgh_number,
	leg.lgh_startdate,
	rtd_pay_ineligible,
	leg.ord_hdrnumber,
	pd.pyd_number,
	pd.pyt_itemcode,
	pd.pyd_description,
	pd.pyd_amount,
	pd.pyh_payperiod,
	pyd_workperiod,
	pd.pyd_amount,
	pd.pyd_status,
	isNull(leg.lgh_miles,0),
	1
from tractor_rtd join legheader leg on tractor_rtd.rtd_id = leg.lgh_rtd_id
	join paydetail pd on leg.lgh_number = pd.lgh_number and pd.asgn_type = 'TRC'
	join paytype on pd.pyt_itemcode = paytype.pyt_itemcode
	left join payheader ph on pd.pyh_number = ph.pyh_pyhnumber
where rtd_payperiod is not null 
	and isNull(rtd_payperiod,'1900-01-01') = @pdt_payperiod
	and isNull(rtd_pay_ineligible,0) = 0
	and CHARINDEX(@psd_asgn_id, 'UNKNOWN,' + isnull(tractor_rtd.rtd_trcid,'')) > 0  
	and CHARINDEX(@terminal, 'UNK,' + isnull(tractor_rtd.rtd_terminal,'')) > 0  
	and isNull(paytype.pyt_rtd_exclude,'N') = 'N'
	and (Case
			when @rtd_id > 0 then @rtd_id
			else tractor_rtd.rtd_id
		end ) = tractor_rtd.rtd_id
	and exists (select 1 from paydetail where paydetail.pyh_payperiod > rtd_payperiod and paydetail.pyh_payperiod < '2049-12-31')
	


/*
*	Show any adjusting minimum entry that is of the correct Paytype AND has the RTD number in the field.
*/	
/*
insert into @rtddata
select rtd_id,
	rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	0,
	'1900-01-01',
	0,
	0,
	'',
	'',
	0,
	0,
	0,
	0,
	pyd_number,
	pyt_itemcode,
	pyd_description,
	pd.lgh_number,
	pyd_amount,
	rtd_pay_ineligible
from tractor_rtd join paydetail pd on pd.asgn_type = 'TRC' 
			and pd.asgn_id = rtd_trcid
			and pd.pyt_itemcode = @paytype
			and CHARINDEX('RTD:'+ cast(rtd_id as varchar(10)), pd.pyd_description) > 0
where isNull(rtd_payperiod,'1900-01-01') = @pdt_payperiod
	and CHARINDEX(@psd_asgn_id, 'UNKNOWN,' + tractor_rtd.rtd_trcid) > 0
	and CHARINDEX(@terminal, 'UNK,' + tractor_rtd.rtd_terminal) > 0
	and (Case
			when @rtd_id > 0 then @rtd_id
			else tractor_rtd.rtd_id
		end ) = tractor_rtd.rtd_id
*/

-- Compute the pay for the RTD records
update @rtddata
set lgh_pay = (select sum(isNull(pd2.pyd_amount,0)) from paydetail pd2 join paytype on pd2.pyt_itemcode = paytype.pyt_itemcode 
		where pd2.lgh_number = paydetail.lgh_number 
			and pd2.asgn_id = paydetail.asgn_id 
			and pd2.asgn_type = paydetail.asgn_type 
			and isNull(paytype.pyt_rtd_exclude,'N') = 'N')
from paydetail join @rtddata r on r.lgh_number = paydetail.lgh_number
where paydetail.asgn_id = r.rtd_trcid 
	and paydetail.asgn_type = 'TRC'
	and CHARINDEX(@ExcludePT, ',' + paydetail.pyt_itemcode + ',') = 0
	and r.pyd_number = (select max(r3.pyd_number) from @rtddata r3 where r3.lgh_number = r.lgh_number)
	--and r.lgh_number > 0

-- Update any minimum pay records
update @rtddata
set lgh_pay = pyd_amount
where lgh_number = 0 and lgh_pay = 0

-- Compute the Minimum Pay required for the Leg.
Update @rtddata
set lgh_min_pay_amt = (isNull(lgh_miles,0) * @CPM)
from @rtddata r
where r.rpt_seq = (select max(r3.rpt_seq) from @rtddata r3 where r3.lgh_number = r.lgh_number)

-- PTS 49363 - DJM - set the total pay for the RTD
update @rtddata
set rtd_pay_total = (select sum(r2.lgh_pay) from @rtddata r2 where r2.rtd_id = r.rtd_id)
from @rtddata r

-- PTS 49363 - DJM - set the total minimum pay for the RTD
update @rtddata
set rtd_pay_min = (select sum(r2.lgh_min_pay_amt) from @rtddata r2 where r2.rtd_id = r.rtd_id)
from @rtddata r






/*
	Return the results
*/
select rtd_id,
	rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	lgh_number,
	lgh_startdate,
	rtd_pay_ineligible,
	data.ord_hdrnumber,
	ivh_hdrnumber,
	ivd_number,
	ivd_description,
	cht_itemcode,
	ivd_charge, 
	ivh_billdate,
	ivh_invoicestatus,
	ivh_invoicenumber
	pyd_number,
	pyt_itemcode,
	pyd_description,
	pyd_amount,
	pyh_payperiod,
	pyd_workperiod,
	lgh_pay,
	lgh_miles,
	lgh_min_pay_amt,
	(select isNull(ord_number,'UNKNOWN') from orderheader where orderheader.ord_hdrnumber = data.ord_hdrnumber) ord_number,
	ivh_invoicenumber,
	mod_type,
	rpt_seq,
	rtd_pay_total,
	rtd_pay_min
from @rtddata data
--where lgh_pay > 0 

GO
GRANT EXECUTE ON  [dbo].[d_rtd_adjusted_sp] TO [public]
GO
