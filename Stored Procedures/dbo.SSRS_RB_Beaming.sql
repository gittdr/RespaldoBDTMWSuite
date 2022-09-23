SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[SSRS_RB_Beaming]
(
	@Startdate datetime,
	@Enddate datetime,
	@AssetType varchar (20) --- DRV,TRC,TRL
	
)
as

/*
SSRS_RB_Beaming
Key Parameters
	@Startdate datetime,
	@Enddate datetime,
	@AssetType varchar (20), --- DRV,TRC,TRL



*/
set transaction isolation level read uncommitted -- Prevents locking
SET NOCOUNT ON

--select @assettype as Debug into jerry1

create table #Assignment
(
asgn_date datetime null,
asgn_enddate datetime null,
asgn_type varchar(6) null,
asgn_id varchar(13) null,
asgn_number int,
lgh_number int null,
lgh_startcity int null,
StartCityName varchar(30) null,
lgh_endcity int null,
EndCityName varchar(30) Null,
PriorAsgnNumber int  null,
PriorLegNumber int null,
PriorAsgnEndDate datetime null,
LegPriorEndCity int null,
LegPriorEndCityName varchar(30) null,
mov_number int null
)

insert into #Assignment
select 
asn.asgn_date,
asn.asgn_enddate,
asn.asgn_type,
asn.asgn_id,
asn.asgn_number,
asn.lgh_number,
leg.lgh_startcity,
stc.cty_nmstct,
leg.lgh_endcity,
enc.cty_nmstct,
	ISNULL((
	Select top 1 c.asgn_number from assetassignment c 
	where 
	c.asgn_type=asn.asgn_type 
	and 
	c.asgn_id=asn.asgn_id
	and
	asgn_type<>'CAR'
	and 
	asgn_status = 'CMP'
	and 
	c.asgn_enddate<asn.asgn_enddate
	and 
	c.asgn_number<>asn.asgn_number
	and
	c.lgh_number<>asn.lgh_number
	order by c.asgn_enddate desc
	),0),
null,
null,
null,
null,
asn.mov_number
from assetassignment asn
left outer join legheader leg on asn.lgh_number = leg.lgh_number
left outer join city stc on leg.lgh_startcity=stc.cty_code
left outer join city enc on leg.lgh_endcity=enc.cty_code
where 
asn.asgn_date>= @Startdate and asn.asgn_date <= @Enddate
and
asgn_type<>'CAR'
and 
asgn_status = 'CMP'
and
CHARINDEX(asn.asgn_type, @AssetType) > 0

order by asn.asgn_type,asn.asgn_id,asn.asgn_enddate

update #Assignment
	set PriorAsgnEndDate=asn.asgn_enddate,
	PriorLegNumber=asn.lgh_number,
	LegPriorEndCity=leg.lgh_endcity,
	LegPriorEndCityName=enc.cty_nmstct
	from 
	assetassignment asn join 
	legheader leg  on asn.lgh_number=leg.lgh_number
	join city enc on leg.lgh_endcity=enc.cty_code
	where asn.asgn_number=#Assignment.PriorAsgnNumber
	and #Assignment.PriorAsgnNumber<>0
	
select 
asgn_date as [Assignment Start Date],
asgn_enddate as [Assignment End Date],
asgn_type as [Resource Type],
asgn_id as [Resource ID],
lgh_number as [Trip Segment Number],
ISNULL((select top 1 ord_number from orderheader o join legheader l on o.ord_hdrnumber =l.ord_hdrnumber where l.lgh_number = #Assignment.lgh_number),'') as [Order Number],
StartCityName,
LegPriorEndCityName [Previous End City Name],
PriorLegNumber,
ISNULL((select top 1 ord_number from orderheader o join legheader l on o.ord_hdrnumber =l.ord_hdrnumber where l.lgh_number = #Assignment.PriorLegNumber),'') as [Prior Order Number],
PriorAsgnEndDate
from #Assignment
where lgh_startcity<>LegPriorEndCity


GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_Beaming] TO [public]
GO
