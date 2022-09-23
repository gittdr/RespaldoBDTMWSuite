SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetAxleCountForAssets] (@trcID varchar(15),@trlID varchar(15),@pupID varchar(15),@@axles int OUTPUT)

AS
/*   
   Used to get the axle count from the equipmentconfigheader table for the equipment
   configuration of the assets passed.  The trc_loading_class of the tractor  plus the trl_loading_class of the trailer and pup
   are matched to the equipmentconfigheader table to get the axle count

  Call is
  exec  GetAxleCountForAssets 'T1','TAZ','1',@axles OUTPUT
  WHere first three arguments are the tractor number, the trailer id and the pup trailer ID

 DPETE 9/23/04 PTS23776
 
*/


Select  @@axles = ech_axles
From equipmentconfigheader
Where ech_trc_loading_class = (Select IsNull(trc_loading_class,'UNK') From tractorprofile Where 
 trc_number = IsNull(@trcID,'UNKNOWN')) 
-- strange code to make sure an asset that was not assigned a loading class will not match to UNK in the equipmentconfigheader
 and ech_lead_trl_loading_class =  IsNull((Select IsNull(trl_loading_class,'UNK') From trailerprofile Where 
   trl_ID = @trlID and (trl_loading_class  <> 'UNK' or @TrlID = 'UNKNOWN')),'^^^') 
 and ech_pup_trl_loading_class = IsNull((Select IsNull(trl_loading_class,'UNK') From trailerprofile Where 
   trl_ID = @PUPID and (trl_loading_class  <> 'UNK' or @PUPID = 'UNKNOWN')),'^^^') 


Select @@axles =  IsNull(@@axles,0)


GO
GRANT EXECUTE ON  [dbo].[GetAxleCountForAssets] TO [public]
GO
