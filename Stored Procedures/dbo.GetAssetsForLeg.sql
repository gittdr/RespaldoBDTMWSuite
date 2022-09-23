SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetAssetsForLeg] (@lgh int,@@trcID varchar(8) OUTPUT,@@trlID varchar(13) OUTPUT,
   @@pupID varchar(13) OUTPUT,@@carID varchar(8) OUTPUT)

AS
/*   DPETE 9/14/04

 Returns the assets given a lgh_number
 

  Call is
  exec  GetAssetsForLeg 12345,@@TrcID OUTPUT,@@TrlID OUTPUT,@@PupID OUTPUT,@@CarID OUTPUT
  Where first argument is the lgh_number
  The last two are the mile table to use for loaded miles and the mile table to use for empty miles

PTS40260 4/19/08 recode Pauls DPETE

*/

Select @@trcid = evt_tractor,@@trlid = evt_trailer1, @@pupid = evt_trailer2,@@CarID = evt_carrier
From stops,event
Where stops.lgh_number = @lgh
and stp_mfh_sequence = (Select Min(Stp_mfh_sequence) from stops s2 Where s2.lgh_number = @lgh)
and event.stp_number = stops.stp_number
and evt_sequence = 1

Select @@trcid = IsNull(@@trcid,'UNKNOWN')
,@@trlid = IsNull(@@TrlID,'UNKNOWN')
, @@PupID = IsNull(@@PupID,'UNKNOWN')
,@@CarID = IsNull(@@CarID,'UNKNOWN')



GO
GRANT EXECUTE ON  [dbo].[GetAssetsForLeg] TO [public]
GO
