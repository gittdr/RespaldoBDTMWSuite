SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   View [dbo].[vSSRSRB_CommodityProfile]

As

/**
 *
 * NAME:
 * dbo.vSSRSRB_CommodityProfile
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve for Commodity data 
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Revised 
 **/

SELECT     commodity.cmd_code as 'Commodity Code', 
           commodity.cmd_makeup_description as 'Description', 
           commodity.cmd_name as 'Commodity Name', 
           commodity.cmd_class as 'Commodity Class', 
           commodity.cmd_pin as 'Commodity Pin', 
           commodity.cmd_stcc as 'Stcc', 
           commodity.cmd_hazardous as 'Hazardous', 
           commodity.cmd_code_num as 'Commodity Code Number', 
           commodity.cmd_misc1 as 'Misc1', 
           commodity.cmd_misc2 as 'Misc2', 
           commodity.cmd_misc3 as 'Misc', 
           commodity.cmd_misc4 as 'Misc4', 
           commodity.cmd_specificgravity as 'Specific Gravity', 
           commodity.cmd_gravtemperature as 'Gravity Temperature', 
           commodity.cmd_temperatureunit as 'Temperature Unit', 
           commodity.cmd_taxtable1 as 'TaxTable1', 
           commodity.cmd_taxtable2 as 'TaxTable2', 
           commodity.cmd_taxtable3 as 'TaxTable3', 
           commodity.cmd_taxtable4 as 'TaxTable4', 
           commodity.cmd_updatedby as 'Updated By', 
           commodity.cmd_updateddate as 'Updated Date', 
           commodity.cmd_createdate as 'Created Date', 
           commodity.cmd_active as 'Active', 
           commodity.cmd_cust_num as 'Customer Number', 
           commodity.cmd_dot_name as 'Dot Name', 
           commodity.cmd_haz_num as 'Hazardous Number', 
           commodity.cmd_waste_code as 'Waste Code', 
           commodity.cmd_haz_class as 'Hazardous Class', 
           commodity.cmd_haz_subclass as 'Hazardous Sub Class', 
           commodity.cmd_pin_flag as 'Pin Flag', 
           cmd_risk as 'Risk', 
           cmd_marine as 'Marine', 
           cmd_spec_prov as 'Special Approval', 
           cmd_cmp_id as 'Commodity Company ID', 
           cmd_flash_point as 'Flash Point'

from commodity WITH (NOLOCK)

GO
GRANT DELETE ON  [dbo].[vSSRSRB_CommodityProfile] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_CommodityProfile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_CommodityProfile] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_CommodityProfile] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_CommodityProfile] TO [public]
GO
