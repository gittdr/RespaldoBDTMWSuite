SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[ida_GetAvailablePower] AS

declare @SerializedValue varchar(2000)
declare @ExcludeTractors bit
select @SerializedValue = SerializedValue from core_setting 
where settingsclasstypename = 'TMWSystems.IDA.ExcludeCarrierSettings'
and PropertyName = 'ExcludeTractors'

if @SerializedValue like '%<m_value>true</m_value>%'
	select @ExcludeTractors = 1
else
	select @ExcludeTractors = 0

select
	-- REVIEW: ensure we only select the needed columns
	'TRC' PowerType,
	tp.trc_number PowerId,
--	tp.trc_number,
--	null CarrerId,

	-- Last planned leg Info
	-- lgh.lgh_tractor,
	lgh.lgh_outstatus sLegStatus,
	lgh.lgh_startdate dtmLegStart,
	lgh.lgh_enddate dtmLegEnd,
	lgh.lgh_driver1 idDriver1,
	lgh.lgh_driver2 idDriver2,

	-- Availability Info:
	-- End of last planned/actual trip
	ca.cty_nmstct nmstctLastPlannedEnd,
	ca.cty_latitude latLastPlannedEnd,
	ca.cty_longitude lonLastPlannedEnd,
	lgh.lgh_enddate dtmLastPlannedEnd,
	-- Tractor avail info
	cb.cty_nmstct nmstctAvailable,
	cb.cty_latitude latAvailable,
	cb.cty_longitude lonAvailable,
	tp.trc_avl_date dtmAvailable,
	-- Latest location Info (use this if last planned trip is complete)
	tp.trc_gps_desc sDescriptionLatestGPS,
	tp.trc_gps_latitude latLatestGPS,
	tp.trc_gps_longitude lonLatestGPS,
	tp.trc_gps_date dtmLatestGPS
into #power
from
	tractorprofile tp
	-- Last planned/actual trip
	inner join
	(
		select *
		from legheader_active (NOLOCK)
		where
			lgh_instatus = 'UNP'
			-- and lgh_outstatus in ('PLN','DSP','STD','CMP') -- Not needed?
	) lgh
	on tp.trc_number=lgh.lgh_tractor
	-- Last planned/actual city
	left join city ca (NOLOCK)
	on lgh.lgh_endcity = ca.cty_code
	-- Available city
	left join city cb (NOLOCK)
	on tp.trc_avl_city = cb.cty_code
where
	tp.trc_number <> 'UNKNOWN'
	and tp.trc_status <> 'OUT'
	and @ExcludeTractors = 0
union
select
	'CAR' PowerType,
	car.car_id PowerId,
	-- Last planned leg Info
	null sLegStatus,
	null dtmLegStart,
	null dtmLegEnd,
	'UNKNOWN ' idDriver1,
	'UNKNOWN ' idDriver2,

	-- Availability Info:
	-- End of last planned/actual trip
	null nmstctLastPlannedEnd,
	null latLastPlannedEnd,
	null lonLastPlannedEnd,
	null dtmLastPlannedEnd,
	-- Tractor avail info
	null nmstctAvailable,
	null latAvailable,
	null lonAvailable,
	null dtmAvailable,
	-- Latest location Info (use this if last planned trip is complete)
	null sDescriptionLatestGPS,
	null latLatestGPS,
	null lonLatestGPS,
	null dtmLatestGPS

from carrier car (NOLOCK)
where car.car_id <> 'UNKNOWN'
order by PowerId


select * from #power

select distinct trc.* -- REVIEW: only select the needed columns
into #tractor
from tractorprofile trc (NOLOCK)
inner join #power pwr
on trc.trc_number=pwr.PowerId and pwr.PowerType='TRC'
order by trc.trc_number

select * from #tractor

