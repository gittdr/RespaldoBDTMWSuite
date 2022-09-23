SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vSSRSRB_TrailerDetail]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_TrailerDetail]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_TrailerDetail
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_TrailerDetail]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/

SELECT tp.*,
	   trl_det_compartment as [Detail Compartment],	
	   trl_det_wet as [Detail Wet],
	   trl_det_vol as [Detail Vol],
	   trl_det_uom as [Detail UOM],
	   trl_det_innage as [Detail Innage],
	   trl_det_depth as [Detail Depth],
	   trl_det_ref_pt as [Detail Ref Pt],	
	   trl_det_f_bulk as [Detail F Bulk],
	   trl_det_r_bulk as [Detail R Bulk],
	   trl_det_chart as [Detail Chart],
	   trl_det_depth_uom as [Detail Depth UOM]
--SELECT *
FROM dbo.trailer_detail td WITH (NOLOCK)
JOIN vSSRSRB_TrailerProfile tp WITH(NOLOCK)
	ON td.trl_id = tp.[Trailer ID]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_TrailerDetail] TO [public]
GO
