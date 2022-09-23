SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_ltl_accessorial_sp]
AS

SELECT	'N' include_flag,
		lac_id,  
		Coalesce(lac_group_id, 'NONE') lac_group_id, 
		CASE coalesce(lac_group_id, 'NONE') WHEN 'NONE' THEN '' ELSE lbl.name END group_name,
		lbl.code group_sort, 
		lac_display_order, 
		lac_description,
		lac_chargetypes, 
		lac_paytypes
FROM ltl_accessorial lac
LEFT JOIN labelfile lbl on lbl.abbr = lac.lac_group_id AND lbl.labeldefinition = 'LTLDisplayGroup'
WHERE coalesce(lac_retired, 'N') = 'N'
ORDER by group_sort, lac_display_order

GO
GRANT EXECUTE ON  [dbo].[d_ltl_accessorial_sp] TO [public]
GO
