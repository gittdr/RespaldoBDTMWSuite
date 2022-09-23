SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE             View [dbo].[vTTSTMW_CarrierProfile]

As

--Revision History
--1. Added Euro/Penske specific fields
--   Ver 5.5 LBK
--2. Added trend analysis fields Day,Month, and Year

SELECT     carrier.car_id as 'Carrier ID',
           carrier.car_name as 'Carrier Name', 
           carrier.car_fedid as 'Carrier Federal ID', 
           carrier.car_address1 as 'Address1', 
           carrier.car_address2 as 'Address2', 
	   (select cty_name from city (NOLOCK) where city.cty_code = carrier.cty_code) as [Carrier City],
	   (select cty_state from city (NOLOCK) where city.cty_code = carrier.cty_code) as [Carrier State],
           carrier.cty_code as 'City Code', 
           carrier.car_zip as 'Zip Code', 
           carrier.pto_id as 'Pto Id', 
           carrier.car_scac as 'Carrier Scac Code', 
           carrier.car_contact as 'Contact', 
           carrier.car_type1 as 'CarType1', 
           carrier.car_type2 as 'CarType2', 
           carrier.car_type3 as 'CarType3', 
           carrier.car_type4 as 'CarType4', 
           'CarType1 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = carrier.car_type1 and labelfile.labeldefinition = 'CarType1'),''),
           'CarType2 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = carrier.car_type2 and labelfile.labeldefinition = 'CarType2'),''),
           'CarType3 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = carrier.car_type3 and labelfile.labeldefinition = 'CarType3'),''),
           'CarType4 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = carrier.car_type4 and labelfile.labeldefinition = 'CarType4'),''),
           carrier.car_misc1 as 'Misc1', 
           carrier.car_misc2 as 'Misc2', 
           carrier.car_misc3 as 'Misc3', 
           carrier.car_misc4 as 'Misc4', 
           carrier.car_phone1 as 'Phone Number', 
           carrier.car_phone2 as 'Phone Number 2',  
           carrier.car_phone3 as 'Phone Number 3', 
           carrier.car_lastactivity as 'Last Activity', 
           carrier.car_actg_type as 'Accounting Type', 
           carrier.car_iccnum as 'Icc Number', 
           carrier.car_contract as 'Contract', 
           carrier.car_otherid as 'Other Id', 
           carrier.car_usecashcard as 'Use Cash Card', 
           carrier.car_status as 'Carrier Status', 
           carrier.car_board as 'Board', 
           carrier.car_updatedby as 'Updated By', 
           carrier.car_updateddate as 'Updated Date', 
           --**Created Date**
       	   carrier.car_createdate as 'Created Date', 
           --Day
           (Cast(Floor(Cast(carrier.[car_createdate] as float))as smalldatetime)) as [Created Date Only], 
           Cast(DatePart(yyyy,carrier.[car_createdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,carrier.[car_createdate]) as varchar(2)) + '-' + Cast(DatePart(dd,carrier.[car_createdate]) as varchar(2)) as [Created Day],
           --Month
           Cast(DatePart(mm,carrier.[car_createdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,carrier.[car_createdate]) as varchar(4)) as [Created Month],
           DatePart(mm,carrier.[car_createdate]) as [Created Month Only],
           --Year
           DatePart(yyyy,carrier.[car_createdate]) as [Created Year],  
	   carrier.car_exp1_date as 'Exp1 Date', 
           carrier.car_exp2_date as 'Exp2 Date', 
           --**Termination Date**
       	   car_terminationdt as 'Termination Date',
           --Day
           (Cast(Floor(Cast(carrier.[car_terminationdt] as float))as smalldatetime)) as [Termination Date Only], 
           Cast(DatePart(yyyy,carrier.[car_terminationdt]) as varchar(4)) +  '-' + Cast(DatePart(mm,carrier.[car_terminationdt]) as varchar(2)) + '-' + Cast(DatePart(dd,carrier.[car_terminationdt]) as varchar(2)) as [Termination Day],
           --Month
           Cast(DatePart(mm,carrier.[car_terminationdt]) as varchar(2)) + '/' + Cast(DatePart(yyyy,carrier.[car_terminationdt]) as varchar(4)) as [Termination Month],
           DatePart(mm,carrier.[car_terminationdt]) as [Termination Month Only],
           --Year
           DatePart(yyyy,carrier.[car_terminationdt]) as [Termination Year],  
           carrier.car_email as 'Email', 
           carrier.car_service_location as 'Service Location',
           --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as Branch,
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_branch as Branch,		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as Country,
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   -- carrier.car_country as Country,		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
 	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [GP Class],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_gp_class as [GP Class],	
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as Agent,
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_agent as Agent,		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [Quick Entry],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_quickentry as [Quick Entry],		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [WayBill Range Start],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_waybill_range_start as [WayBill Range Start],		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [WayBill Range End],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_waybill_range_end as [WayBill Range End],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [Misc Type]
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --carrier.car_misc_type as [Misc Type]	
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	  







from carrier (NoLock)















GO
GRANT SELECT ON  [dbo].[vTTSTMW_CarrierProfile] TO [public]
GO
