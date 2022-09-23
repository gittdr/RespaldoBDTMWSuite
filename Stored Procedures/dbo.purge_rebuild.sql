SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[purge_rebuild] 
 @from_date datetime,
 @thru_date datetime
AS
create table #temp (lgh_number int)

insert into #temp select lgh_number
 from legheader
 where lgh_enddate >= @from_date
   and lgh_enddate <= @thru_date

truncate table purgework

insert into purgework
 select distinct mov_number
  from stops, #temp
  where stops.lgh_number = #temp.lgh_number
GO
GRANT EXECUTE ON  [dbo].[purge_rebuild] TO [public]
GO
