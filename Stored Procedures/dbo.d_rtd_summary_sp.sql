SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_rtd_summary_sp] @pdt_payperiod datetime, @psd_asgn_id	varchar(8), @terminal varchar(6), @rtd_id integer
as  

/*
	PTS 43872 - DJM - 9/19/2008 - Proc return information for RTD records and Legheader Minimum Pay information that have been processed.
*/

declare @rtddata Table(
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
	ord_hdrnumber		integer			null,
	mov_number			integer			null,
	lgh_startcty_nmstct	varchar(25)		null,
	lgh_endcty_nmstct	varchar(25)		null,
	lgh_miles			integer			null,
	lgh_pay				money			null,
	lgh_min_pay_amt		money			null,
	rtd_diff			money			null,
	pyd_number			integer			null,
	pyt_itemcode		varchar(6)		null,
	pyd_description		varchar(100)	null,
	pyd_lgh_number		integer			null,
	pyd_amount			money			null,
	rtd_pay_ineligible	char(1)			null
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


insert into @rtddata
select rtd_id,
	rtd_trcid,
	rtd_payperiod,
	rtd_terminal,
	rtd_createby,
	rtd_createdt,
	rtd_lastupdateby,
	rtd_lastupdatedt,
	legheader.lgh_number,
	lgh_startdate,
	legheader.ord_hdrnumber,
	legheader.mov_number,
	lgh_startcty_nmstct,
	lgh_endcty_nmstct,
	isNull(lgh_miles,0),
	0,
	0,
	0,
	pyd_number,
	pd.pyt_itemcode,
	pyd_description,
	pd.lgh_number,
	pyd_amount,
	rtd_pay_ineligible
from tractor_rtd join legheader on tractor_rtd.rtd_id = legheader.lgh_rtd_id
	join paydetail pd on pd.asgn_type = 'TRC' 
		and pd.asgn_id = rtd_trcid
		and pd.lgh_number = legheader.lgh_number
	join paytype on pd.pyt_itemcode = paytype.pyt_itemcode
where isNull(rtd_payperiod,'1900-01-01') = @pdt_payperiod
	and CHARINDEX(@psd_asgn_id, 'UNKNOWN,' + tractor_rtd.rtd_trcid) > 0
	and CHARINDEX(@terminal, 'UNK,' + tractor_rtd.rtd_terminal) > 0
	and isNull(rtd_pay_ineligible,'N') 	= 'N'
	and isNull(paytype.pyt_rtd_exclude,'N') = 'N'
	and (Case
			when @rtd_id > 0 then @rtd_id
			else tractor_rtd.rtd_id
		end ) = tractor_rtd.rtd_id
		

/*
*	Show any adjusting minimum entry that is of the correct Paytype AND has the RTD number in the field.
*/	
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
	and isNull(rtd_pay_ineligible,'N') 	= 'N'
	and (Case
			when @rtd_id > 0 then @rtd_id
			else tractor_rtd.rtd_id
		end ) = tractor_rtd.rtd_id

-- Compute the pay for the RTD records
update @rtddata
set lgh_pay = (select sum(isNull(pd2.pyd_amount,0)) from paydetail pd2 join paytype on pd2.pyt_itemcode = paytype.pyt_itemcode
	where pd2.lgh_number = paydetail.lgh_number and pd2.asgn_id = paydetail.asgn_id and pd2.asgn_type = paydetail.asgn_type and isNull(paytype.pyt_rtd_exclude,'N') = 'N')
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
set lgh_min_pay_amt = (lgh_miles * @CPM)
from @rtddata r
where pyd_number = (select max(r3.pyd_number) from @rtddata r3 where r3.lgh_number = r.lgh_number)

update @rtddata
set rtd_diff = (select sum(isNull(r2.lgh_min_pay_amt,0) - isnull(r2.lgh_pay,0)) from @rtddata r2 where r2.rtd_id = r1.rtd_id)
from @rtddata r1


/*`
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
	data.ord_hdrnumber,
	mov_number,
	lgh_startcty_nmstct,
	lgh_endcty_nmstct,
	lgh_miles,
	lgh_pay,
	lgh_min_pay_amt,
	rtd_diff,
	0 release,
	pyd_number,
	pyt_itemcode,
	pyd_description,
	pyd_lgh_number,
	pyd_amount,
	(select min(lgh_startdate) from legheader where lgh_rtd_id = rtd_id) rtd_startdate,
	(select max(lgh_enddate) from legheader where lgh_rtd_id = rtd_id) rtd_enddate,
	@paytype rtd_minpaytype,
	(lgh_pay - lgh_min_pay_amt) lgh_diff,
	isNull(rtd_pay_ineligible,'N') rtd_pay_ineligible,
	(select ord_number from orderheader where orderheader.ord_hdrnumber = data.ord_hdrnumber)
from @rtddata data
--where lgh_pay > 0 





GO
GRANT EXECUTE ON  [dbo].[d_rtd_summary_sp] TO [public]
GO
