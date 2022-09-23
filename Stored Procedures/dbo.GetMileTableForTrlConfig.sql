SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[GetMileTableForTrlConfig] (@TrlCfg varchar(6),@@Ltable tinyint OUTPUT,
  @@Utable tinyint OUTPUT)

AS
/*   DPETE 9/2/04

 Returns the mile table to use for empty and loaded miles given a trailer configuration value

  Call is
  exec  GetMileTableForTrlConfig '8AXB',@@ltable OUTPUT,@@Utable OUTPUT
  WHere first three arguments are the tractor number, the trailer id and the pup trailer ID
  The last two are the mile table to use for loaded miles and the mile table to use for empty miles

*/


Select @@ltable =  Convert(tinyint,IsNull(cfg_mt_type_loaded,'0'))
   ,@@uTable = Convert(tinyint,IsNull(cfg_mt_type_empty,'0'))
From trlconfiguration
Where cfg_trlconfiguration = @trlcfg


Select @@ltable =  IsNull(@@ltable,0) 
Select @@uTable =  IsNull(@@uTable,0) 



GO
GRANT EXECUTE ON  [dbo].[GetMileTableForTrlConfig] TO [public]
GO
