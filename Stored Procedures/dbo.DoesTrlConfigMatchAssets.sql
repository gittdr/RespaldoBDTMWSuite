SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[DoesTrlConfigMatchAssets] (@config varchar(6), @trcID varchar(15),@trlID varchar(15),@pupID varchar(15),
  @@configaxles int OUTPUT, @@assetaxles int OUTPUT)

AS
/*   
   Used to match axle count from the equipmentconfigheader table for the equipment
   configuration of the assets passed to that for the trailer configraion on th order.
   The trc_loading_class of the tractor  plus the trl_loading_class of the trailer and pup
   are matched to the equipmentconfigheader table to get the axle count Values are returned 
   for messages on no match

  Call is
  exec  DoesTrlConfigMatchAssets '8AXA','T1','TAZ','1',@Caxles  OUTPUT,@Aaxles OUTPUT
  WHere first argument is the trailer config on the order(s) and the next three arguments 
  are the tractor number, the trailer id and the pup trailer ID

  

 DPETE 9/23/04 PTS23776
 
*/


Select  @@assetaxles =  ech_axles
From equipmentconfigheader
Where ech_trc_loading_class = (Select IsNull(trc_loading_class,'UNK') From tractorprofile Where 
 trc_number = IsNull(@trcID,'UNKNOWN')) 
-- strange code to make sure an asset that was not assigned a loading class will not match to UNK in the equipmentconfigheader
 and ech_lead_trl_loading_class =  IsNull((Select IsNull(trl_loading_class,'UNK') From trailerprofile Where 
   trl_ID = @trlID and (trl_loading_class  <> 'UNK' or @TrlID = 'UNKNOWN')),'^^^') 
 and ech_pup_trl_loading_class = IsNull((Select IsNull(trl_loading_class,'UNK') From trailerprofile Where 
   trl_ID = @PUPID and (trl_loading_class  <> 'UNK' or @PUPID = 'UNKNOWN')),'^^^') 

Select  @@configaxles  = Max(ech_axles) 
From equipmentconfigheader
Where ech_Train_config = @config




Select @@assetaxles =  IsNull(@@assetaxles,0), @@configaxles= IsNull( @@configaxles,0)


GO
GRANT EXECUTE ON  [dbo].[DoesTrlConfigMatchAssets] TO [public]
GO
