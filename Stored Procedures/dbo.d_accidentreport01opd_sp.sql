SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create Proc [dbo].[d_accidentreport01opd_sp] @srpid int 
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
   SR 17782 DPETE created 12/10/03 For subreport of d_accidentreport01_sp with other vehicle damage
   21787 DPETE remove ins co information
 * 11/28/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/
Select srp_id,
  prp_Owneris = IsNull(prp_OwnerIs,'O'),
  prp_Ownername = IsNull(prp_Ownername,''),
  prp_Owneraddress1 = IsNull(prp_OwnerAddress1,''),
  prp_Owneraddress2 = IsNull(prp_OwnerAddress2,''),
  ownercitystatezip = IsNull(c1.cty_name,'')+IsNull(', '+prp_OwnerState,'')+IsNull('    '+prp_OwnerZip,''),
  prp_OwnerPhone = IsNull(prp_OwnerPhone,''),
  prp_Description = IsNull(prp_Description,''),
  prp_Damage = IsNull(prp_Damage,''),
  prp_value = IsNull(prp_value,0),
  prp_ActionTaken = IsNull(prp_ActionTaken,'')
From (Select cty_code,cty_name From city where cty_code in (Select prp_OwnerCity From propertydamage o1 Where o1.srp_ID = @srpid)) c1 
		RIGHT OUTER JOIN propertydamage ON c1.cty_code = propertydamage.prp_Ownercity  --pts40462 outer join conversion
Where srp_ID = @srpid
  
GO
GRANT EXECUTE ON  [dbo].[d_accidentreport01opd_sp] TO [public]
GO
