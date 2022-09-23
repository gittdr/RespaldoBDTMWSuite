SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO









CREATE             View [dbo].[vTTSTMW_TrailerDetail]

As

--Revision History
--1. Added Driver Types and Driver First Last Name,Driver Terminal Field For Driver 1
     --Ver 5.2 LBK

SELECT     vTTSTMW_TrailerProfile.*,
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
	


FROM       dbo.trailer_detail (NOLOCK),
	   vTTSTMW_TrailerProfile
Where      [Trailer ID] = trl_id















GO
GRANT SELECT ON  [dbo].[vTTSTMW_TrailerDetail] TO [public]
GO
