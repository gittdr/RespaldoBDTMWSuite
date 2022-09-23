SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PurgeManifestLTL]
 @LegNumber int
AS
BEGIN
 
begin transaction

delete from legheader where lgh_number = @LegNumber

delete from legheader_brokered where lgh_number = @LegNumber

delete from legheaderbrokered_acc where lgh_number = @LegNumber

delete from legheader_brokered_status where lgh_number = @LegNumber

delete from assetassignment where lgh_number = @LegNumber

delete from paydetail where lgh_number = @LegNumber

delete from manifestheader where stp_number_start in (select stp_number from stops where lgh_number = @LegNumber)

delete from ltl_reweigh where evt_number in (select evt_number from event where stp_number in (select stp_number from stops where lgh_number = @LegNumber)) 

delete from eventltlinfo where evt_number in (select evt_number from event where stp_number in (select stp_number from stops where lgh_number = @LegNumber)) 

delete from event where stp_number in (select stp_number from stops where lgh_number = @LegNumber)

delete from stops where lgh_number = @LegNumber

delete from TrailerSpottingDetail where lgh_number = @LegNumber

commit transaction

RETURN 0
END
GO
GRANT EXECUTE ON  [dbo].[PurgeManifestLTL] TO [public]
GO
