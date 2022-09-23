SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[d_pdhours_splits_sp] @split_leg int 
as

Declare @firstdayofyear		datetime,
	@dayhold	datetime,
	@weeknum	int,
	@weekstart	datetime,
	@yearstartdate	datetime,
	@maxdiff	int,
	@current_diff	int,
	@paysheduledetid int,
	@splitcheckcalllimit	int,
	@isserverondst	char(1),
	@driver1id	varchar(8),
	@driver2id	varchar(8),
	@driver1GMToffset	int,
	@driver2GMToffset	int,
	@driver1ApplyDST	char(1),
	@driver2ApplyDST	char(1),
	@servergmtdelta		int,
	@today	datetime

Create Table #pd_hours_raw (
	pdh_identity	int null,
	pyd_number int not null,
	pdh_weeknum int not null,
	pdh_date datetime null,
	pdh_year int null,
	pdh_type varchar(6) null,
	pdh_miles dec(9,2) null,
	lgh_number	int null,
	stp_number	int null,
	weekstart_date	datetime null,
	weekend_date	datetime null,
	tripstart_date	datetime null,
	tripend_date	datetime null,
	tripstart_ckc	int null,
	tripend_ckc	int null,
	stp_startdate	datetime null,
	stp_arrivaldate datetime null,
	start_checkcall_date	datetime null,
	end_checkcall_date	datetime null,
	ord_number varchar(12) null)

CREATE TABLE #pd_legdata (
	pyd_number INT NULL,
	pdh_weeknum INT NULL,
	lgh_number INT NULL, 
	stp_number INT NULL,
	stp_mfh_sequence INT NULL, 
	diff INT NULL,
	stp_departuredate DATETIME NULL, 
	stp_arrivaldate DATETIME NULL,
	lgh_startdate DATETIME NULL,
	lgh_enddate DATETIME NULL,
	weeknum INT NULL )

CREATE TABLE #ckc_temp (
	  ckc_date datetime null
	, ckc_number int null
	, ckc_asgntype varchar(6) null
	, ckc_asgnid varchar(8) null
	, ckc_latseconds int null
	, ckc_longseconds int null
	, ckc_comment varchar (254) null
	)

execute tmw_isserverindstmode_sp @servermode = @isserverondst OUTPUT, @servergmtoffset = @servergmtdelta OUTPUT

if @split_leg > 0
	select 	@yearstartdate = max(lgh_startdate), 
		@driver1id = max(lgh_driver1),
		@driver2id = max(lgh_driver2)
	from 	legheader where lgh_number = @split_leg

-- Go get driver's GMT offset and DST flag for city considered "home"
select @driver1GMToffset = cty1.cty_gmtdelta,
	@driver1applydst =  cty1.cty_dstapplies
from 	manpowerprofile mpp1, city cty1
where	mpp1.mpp_city = cty1.cty_code AND
	mpp1.mpp_id = @driver1id

select @driver2GMToffset = cty2.cty_gmtdelta,
	@driver2applydst = cty2.cty_dstapplies
from 	manpowerprofile mpp2, city cty2
where	mpp2.mpp_city = cty2.cty_code AND
	mpp2.mpp_id = @driver2id

if @split_leg > 0
	select @yearstartdate = max(lgh_startdate) from legheader where lgh_number = @split_leg

-- Get the First day of the current Year
--select @firstdayofyear = convert(datetime, '01/01/' + cast(DatePart(yyyy, @yearstartdate) as varchar(4)),101)
select @today = CAST(FLOOR(CAST(getdate() AS float)) AS datetime)
select @firstdayofyear = cast(floor(cast(dateadd(dy, -datepart(dy, @today)+1, @today) as float)) as datetime)



-- Get the first Sunday of the Year to use to start counting weeks.
select @dayhold = @firstdayofyear	
while DatePart(dw,@dayhold) <> 1
	Begin
		Select @dayhold = DateAdd(dd,1,@dayhold)
	End 
select @weekstart = @dayhold

/* Update the pdh_weeks column.  Jude is not populating from Settlements	*/
update pdhours
set pdh_weeknum = DateDiff(wk, @weekstart, pdh_date),
	pdh_year = DatePart(yyyy,pdh_date)
from paydetail p
where p.pyd_number = pdhours.pyd_number
	and pdhours.pdh_weeknum = 0

/*	Insert the PDHOURS records for the trip segment that also span a weekend 
*/
insert into #pd_hours_raw (pyd_number,pdh_weeknum,lgh_number,stp_number,pdh_date, pdh_type, pdh_identity,pdh_year,
	tripstart_date, tripend_date,stp_startdate, stp_arrivaldate, ord_number)
