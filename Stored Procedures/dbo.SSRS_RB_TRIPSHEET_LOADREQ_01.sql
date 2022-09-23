SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SSRS_RB_TRIPSHEET_LOADREQ_01]

 @mov_number INTEGER  

AS  

SELECT 
CASE loadrequirement.lrq_equip_type
	WHEN 'DRV' THEN 'Driver'
	WHEN 'CAR' THEN 'Carrier'
	WHEN 'TRC' THEN 'Tractor'
	WHEN 'TRL' THEN 'Trailer'
	ELSE Loadrequirement.lrq_equip_type
	END AS'lrq_equip_type', 
 loadrequirement.lrq_not,
loadrequirement.lrq_type, 
CASE loadrequirement.lrq_manditory
	WHEN 'Y' THEN 'Must have/be'
	ELSE 'Should have/be'
	END AS'lrq_manditory',  
loadrequirement.ord_hdrnumber, 
loadrequirement.lrq_sequence, 
loadrequirement.lrq_quantity, 
orderheader.ord_number, 
loadrequirement.cmp_id, 
loadrequirement.def_id_type,
loadrequirement.stp_number,
loadrequirement.fgt_number,
loadrequirement.lgh_number,
loadrequirement.mov_number
FROM loadrequirement 
LEFT JOIN orderheader 
	ON loadrequirement.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE loadrequirement.mov_number = @mov_number



GO