select distinct mpp.* -- REVIEW: only select the needed columns
into #driver
from manpowerprofile mpp (NOLOCK)
inner join #power pwr
on mpp.mpp_id=pwr.idDriver1 or mpp.mpp_id=pwr.idDriver2
order by mpp.mpp_id

select * from #driver

select distinct
	car.*, -- REVIEW: only select the needed columns
	lf.code as CarrierRatingCode
into #carrier
from carrier car (NOLOCK)
inner join #power pwr
on car.car_id=pwr.PowerId and pwr.PowerType='CAR'
left join labelfile lf (NOLOCK)
on car.car_rating = lf.abbr and lf.labeldefinition = 'CarrierServiceRating'
order by car.car_id
select * from #carrier

select distinct
	tca.*, -- REVIEW: only select the needed columns
	lf.name
into #tractoraccessories
from tractoraccesories tca (NOLOCK)
inner join #tractor trc
on tca.tca_tractor=trc.trc_number and tca.tca_source = 'TRC'
inner join labelfile lf (NOLOCK)
on tca.tca_type=lf.abbr and lf.labeldefinition='TrcAcc'
union
select distinct
	tca.*, -- REVIEW: only select the needed columns
	lf.name
from tractoraccesories tca (NOLOCK)
inner join #carrier car
on tca.tca_tractor=car.car_id and tca.tca_source = 'CAR'
inner join labelfile lf (NOLOCK)
on tca.tca_type=lf.abbr and lf.labeldefinition='TrcAcc'
order by tca.tca_tractor
select * from #tractoraccessories

select distinct
	drq.*, -- REVIEW: only select the needed columns
	lf.name
into #driverqualification
from driverqualifications drq (NOLOCK)
inner join #driver drv
on drq.drq_id=drv.mpp_id and drq.drq_source = 'DRV'
inner join labelfile lf (NOLOCK)
on drq.drq_type=lf.abbr and lf.labeldefinition='DrvAcc'
union
select distinct
	drq.*, -- REVIEW: only select the needed columns
	lf.name
from driverqualifications drq (NOLOCK)
inner join #carrier car
on drq.drq_id=car.car_id and drq.drq_source = 'CAR'
inner join labelfile lf (NOLOCK)
on drq.drq_type=lf.abbr and lf.labeldefinition='DrvAcc'
order by drq.drq_id
select * from #driverqualification

select distinct
	ta.*, -- REVIEW: only select the needed columns
	lf.name
into #traileraccessory
from trlaccessories ta (NOLOCK)
inner join #carrier car
on ta.ta_trailer=car.car_id and ta.ta_source = 'CAR'
inner join labelfile lf (NOLOCK)
on ta.ta_type=lf.abbr and lf.labeldefinition='TrlAcc'
order by ta.ta_trailer
select * from #traileraccessory

select distinct
	caq.*, -- REVIEW: only select the needed columns
	lf.name
into #carrierqualification
from carrierqualifications caq (NOLOCK)
inner join #carrier car
on caq.caq_id=car.car_id
inner join labelfile lf (NOLOCK)
on caq.caq_type=lf.abbr and lf.labeldefinition='CarQual'
order by caq.caq_id
select * from #carrierqualification

select distinct ex.* -- REVIEW: only select the needed columns
into #expiration
from expiration ex (NOLOCK)
inner join #driver drv
on (ex.exp_idtype='DRV' and ex.exp_id=drv.mpp_id)
where (not ex.exp_completed = 'Y')
union
select distinct ex.*
from expiration ex (NOLOCK)
inner join #tractor trc
on (ex.exp_idtype='TRC' and ex.exp_id=trc.trc_number)
where (not ex.exp_completed = 'Y')
union
select distinct ex.*
from expiration ex (NOLOCK)
inner join #carrier car
on (ex.exp_idtype='CAR' and ex.exp_id=car.car_id)
where (not ex.exp_completed = 'Y')
select * from #expiration




GO
GRANT EXECUTE ON  [dbo].[ida_GetAvailablePower] TO [public]
GO
