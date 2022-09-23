SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Proc [dbo].[d_accidentreport02inj_sp] @srpid int 
As
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
   SR 21430 DPETE created 12/10/03 For subreport of d_accidentreport02_sp with injuries
 * 11/28/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
Select inj_name = Isnull(inj_name,''),
  inj_address1 = IsNull(inj_address1,''),
  inj_address2 = IsNull(inj_address2,''),
  cty_name = IsNull(cty_name,''),
  inj_state = IsNull(inj_state,''),
  inj_zip = IsNull(inj_zip,''),
  inj_homephone = IsNull(inj_homephone,''),
  inj_workphone = IsNull(inj_workphone,''),
  inj_description = IsNull(inj_description,''),
  inj_howoccured = IsNull(inj_howOccurred,''),
  inj_personis = IsNull(inj_personis,'O'),
  inj_treatedatscene = IsNull(inj_treatedatscene,'N'),
  inj_treatedawayfromscene = IsNull(inj_treatedawayfromscene,'N'),
  inj_isfatal = IsNull(inj_isfatal,'N'),
  inj_claimindoubt=IsNull(inj_claimindoubt,'N'),
  inj_medicalrestrictions = IsNull(inj_medicalrestrictions,''),
  inj_lastdateworked = IsNull(inj_lastdateworked,'1-1-1950'),
  inj_expectedreturn = IsNull(inj_expectedreturn,'1-1-1950')
From city RIGHT OUTER JOIN injury ON city.cty_code = injury.inj_city
Where srp_ID = @srpid
GO
GRANT EXECUTE ON  [dbo].[d_accidentreport02inj_sp] TO [public]
GO
