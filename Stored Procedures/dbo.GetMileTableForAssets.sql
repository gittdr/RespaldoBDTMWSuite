SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetMileTableForAssets] (@trcID varchar(15),@trlID varchar(15),@pupID varchar(15),@@Ltable tinyint OUTPUT,
  @@Utable tinyint OUTPUT)

AS
/*   DPETE 8/24/04

 Returns the mile table to use for empty and loaded miles given the set of assets on the trip
 Returns zero in output variables if the mile table cannot be determined

  Call is
  exec  GetMileTableForAssets 'T1','TAZ','1',@@ltable OUTPUT,@@Utable OUTPUT
  WHere first three arguments are the tractor number, the trailer id and the pup trailer ID
  The last two are the mile table to use for loaded miles and the mile table to use for empty miles

*/
Declare @trlcfg varchar(6)

Exec  GetTrlConfigForAssets @trcid,@trlid,@pupid,@trlcfg OUTPUT

Select @@ltable =  Convert(tinyint,IsNull(cfg_mt_type_loaded,'0'))
   ,@@uTable = Convert(tinyint,IsNull(cfg_mt_type_empty,'0'))
From trlconfiguration
Where cfg_trlconfiguration = @trlcfg


Select @@ltable =  IsNull(@@ltable,0) 
Select @@uTable =  IsNull(@@uTable,0) 



GO
GRANT EXECUTE ON  [dbo].[GetMileTableForAssets] TO [public]
GO
