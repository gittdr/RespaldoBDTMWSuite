SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
create procedure [dbo].[d_dddw_label_extequipmenttype_sp]     
as 
/**
 * 
 * NAME:
 * dbo.d_dddw_label_extequipmenttype_sp 
 *
 * TYPE:
 * [StoredProcedure)
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * PARAMETERS:
 * none 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * 
 * REVISION HISTORY:
 *	PTS 50742 JJF 20100216 initial
 **/


	SELECT	1 as sortorder,
			'ITEM' as valuetype,
			name,
			abbr,
			label_extrastring1 as member_of_group
	FROM	labelfile 
	WHERE	labeldefinition = 'ExtEquipmentType'
			and isnull(retired, 'N') <> 'Y'
UNION 
	SELECT DISTINCT 2 as sortorder,
			'GROUP' as valuetype,
			LEFT(label_extrastring1, 6) as name,
			LEFT(label_extrastring1, 6) as abbr,
			'N/A' as member_of_group
	FROM	labelfile 
	WHERE	labeldefinition = 'ExtEquipmentType'
			and isnull(retired, 'N') <> 'Y'
			and isnull(label_extrastring1, '') <> '' 
			and label_extrastring1 <> 'UNK'
UNION
	SELECT	0 as sortorder,
			'ALL' as valuetype,
			'ALL' as name,
			'ALL' as abbr,
			'N/A' as member_of_group
ORDER BY	sortorder, name

GO
GRANT EXECUTE ON  [dbo].[d_dddw_label_extequipmenttype_sp] TO [public]
GO
