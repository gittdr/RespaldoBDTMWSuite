SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InvServiceGetAllReadingAlert] 
 @cmp_revtype1 varchar(6),
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
AS

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

declare @imax int
declare @i int 
declare @currentCompany varchar(8)
select @imax = max(id) from #companies
SET @i = 1 

create table #results (
 inv_id int, 
 CompanyID varchar(8), 
 ForecastBucket int, 
 InventoryDate datetime, 
 LastReadingDate datetime, 
 Sequence int, 
 Reading int, 
 [Source] varchar(6) ,
 HoursFromLastReading decimal(18,4),
 AverageHoursBetweenReadings decimal(18,4),
 HoursLate decimal(18,4)
)

while (@i <= @imax)
begin
 select @currentCompany = cmp_id from #companies where ID = @i
 insert #results
 exec InvServiceGetCompanyReadingAlert @currentCompany
 select @i = @i + 1 
end

select * 
from #results 
order by HoursLate desc
     
drop table #companies
drop table #results
GO
GRANT EXECUTE ON  [dbo].[InvServiceGetAllReadingAlert] TO [public]
GO
