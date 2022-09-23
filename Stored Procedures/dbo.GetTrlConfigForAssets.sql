SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetTrlConfigForAssets] (@trcID varchar(15),@trlID varchar(15),@pupID varchar(15),@@trlconfig varchar(6) OUTPUT)

AS
/*   
   NOTE: called by getmiletypeforassets proc

  Call is
  exec  GetTrlConfigForAssets 'T1','TAZ','1',@trlcfg OUTPUT
  WHere first three arguments are the tractor number, the trailer id and the pup trailer ID

 DPETE 8/24/04 PTS24469(22082)
 DPETE 9/21/04 PTS 24811 Modify such that an UNK loading class on a tractor (other than UNKNOWN tractor) will
    not match to an UNK tractor or PUP loading class on the equipment config header
*/


Select  @@TrlConfig = ech_train_config
From equipmentconfigheader
Where ech_trc_loading_class = (Select IsNull(trc_loading_class,'UNK') From tractorprofile Where 
 trc_number = IsNull(@trcID,'UNKNOWN')) 
-- strange code to make sure an asset that was not assigned a loading class will not match to UNK in the equipmentconfigheader
 and ech_lead_trl_loading_class =  IsNull((Select IsNull(trl_loading_class,'UNK') From trailerprofile Where 
   trl_ID = @trlID and (trl_loading_class  <> 'UNK' or @TrlID = 'UNKNOWN')),'^^^') 
 and ech_pup_trl_loading_class = IsNull((Select IsNull(trl_loading_class,'UNK') From trailerprofile Where 
   trl_ID = @PUPID and (trl_loading_class  <> 'UNK' or @PUPID = 'UNKNOWN')),'^^^') 


Select @@trlconfig =  Case IsNull(@@trlConfig,'') When '' Then 'UNK' else @@trlconfig End


GO
GRANT EXECUTE ON  [dbo].[GetTrlConfigForAssets] TO [public]
GO
