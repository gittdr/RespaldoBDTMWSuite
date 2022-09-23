SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE            view [dbo].[vTTSTMW_CompanyProfile]

as

--Revision History
--Added 
--1. Shipper Last Business Date,Consignee Last Business Date,Bill To Last Business Date
--   Ver 5.4 LBK   
--2. Added Penske/Euro Specific Fields Ver 5.43 LBK


SELECT     company.cmp_id as 'Company ID', 
	   company.cmp_name as 'Company Name', 
           company.cmp_address1 as 'Address1', 
           company.cmp_address2 as 'Address 2', 
           company.cmp_city as 'City', 
	   IsNull((select cty_name from city (NOLOCK) where cmp_city = cty_code),'') as 'City Name', 
           IsNull((select cty_nmstct from city (NOLOCK) where cmp_city = cty_code),'') as 'City State', 
	   company.cmp_zip as 'Zip Code', 
           company.cmp_primaryphone as 'Primary Phone Number', 
           company.cmp_secondaryphone as 'Secondary Phone Number', 
           company.cmp_faxphone as 'Fax Phone Number', 
           company.cmp_shipper as 'Shipper', 
           company.cmp_consingee as 'Consignee',  
           company.cmp_billto as 'Bill To', 
           company.cmp_othertype1 as 'Other Type1', 
           company.cmp_othertype2 as 'Other Type2', 
           company.cmp_artype as 'Accounts Receivable Type', 
           company.cmp_invoicetype as 'Invoice Type', 
           company.cmp_revtype1 as 'RevType1', 
           company.cmp_revtype2 as 'RevType2', 
           company.cmp_revtype3 as 'RevType3', 
           company.cmp_revtype4 as 'RevType4', 
           'RevType1 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = company.cmp_revtype1 and labelfile.labeldefinition = 'RevType1'),''),
           'RevType2 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = company.cmp_revtype2 and labelfile.labeldefinition = 'RevType2'),''),
           'RevType3 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = company.cmp_revtype3 and labelfile.labeldefinition = 'RevType3'),''),
           'RevType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = company.cmp_revtype4 and labelfile.labeldefinition = 'RevType4'),''),                 
           company.cmp_currency as 'Currency', 
           company.cmp_active as 'ActiveYN',
           company.cmp_opens_mo as 'Opens Month', 
           company.cmp_closes_mo as 'Closes Month', 
           company.cmp_creditlimit as 'Credit Limit', 
           company.cmp_creditavail as 'Credit Available', 
           company.cmp_mileagetable as 'Mileage Table', 
           company.cmp_mastercompany as 'Master Company', 
           company.cmp_terms as 'Terms', 
           company.cmp_defaultbillto as 'Default Bill To', 
           company.cmp_edi214 as 'EDI 214', 
           company.cmp_edi210 as 'EDI 210', 
           company.cmp_edi204 as 'EDI 204', 
           company.cmp_state as 'State',  
           company.cmp_region1 as 'Region1', 
           company.cmp_region2 as 'Region2', 
           company.cmp_region3 as 'Region3', 
           company.cmp_region4 as 'Region4', 
           company.cmp_addnewshipper as 'Add New Shipper', 
           company.cmp_opensun as 'Open Sunday', 
           company.cmp_openmon as 'Open Monday', 
           company.cmp_opentue as 'Open Tuesday', 
           company.cmp_openwed as 'Open Wednesday', 
           company.cmp_openthu as 'Open Thursday', 
           company.cmp_openfri as 'Open Friday', 
           company.cmp_opensat as 'Open Saturday', 
           company.cmp_payfrom as 'Pay From', 
           company.cmp_mapfile as 'Map File', 
           company.cmp_contact as 'Contact', 
           company.cmp_directions as 'Directions',
           company.cty_nmstct as 'City Name State', 
           company.cmp_misc1 as 'Misc1', 
           company.cmp_misc2 as 'Misc2', 
           company.cmp_misc3 as 'Misc3', 
           company.cmp_misc4 as 'Misc4', 
           company.cmp_mbdays as 'Master Bill Days', 
           company.cmp_lastmb as 'Last Master Bill', 
           company.cmp_invcopies as 'Invoice Copies', 
           company.cmp_transfertype as 'Transfer Type', 
	   company.cmp_altid as 'Alt ID', 
           company.cmp_updatedby as 'Updated By', 
           company.cmp_updateddate as 'Updated Date', 
           company.cmp_defaultpriority as 'Default Priority', 
           company.cmp_invoiceto as 'Invoice To', 
           company.cmp_invformat as 'Invoice Format', 
           company.cmp_invprintto as 'Invoice Print To', 
           company.cmp_creditavail_update as 'Credit Available Update', 
           company.cmd_code as 'Commodity Code', 
           company.junknotinuse as 'Junk Not In Use', 
           company.cmp_agedinvflag as 'Age Invoice Flag', 
           company.cmp_max_dunnage as 'Max Dunnage', 
           company.cmp_acc_balance as 'Account Balance',
           company.cmp_acc_dt as 'Account Date', 
           company.cmp_opens_tu as 'Opens Tuesday', 
           company.cmp_closes_tu as 'Closes Tuesday', 
           company.cmp_opens_we as 'Opens Wednesday', 
           company.cmp_closes_we as 'Closes Wednesday', 
           company.cmp_opens_th as 'Opens Thursday', 
           company.cmp_closes_th as 'Closes Thursday', 
           company.cmp_opens_fr as 'Opens Friday', 
           company.cmp_closes_fr as 'Closes Friday', 
           company.cmp_opens_sa as 'Opens Saturday', 
           company.cmp_closes_sa as 'Closes Saturday', 
           company.cmp_opens_su as 'Opens Sunday',  
           company.cmp_closes_su as 'Closes Sunday',  
           company.cmp_subcompany as 'Sub Company', 
           --**Created Date**
       	   company.cmp_createdate as 'Created Date', 
           --Day
           (Cast(Floor(Cast(company.[cmp_createdate] as float))as smalldatetime)) as [Created Date Only], 
           Cast(DatePart(yyyy,company.[cmp_createdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,company.[cmp_createdate]) as varchar(2)) + '-' + Cast(DatePart(dd,company.[cmp_createdate]) as varchar(2)) as [Created Day],
           --Month
           Cast(DatePart(mm,company.[cmp_createdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,company.[cmp_createdate]) as varchar(4)) as [Created Month],
           DatePart(mm,company.[cmp_createdate]) as [Created Month Only],
           --Year
           DatePart(yyyy,company.[cmp_createdate]) as [Created Year],   
           company.cmp_taxtable1 as 'Tax Table 1', 
           company.cmp_taxtable2 as 'Tax Table 2', 
           company.cmp_taxtable3 as 'Tax Table 3', 
           company.cmp_taxtable4 as 'Tax Table 4', 
           company.cmp_quickentry as 'Quick Entry', 
           company.cmp_slack_time as 'Slack Time', 
           company.cmp_mailto_name as 'Mail To Name', 
           company.cmp_mailto_address1 as 'Mail To Address1', 
           company.cmp_mailto_address2 as 'Mail To Address2', 
           company.cmp_mailto_city as 'Mail To City', 
           company.cmp_mailto_state as 'Mail To State', 
           company.cmp_mailto_zip as 'Mail To Zip', 
           company.mailto_cty_nmstct as 'Mail To City Name State', 
           company.cmp_latseconds as 'Latitude Seconds',
           company.cmp_longseconds as 'Longitude Seconds',
           company.cmp_mailto_crterm1 as 'Mail To CrTerm1',  
           company.cmp_mailto_crterm2 as 'Mail To CrTerm2',
           company.cmp_mailto_crterm3 as 'Mail To CrTerm3', 
           company.cmp_mbformat as 'Master Bill Format',
           company.cmp_mbgroup as 'Master Bill Group',
           company.cmp_centroidcity as 'Centroid City',
           company.cmp_centroidctynmstct as 'Centroid City Name City State', 
           company.cmp_centroidzip as 'Centroid City Zip',
           company.cmp_ooa_mileage as 'Ooa Mileage',
           company.cmp_ooa_mileage_stops as 'Ooa Mileage Stops',
           company.cmp_mapaddress as 'Map Address',
           company.cmp_usestreetaddr as 'Use Street Address',
           company.cmp_primaryphoneext as 'Primary Phone Extension',
           company.cmp_secondaryphoneext as 'Seconday Phone Extension',
           company.cmp_palletcount as 'Pallet Count',
           company.cmp_fueltableid as 'Fuel Table ID',
           company.grp_id as 'Group ID',
           company.cmp_parent as 'Parent',
           company.cmp_country as 'Country',
           company.cmp_address3 as 'Address3',
           company.cmp_slacktime_late as 'Slack Time Late',
           company.cmp_geoloc as 'Geographic Location',
           company.cmp_min_charge as 'Minimum Charge',
           company.cmp_service_location as 'Service Location',
           company.cmp_psoverride as 'Ps Override',
           company.cmp_geoloc_forsearch as 'Geographic Location For Search',
	   'Shipper Last Business Date' = (select max(customercrossref.cxr_lastbusinessdt) from customercrossref where customercrossref.cxr_shipper = company.cmp_id),
	   'Consignee Last Business Date' = (select max(customercrossref.cxr_lastbusinessdt) from customercrossref where customercrossref.cxr_consignee = company.cmp_id),
	   'Bill To Last Business Date' =  (select max(invoiceheader.ivh_billdate) from invoiceheader where invoiceheader.ivh_billto = company.cmp_id),
	    --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Depot],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_depot as [Depot],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
 	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [GP Class],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_gp_class as [GP Class], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [House Number],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_house_number as [House Number],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Image Routing1],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_image_routing1 as [Image Routing1],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
 	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Image Routing2],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_image_routing2 as [Image Routing2], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Image Routing3],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_image_routing3 as [Image Routing3],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [MailTo Country], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_mailto_country as [MailTo Country],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [MailTo House Number],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_mailto_house_number as [MailTo House Number], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [MailTo Street Name], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --company.cmp_mailto_street_name as [MailTo Street Name], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Make Payto], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
           --company.cmp_make_payto as [Make Payto], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
  	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Payment Terms], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --company.cmp_Payment_terms as [Payment Terms], 
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
 	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Port],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --company.cmp_port as [Port],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Sales Person],
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --company.cmp_sales_person as [Sales Person],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Street Name], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
 	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --company.cmp_street_name as [Street Name],
	  --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Tax ID], 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --company.cmp_taxid as [Tax ID],  
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Doc Language]  
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --company.doc_language as [Doc Language]
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

FROM         dbo.company (NOLOCK)














GO
GRANT SELECT ON  [dbo].[vTTSTMW_CompanyProfile] TO [public]
GO
