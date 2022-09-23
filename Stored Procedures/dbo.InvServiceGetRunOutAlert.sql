SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[InvServiceGetRunOutAlert] @cmp_revtype1 varchar(6),
  @cmp_revtype2 varchar(6),
  @cmp_revtype3 varchar(6),
  @cmp_region1 varchar(6),
  @cmp_region2 varchar(6),
  @cmp_region3 varchar(6),
  @cmp_othertype1 varchar(6),
  @cmp_othertype2 varchar(6),
  @cmp_defaultbillto varchar(8),
  @cmp_InvSrvMode varchar(6),
  @cmp_bookingterminal varchar(8),
  @cmp_inv_controlling_cmp_id varchar(8)
as

create table #companies (
 ID int IDENTITY(1,1) NOT NULL,
 cmp_id varchar(8),
)

insert into #companies
exec GetCompaniesByTankRestrictions 
 @cmp_revtype1,
 @cmp_revtype2,
 @cmp_revtype3,
 @cmp_region1,
 @cmp_region2,
 @cmp_region3,
 @cmp_othertype1,
 @cmp_othertype2,
 @cmp_defaultbillto,
 @cmp_InvSrvMode,
 @cmp_bookingterminal,
 @cmp_inv_controlling_cmp_id

Create table #readings
(ID int not null,
UpdatedDate datetime not null,
UpdatedBy varchar(500) not null,
cmp_id varchar(8),
forecast_bucket int, 
cmd_code varchar(8),
SafeFill int,
[ShutDown] int,
PriorReadingDate datetime,
PriorReading int,
LastReadingDate datetime,
LastReading int,
LastReadingEstSales int,
LastReadingDeliveries int,
NowReadingDate datetime,
NowReading int,
NowReadingEstSales int,
NowDeliveries int,
NowDeliveriesExcluded int,
Reading12HoursDate datetime,
Reading12Hours int,
Reading12HoursEstSales int,
Deliveries12Hours int,
Deliveries12HoursExcluded int,
Questionable char(1) null,
Status varchar(100) null,
RunOutDate datetime null)



declare @imax int
declare @i int 
declare @currentCompany varchar(8)
select @imax = max(id) from #companies
SET @i = 1 

while (@i <= @imax)
begin
 select @currentCompany = cmp_id from #companies where ID = @i
  
 Insert #readings
 exec InvServiceGetEstimatedReadingCalculation @currentCompany
  
 select @i = @i + 1 
end
     
select cmp_id, forecast_bucket, cmd_code, SafeFill, [ShutDown], PriorReadingDate, PriorReading, 
  LastReadingDate, LastReading, (PriorReading + LastReadingDeliveries - LastReadingEstSales) as ExpectedReading,
  LastReadingEstSales, LastReadingDeliveries, 
  NowReading,
  NowReadingEstSales,
  NowDeliveries,
  NowDeliveriesExcluded,
  RunOutDate, Status
  from #readings
  where runoutdate < dateadd(hh, 12, getdate())
order by runoutdate

drop table #readings
drop table #companies
GO
GRANT EXECUTE ON  [dbo].[InvServiceGetRunOutAlert] TO [public]
GO
