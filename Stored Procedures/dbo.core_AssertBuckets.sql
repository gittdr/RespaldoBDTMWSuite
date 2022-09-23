SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[core_AssertBuckets] (
	@carrierlanecommitmentid int,
	@TheDate datetime
) as

if not exists (select 1 from core_carriercommitmentbuckets (nolock)
						where carrierlanecommitmentid = @carrierlanecommitmentid
						and ccb_date = @TheDate)
	exec core_CreateCarrierCommitmentTrackingBuckets @carrierlanecommitmentid, @TheDate 


if not exists (select 1 from core_carriercapacitybuckets (nolock)
						where carrierlanecommitmentid = @carrierlanecommitmentid
						and ccpb_date = @TheDate)
	exec core_CreateCarrierCapacityTrackingBuckets @carrierlanecommitmentid, @TheDate 

GO
GRANT EXECUTE ON  [dbo].[core_AssertBuckets] TO [public]
GO