Select p.pyd_number,
	pd.pdh_weeknum,
	leg.lgh_number,
	pd.pdh_stp_number,
	pd.pdh_date,
	pd.pdh_type,
	pd.pdh_identity,
	pd.pdh_year,
	s2.stp_departuredate,
	leg.lgh_enddate,
	s2.stp_departuredate,
	s.stp_arrivaldate,
	ord_number
from pdhours pd 
	Inner JOIN paydetail p ON pd.pyd_number = p.pyd_number 
	Inner Join paytype ON p.pyt_itemcode = paytype.pyt_itemcode and paytype.pyt_basisunit = 'DIS' 
	INNER JOIN legheader leg ON p.lgh_number = leg.lgh_number 
	Inner Join stops s ON leg.lgh_number = s.lgh_number and s.stp_number = pd.pdh_stp_number 
	Inner Join stops s2 ON leg.lgh_number = s2.lgh_number and s2.stp_mfh_sequence = (s.stp_mfh_sequence - 1)
	Left Outer Join orderheader ON p.ord_hdrnumber = orderheader.ord_hdrnumber
where datediff(wk, s2.stp_departuredate, s.stp_arrivaldate) > 0
	and p.lgh_number = @split_leg
	and pd.pdh_type = 'REG'
	and not exists (select * from pdhours pd2 
			where pd2.pyd_number = pd.pyd_number
			and pd2.pdh_weeknum = (pd.pdh_weeknum - datediff(wk, s2.stp_departuredate, s.stp_arrivaldate)))
	
--Insert the PDHOURS records for the trip segment that also span a Holiday
insert into #pd_hours_raw (pyd_number,pdh_weeknum,lgh_number,stp_number,pdh_date, pdh_type, pdh_identity,pdh_year,
	tripstart_date, tripend_date,stp_startdate, stp_arrivaldate, ord_number)
Select p.pyd_number,
	pd.pdh_weeknum,
	leg.lgh_number,
	pd.pdh_stp_number,
	pd.pdh_date,
	pd.pdh_type,
	pd.pdh_identity,
	pd.pdh_year,
	s2.stp_departuredate,
	s.stp_arrivaldate,
	s2.stp_departuredate,
	s.stp_arrivaldate,
	ord_number
from pdhours pd 
	Inner JOIN paydetail p ON pd.pyd_number = p.pyd_number 
	Inner Join paytype ON p.pyt_itemcode = paytype.pyt_itemcode and paytype.pyt_basisunit = 'DIS' 
	INNER JOIN legheader leg ON p.lgh_number = leg.lgh_number 
	Inner Join stops s ON leg.lgh_number = s.lgh_number and s.stp_number = pd.pdh_stp_number 
	Inner Join stops s2 ON leg.lgh_number = s2.lgh_number and s2.stp_mfh_sequence = (s.stp_mfh_sequence - 1) 
	inner join Holidays h ON h.holiday between cast(convert(char(8),s2.stp_departuredate,112) as datetime) and s.stp_arrivaldate
	Left Outer Join orderheader ON p.ord_hdrnumber = orderheader.ord_hdrnumber	
where p.lgh_number = @split_leg
	and not exists (select * from #pd_hours_raw pd3 
			where pd3.pyd_number = pd.pyd_number
			and pd3.pdh_weeknum = pd.pdh_weeknum)
	and not exists (select * from pdhours pd4 
			where pd4.pyd_number = pd.pyd_number
			and pd4.pdh_weeknum = pd.pdh_weeknum 
			and pd4.pdh_type = 'HOL')

/* Create a table holding all the leg/stop information necessary to determine 
	how many weeks each stops of the Leg spans

*/
INSERT Into #pd_legdata
Select 	p.pyd_number,
	pdhours.pdh_weeknum,
	s.lgh_number, 
	s.stp_number,
	s.stp_mfh_sequence, 
	0,
	s2.stp_departuredate, 
	s.stp_arrivaldate,
	lgh_startdate,
	lgh_enddate,
	DateDiff(wk, @weekstart, s.stp_arrivaldate)
from  #pd_hours_raw pdhours inner join paydetail p
	ON pdhours.pyd_number = p.pyd_number inner join Legheader leg
	ON p.lgh_number = leg.lgh_number inner join stops s
	on leg.lgh_number = @split_leg
	and leg.lgh_number = s.lgh_number 
	and pdhours.stp_number = s.stp_number inner join stops s2
	ON s.lgh_number = s2.lgh_number 
	and s2.stp_mfh_sequence = (s.stp_mfh_sequence -1)
