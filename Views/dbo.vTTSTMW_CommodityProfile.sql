SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE       View [dbo].[vTTSTMW_CommodityProfile]

As

--Revision History
--1. Added Euro/Penske specific fields
--   Ver 5.5 LBK

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
           cmd_flash_point as 'Flash Point',
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Adr Class], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
 	   --cmd_adr_class as [Adr Class],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Adr Packaging Group],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --cmd_adr_packaging_group as [Adr Packaging Group], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Adr Trem],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --cmd_adr_trem as [Adr Trem], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Company Prohibited],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --cmd_company_prohibited as [Company Prohibited], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Flash Point Max], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --cmd_flash_point_max as [Flash Point Max],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Haz SubClass2], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --cmd_haz_subclass2 as [Haz SubClass2], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Imdg Class], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --cmd_imdg_class as [Imdg Class],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Imdg Packaging Group],  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
          --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --cmd_imdg_packaging_group as [Imdg Packaging Group], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Imdg SubClass],  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --cmd_imdg_subclass as [Imdg SubClass], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Imdg SubClass2], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --cmd_imdg_subclass2 as [Imdg SubClass2], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Imdg Trem], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --commodity.cmd_imdg_trem as [Imdg Trem],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Non Spec] 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --commodity.cmd_non_spec as [Non Spec]
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

from commodity (NOLOCK)








GO
GRANT SELECT ON  [dbo].[vTTSTMW_CommodityProfile] TO [public]
GO
