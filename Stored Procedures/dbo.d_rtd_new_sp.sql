SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_rtd_new_sp]	@paidflag int
as  

/*
	PTS 43872 - DJM - 9/19/2008 - New proc to return information for RTD records and Legheader Minimum Pay information that have not been
									assigned a Pay Period yet.
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

insert into @rtddata
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
	ord_hdrnumber,
	mov_number,
	lgh_startcty_nmstct,
	lgh_endcty_nmstct,
	isNull(lgh_miles,0),
	0,
	0,
	0,
	rtd_pay_ineligible
from tractor_rtd join legheader on tractor_rtd.rtd_id = legheader.lgh_rtd_id
	and isNull(rtd_payperiod,'1900-01-01') = '1900-01-01'
	and isNull(rtd_pay_ineligible,'N') = 'N'
	
-- Compute the pay for the RTD records
update @rtddata
set lgh_pay = isNull((select sum(isNull(pd2.pyd_amount,0)) from paydetail pd2 where pd2.lgh_number = paydetail.lgh_number 
														and pd2.asgn_id = paydetail.asgn_id		
														and pd2.asgn_type = paydetail.asgn_type
														and not exists (select 1 from paytype where paytype.pyt_itemcode = pd2.pyt_itemcode and isNull(paytype.pyt_rtd_exclude,'N') = 'Y')),0)
from paydetail join @rtddata r on r.lgh_number = paydetail.lgh_number
where paydetail.asgn_id = r.rtd_trcid 
	and paydetail.asgn_type = 'TRC'
	and CHARINDEX(',' + paydetail.pyt_itemcode + ',', @ExcludePT) = 0


-- Remove any RTD records where a Leg withing the RTD does not have any pay.
if @paidflag = 0
	delete from @rtddata
	from @rtddata r1
	where exists (select 1 from @rtddata r2 where r2.rtd_id = r1.rtd_id and lgh_pay = 0)
else if @paidflag = 1
	delete from @rtddata
	from @rtddata r1
	where not exists (select 1 from @rtddata r2 where r2.rtd_id = r1.rtd_id and lgh_pay = 0)
	

-- Compute the Minimum Pay required for the Leg.
Update @rtddata
set lgh_min_pay_amt = (lgh_miles * @CPM)


-- Compute the amount by which the RTD is SHORT of the Minimum.
--select rtd_id,
--	lgh_pay, 
--	lgh_min_pay_amt,
--	(select sum(r2.lgh_min_pay_amt - r2.lgh_pay) from @rtddata r2 where r2.rtd_id = r1.rtd_id) rtd_diff
--from @rtddata r1

update @rtddata
set rtd_diff = (select sum(r2.lgh_min_pay_amt - r2.lgh_pay) from @rtddata r2 where r2.rtd_id = r1.rtd_id)
from @rtddata r1

--update @rtddata
--set rtd_diff = (select sum(isNull(r2.lgh_min_pay_amt,0) - isnull(r2.lgh_pay,0)) from @rtddata r2 where r2.rtd_id = r1.rtd_id)
--from @rtddata r1


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
	ord_hdrnumber,
	mov_number,
	lgh_startcty_nmstct,
	lgh_endcty_nmstct,
	lgh_miles,
	lgh_pay,
	lgh_min_pay_amt,
	rtd_diff,
	0 release,
	isNull(rtd_pay_ineligible,'N') rtd_pay_ineligible
from @rtddata
--where lgh_pay > 0 

GO
GRANT EXECUTE ON  [dbo].[d_rtd_new_sp] TO [public]
GO
