SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[add_equip_totals_proc]
(
--This could either be a single company ID, or a comma separated list of company IDs
@cmpid varchar (max)
)
AS
BEGIN
	SELECT equipment_type as EquipmentType,
	CASE 
		WHEN sum([Incoming_Quantity]-[Outgoing_Quantity]) <= 0 THEN 0
		WHEN sum([Incoming_Quantity]-[Outgoing_Quantity]) > 0 THEN sum([Incoming_Quantity]-[Outgoing_Quantity])
	END as Total from additional_equipment
	WHERE Company_Id in (SELECT * FROM dbo.SplitStrings_Bigger(@cmpid,','))
	GROUP BY Equipment_Type
END
GO
GRANT EXECUTE ON  [dbo].[add_equip_totals_proc] TO [public]
GO