Order by p.pyd_number, s.lgh_number, s.stp_mfh_sequence

-- update the field indicating the number of weeks the stop spans
update #pd_legdata
set diff = DateDiff(wk, stp_departuredate, stp_arrivaldate)

select @maxdiff = max(diff) from #pd_legdata

Select @current_diff = isNull(@current_diff,0) + 1

while @current_diff <= @maxdiff
Begin	
		
	--Fill in missing Weeks records
	--	PTS 24895 - Removed the Time from the pdh_date field.
	insert into #pd_hours_raw (pyd_number,pdh_weeknum,lgh_number, stp_number,pdh_date, pdh_type, pdh_identity,pdh_year,
		weekstart_date, weekend_date, tripstart_date, tripend_date,stp_startdate, stp_arrivaldate, ord_number)
	select #pd_legdata.pyd_number,
		(pdhours.pdh_weeknum - @current_diff) weeknum,
		p.lgh_number,
		s.stp_number,
		cast(convert(char(8),#pd_legdata.stp_departuredate,112) as datetime),
		'REG',
		0,
		Case 
			when s.stp_arrivaldate < @weekstart then DatePart(yyyy,s.stp_arrivaldate) -1 
			else DatePart(yyyy,s.stp_arrivaldate)
		End,
		DateAdd(wk,(pdhours.pdh_weeknum - @current_diff), @weekstart),
		DateAdd(mi, 10079, DateAdd(wk,(pdhours.pdh_weeknum - @current_diff), @weekstart)),
		#pd_legdata.stp_departuredate,
		DateAdd(mi, 10079, DateAdd(wk,(pdhours.pdh_weeknum - @current_diff), @weekstart)),
		#pd_legdata.stp_departuredate,
		#pd_legdata.stp_arrivaldate,
		ord_number
	from #pd_legdata 
	inner join paydetail p on #pd_legdata.pyd_number = p.pyd_number and #pd_legdata.diff > 0 
	inner join pdhours on #pd_legdata.pyd_number = pdhours.pyd_number 
	inner join stops s on #pd_legdata.stp_number = s.stp_number 
	inner join paytype pt on p.pyt_itemcode = pt.pyt_itemcode and pt.pyt_basisunit = 'DIS'
	Left Outer Join orderheader ON p.ord_hdrnumber = orderheader.ord_hdrnumber
	where #pd_legdata.diff >= @current_diff
		and not exists (select * 
			from #pd_hours_raw 
			where #pd_hours_raw.pyd_number = #pd_legdata.pyd_number
				and #pd_hours_raw.pdh_weeknum = ((pdhours.pdh_weeknum - @current_diff)))

	-- Increment the counter
	Select @current_diff = @current_diff + 1
End

-- Update the starting date of the week.
update #pd_hours_raw
set weekstart_date = DateAdd(wk, pdh_weeknum, @weekstart)

-- Update the Ending date of the week by adding 10079 minutes (10080 minutes in a week)
update #pd_hours_raw
set weekend_date = DateAdd(mi, 10079, weekstart_date)


update #pd_hours_raw
--set tripstart_date = weekstart_date
set tripstart_date = weekstart_date, tripend_date = stp_arrivaldate
where tripstart_date < weekstart_date

update #pd_hours_raw
set tripend_date = weekend_date
where tripend_date  > weekend_date

-- update pdh_date where it's a holiday and the trip started before the holiday 25504
UPDATE #pd_hours_raw
SET	pdh_date = dateadd(d, -1, pdh_date)
FROM 	holidays, #pd_legdata
WHERE pdh_date = holidays.holiday
AND	#pd_legdata.pyd_number = #pd_hours_raw.pyd_number
AND	cast(convert(char(8), #pd_legdata.stp_departuredate,112) as datetime) < holiday 

-- update pdh_date where it's a holiday and the trip ended after the holiday 25504
UPDATE #pd_hours_raw
SET	pdh_date = dateadd(d, 1, pdh_date)
FROM 	holidays, #pd_legdata
WHERE pdh_date = holidays.holiday
AND	#pd_legdata.pyd_number = #pd_hours_raw.pyd_number
AND	holiday < cast(convert(char(8), #pd_legdata.stp_arrivaldate,112) as datetime) 

/* For ANY paydetail for the pay period/trip segment, look for dates that include
	a Holiday and create a Holday record if necessary				*/
Insert into #pd_hours_raw (pyd_number, pdh_weeknum, pdh_date,pdh_type, tripstart_date, 
	tripend_date, lgh_number,pdh_identity, pdh_year,stp_startdate, stp_arrivaldate,
	weekstart_date, weekend_date)
Select pd.pyd_number,
	DateDiff(wk,@weekstart, holiday) weeknum,
	holiday,
	'HOL',
	Case when leg.stp_departuredate between holiday and dateadd(mi,1439,holiday) then leg.stp_departuredate
		else holiday
	End,
	Case when leg.stp_arrivaldate between holiday and dateadd(mi,1439,holiday) then leg.stp_arrivaldate
		else dateadd(mi,1439,holiday)
	end,
	leg.lgh_number,
	0,
	DatePart(yyyy,holiday),
	leg.stp_departuredate,
	leg.stp_arrivaldate,
	holiday,
	dateadd(mi,1439,holiday)
from pdhours pd,
	paydetail,
	#pd_legdata leg,
	holidays	
where pd.pyd_number = paydetail.pyd_number
	and paydetail.lgh_number = leg.lgh_number
	and pd.pyd_number = leg.pyd_number
	and leg.lgh_number = @split_leg
	and holiday between cast(convert(char(8),leg.stp_departuredate,112) as datetime) and leg.stp_arrivaldate 
	and pd.pdh_type = 'REG'
	and not exists (select * from pdhours pd2 
			where pd.pyd_number = pd2.pyd_number
				and pd.pdh_date = pd2.pdh_date
				and pd.pdh_type = 'HOL')

-- Get the max number of minutes to allow for when searching for Checkcalls. Applies
-- to checkcalls on either 'side' of the search date.
select @splitcheckcalllimit = isNull(gi_integer1,15)
from generalinfo
where gi_name = 'PDHoursSplitCheckCallTime'

-- PTS 26892 - DJM - Create a Temp table to hold Checkcalls for the Driver
INSERT into #ckc_temp
select ckc_date, ckc_number, ckc_asgntype, ckc_asgnid, ckc_latseconds, ckc_longseconds, ckc_comment
from checkcall ck
where 	ck.ckc_asgntype = 'DRV'
	and ck.ckc_asgnid = @driver1id
	AND CK.CKC_DATE >= DateAdd(hh,-12,(SELECT MIN(PDH_DATE)from #pd_hours_raw))


/* Check for DST Adjustments.  If both the Server and the Driver Resisidence have the same value
	nothing needs to be done.								*/
if @isserverondst= 'Y' and @driver1applydst <> 'Y'
		select @driver1GMToffset = abs(@driver1GMToffset) + 1


-- PTS 26892 - DJM - Correct the datetime of the Checkcall based on the Driver home
update #ckc_temp
set ckc_date = dateadd(hh,-(abs(@driver1GMToffset) - abs(@servergmtdelta)),ckc_date)

-- select new.ckc_date, old.ckc_date, -(abs(@driver1GMToffset) - abs(@servergmtdelta)) offset, @driver1GMToffset, @servergmtdelta, @isserverondst
-- from #ckc_temp new
-- 	inner join checkcall old on new.ckc_number = old.ckc_number



-- Get the checkcall information for the tripstart and tripend dates of the PDHOURS records.
update #pd_hours_raw
set tripstart_ckc = ck1.ckc_number,
	start_checkcall_date = ck1.ckc_date
from #ckc_temp ck1,
	paydetail p,
	(select pd.pyd_number,pdh_type,ckc_asgntype,ckc_asgnid, tripstart_date, pdh_weeknum, Min(ABS(DateDiff(mi,tripstart_date, ckc_date))) diff
	from #ckc_temp ck, #pd_hours_raw pd, paydetail p
	where pd.pyd_number = p.pyd_number
		and p.asgn_type = ck.ckc_asgntype
		and p.asgn_id = ck.ckc_asgnid
	Group By pd.pyd_number,pdh_type,ckc_asgntype,ckc_asgnid,tripstart_date,pdh_weeknum
	Having Min(ABS(DateDiff(mi,tripstart_date, ckc_date))) <= @splitcheckcalllimit) chk_min
where #pd_hours_raw.pyd_number = chk_min.pyd_number
	and #pd_hours_raw.pyd_number = p.pyd_number
	and p.asgn_type = chk_min.ckc_asgntype
	and p.asgn_id = chk_min.ckc_asgnid
	and #pd_hours_raw.pdh_type = chk_min.pdh_type
	and #pd_hours_raw.pdh_weeknum = chk_min.pdh_weeknum
	and ck1.ckc_asgntype = chk_min.ckc_asgntype
	and ck1.ckc_asgnid = chk_min.ckc_asgnid
	and ABS(datediff(mi,#pd_hours_raw.tripstart_date, ck1.ckc_date)) = chk_min.diff

-- Get the checkcall information for the tripstart and tripend dates of the PDHOURS records.
update #pd_hours_raw
set tripend_ckc = ck1.ckc_number,
	end_checkcall_date = ck1.ckc_date
from #ckc_temp ck1,
	paydetail p,
	(select pd.pyd_number,pdh_type,ckc_asgntype,ckc_asgnid, tripstart_date, pdh_weeknum, Min(ABS(DateDiff(mi,tripend_date, ckc_date))) diff
	from #ckc_temp ck, #pd_hours_raw pd, paydetail p
	where pd.pyd_number = p.pyd_number
		and p.asgn_type = ck.ckc_asgntype
		and p.asgn_id = ck.ckc_asgnid
	Group By pd.pyd_number,pdh_type,ckc_asgntype,ckc_asgnid,tripstart_date,pdh_weeknum
	Having Min(ABS(DateDiff(mi,tripend_date, ckc_date))) <= @splitcheckcalllimit) chk_min
where #pd_hours_raw.pyd_number = chk_min.pyd_number
	and #pd_hours_raw.pyd_number = p.pyd_number
	and p.asgn_type = chk_min.ckc_asgntype
	and p.asgn_id = chk_min.ckc_asgnid
	and #pd_hours_raw.pdh_type = chk_min.pdh_type
	and #pd_hours_raw.pdh_weeknum = chk_min.pdh_weeknum
	and ck1.ckc_asgntype = chk_min.ckc_asgntype
	and ck1.ckc_asgnid = chk_min.ckc_asgnid
	and ABS(datediff(mi,#pd_hours_raw.tripend_date, ck1.ckc_date)) = chk_min.diff


-- Return the new PDHOURS records
select pr.pdh_identity,
	pr.pyd_number,
	(select pyd_description from paydetail pay where pay.pyd_number = pr.pyd_number) pyd_description ,
	pr.pdh_weeknum,
	pr.pdh_date,
	pr.pdh_year,
	pr.pdh_type,
	isNull(p.pdh_standardhours,0) pdh_standardhours,
	isnull(p.pdh_othours,0) pdh_othours,
	isNull(p.pdh_eihours,0) pdh_eihours,
	isNull(p.pdh_miles,0) pdh_miles,
	pr.lgh_number,
	pr.weekstart_date,
	pr.weekend_date,
	pr.tripstart_date,
	pr.tripend_date,
	pr.tripstart_ckc,
	pr.tripend_ckc,
	pr.stp_number,
	(select sum(isNull(pdh_miles,0)) from pdhours where pdhours.pyd_number = pr.pyd_number) original_miles,
	0.00 computed_miles,
	pr.stp_startdate,
	pr.stp_arrivaldate,
	start_checkcall_date,
	end_checkcall_date,
	start_loc.ckc_latseconds begin_latseconds,
	start_loc.ckc_longseconds begin_longseconds,
	start_loc.ckc_comment begin_comment,
	end_loc.ckc_latseconds end_latseconds,
	end_loc.ckc_longseconds end_longseconds,
	end_loc.ckc_comment end_comment,
	(select sum(isNull(pdh_standardhours,0)) from pdhours where pdhours.pyd_number = pr.pyd_number) orig_pdh_standardhours,
	(select sum(isNull(pdh_othours,0)) from pdhours where pdhours.pyd_number = pr.pyd_number) orig_pdh_othours,
	(select sum(isNull(pdh_eihours,0)) from pdhours where pdhours.pyd_number = pr.pyd_number) orig_pdh_eihours,
	ord_number
    from #pd_hours_raw pr
    left outer join pdhours p on  pr.pdh_identity = p.pdh_identity
    left outer join #ckc_temp start_loc on pr.tripstart_ckc = start_loc.ckc_number
    left outer join #ckc_temp end_loc on pr.tripend_ckc = end_loc.ckc_number
    Order by pr.pyd_number, pr.lgh_number, pr.pdh_weeknum
/*
from #pd_hours_raw pr,
	pdhours p,
	#ckc_temp start_loc,
	#ckc_temp end_loc
where pr.pdh_identity *= p.pdh_identity
	and pr.tripstart_ckc *= start_loc.ckc_number
	and pr.tripend_ckc *= end_loc.ckc_number
Order by pr.pyd_number, pr.lgh_number, pr.pdh_weeknum
*/

GO
GRANT EXECUTE ON  [dbo].[d_pdhours_splits_sp] TO [public]
GO
