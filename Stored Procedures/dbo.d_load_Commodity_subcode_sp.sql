SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/* DPETE PTS22154 3/30/04 (Paul's Hauling) Need to specify by company what may be picked up or delivered.
      For pickups only, specify product characterisitcs (density)
   DPETE 22694 allow for a row when there is no subcodes for commodity


*/
CREATE PROCEDURE [dbo].[d_load_Commodity_subcode_sp] @cmdcode varchar(8)
AS

If Exists (Select scm_subcode From subcommodity Where cmd_code = @cmdcode)
  Select 
    code = scm_subcode
  ,   name = scm_description	
  From subcommodity 
  Where cmd_code = @cmdcode
  Order by scm_subcode
Else
  Select
    code = scm_subcode
  ,   name = scm_description
  From subcommodity 
  Where cmd_code = 'UNKNOWN'

GO
GRANT EXECUTE ON  [dbo].[d_load_Commodity_subcode_sp] TO [public]
GO
