SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE       View [dbo].[vTTSTMW_PayTo]

As

--Added pto_gps_class 8/5/2005 BK

SELECT           pto_id as PayToID, 
		 pto_id as PayToIDList, 
	         pto_altid as PayToAltID, 
                 pto_fname as [First Name], 
                 pto_mname as [Middle Name], 
                 pto_lname as [Last Name], 
                 pto_ssn as [Social Security Number], 
                 pto_address1 as [Address1], 
                 pto_address2 as [Address2], 
                 (select cty_name from city (NOLOCK) where cty_code = pto_city) as [CityName],
		 (select cty_state from city (NOLOCK) where cty_code = pto_city) as [State],
                 pto_zip as [Zip Code], 
                 pto_phone1 as [Phone Number1], 
                 pto_phone2 as [Phone Number2], 
                 pto_phone3 as [Phone Number3],
                 pto_currency as [Currency], 
                 pto_type1 as [Type1], 
                 pto_type2 as [Type2], 
                 pto_type3 as [Type3], 
                 pto_type4 as [Type4], 
                 pto_company as [Company ID], 
                 pto_division as Division, 
                 pto_terminal as Terminal, 
                 pto_status as PayToStatus, 
                 pto_lastfirst as LastFirstName, 
                 pto_fleet as Fleet, 
                 pto_misc1 as Misc1, 
                 pto_misc2 as Misc2, 
                 pto_misc3 as Misc3, 
                 pto_misc4 as Misc4, 
                 pto_updatedby as UpdatedBy, 
                 pto_updateddate as UpdatedDate, 
                 pto_yrtodategross as YearToDateGross, 
                 pto_socsecfedtax as SocSecFedTax,  
                 pto_dirdeposit as DirectDeposit, 
                 pto_fleettrc as FleetTrc, 
                 pto_startdate as [Start Date], 
                 pto_terminatedate as [Termination Date], 
                 pto_createdate as [Created Date], 
                 pto_companyname as CompanyName,
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Regulatory Code 1],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Regulatory_code_1 as [Regulatory Code 1],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Regulatory Code 2],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Regulatory_code_2 as [Regulatory Code 2],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Country],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --pto_country as [Country],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 pto_gp_class as [GP Class],
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Make BillTo],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --pto_make_billto as [Make BillTo],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		  
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Payment Terms],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --pto_payment_terms as [Payment Terms],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Account Number],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_Account_Number as [Bank Account Number],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Branch],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_Branch as [Bank Branch],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Branch Code],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_Branch_code as [Bank Branch Code],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Check Digit],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_Check_digit as [Bank Check Digit],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Code],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_code as [Bank Code],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Country Code],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_country_code as [Bank Country Code],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Format],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_Format as [Bank Format],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Bank Name],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Bank_Name as [Bank Name],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Central Bank Code],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Central_Bank_code as [Central Bank Code],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Creditor Country Code],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Creditor_country_code as [Creditor Country Code],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Delivery Country Code],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Delivery_country_code as [Delivery Country Code],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Giro Post Type],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --GIRO_Post_Type as [Giro Post Type],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Vendor On Hold],
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Vendor_on_hold as [Vendor On Hold],
		 --<TTS!*!TMW><End><FeaturePack=Euro>
		 
		 --<TTS!*!TMW><Begin><FeaturePack=Other>
		 '' as [Swift Address]
		 --<TTS!*!TMW><End><FeaturePack=Other>
		 --<TTS!*!TMW><Begin><FeaturePack=Euro>
		 --Swift_address as [Swift Address]
		 --<TTS!*!TMW><End><FeaturePack=Euro>
 
FROM       payto







GO
GRANT SELECT ON  [dbo].[vTTSTMW_PayTo] TO [public]
GO
