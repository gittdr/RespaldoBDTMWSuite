SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_getcarriercommitmentbucketidfororder] (
	@ord_hdrnumber int,
	@car_id as varchar(8)
) as

declare @activedate datetime
declare @carrierlanecommitmentid int


-- Get and normalize the date
SELECT @activedate = stops.stp_arrivaldate
  FROM stops
 WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
       stops.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) 
                                   FROM stops
                                  WHERE stops.ord_hdrnumber = @ord_hdrnumber)

set @activedate = CAST(CAST(YEAR(@activedate) AS VARCHAR) + '-' + CAST(MONTH(@activedate) AS VARCHAR) + '-' + CAST(DAY(@activedate) AS VARCHAR) AS DATETIME)


-- Get the lanes
create table #lanes
   (
	LaneId		int,
	LaneName	varchar(50),
	Specificity	int
   )
insert into #lanes
select * from core_fncGetLanesForOrder( @ord_hdrnumber)
--insert into #lanes
--exec core_GetLanesForOrder @ord_hdrnumber
-- select * from #lanes -- display the results for debugging

-- Get the commitment for this carrier for the lane with the most specificity and a declared commitment
select
	clc.carrierlanecommitmentid
into #tempid
from core_carrierlanecommitment as clc
inner join #lanes as l
on clc.laneid=l.laneid
where
	clc.car_id=@car_id
	and clc.effectivedate <= @activedate
	and clc.expiresdate >= @activedate
 --select * from #tempid-- display the results for debugging

-- Create the bucket, if it doesn't exist
set @carrierlanecommitmentid=0

set @carrierlanecommitmentid = IsNull((select top 1 carrierlanecommitmentid 
										from #tempid 
										where carrierlanecommitmentid > @carrierlanecommitmentid 
										order by carrierlanecommitmentid),0)
while @carrierlanecommitmentid > 0
begin
	if (not exists
		(
		select ccb_id
		from core_carriercommitmentbuckets
		where
			carrierlanecommitmentid=@carrierlanecommitmentid
			and ccb_date=@activedate
		)
	)
	exec core_CreateCarrierCommitmentTrackingBuckets @carrierlanecommitmentid, @activedate

	set @carrierlanecommitmentid = IsNull((select top 1 carrierlanecommitmentid 
										from #tempid 
										where carrierlanecommitmentid > @carrierlanecommitmentid 
										order by carrierlanecommitmentid),0)
end

-- Get the bucket
select
	ccb.ccb_id
from core_carriercommitmentbuckets as ccb (NOLOCK)
where
	carrierlanecommitmentid in (select carrierlanecommitmentid from #tempid)
	and ccb_date=@activedate

-- Clean up our temporary tables
drop table #lanes
drop table #tempid

GO
GRANT EXECUTE ON  [dbo].[core_getcarriercommitmentbucketidfororder] TO [public]
GO
