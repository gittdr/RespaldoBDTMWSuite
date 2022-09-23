SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE  Procedure [dbo].[sp_TTSTMW_FLM_CompanyInfo]
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show Company Information in File Maintenance Reports
--********************************************************************

--Revision History: 


SELECT company.cmp_id AS CompanyID, 
       company.cmp_name AS CompanyName, 
       company.cmp_address1 AS Address1, 
       company.cmp_address2 AS Address2, 
       city.cty_name AS City, 
       city.cty_state AS State, 
       city.cty_zip AS Zip, 
       company.cmp_contact AS Contact, 
       company.cmp_primaryphone AS Phone, 
       company.cmp_shipper AS Shipper, 
       company.cmp_consingee AS Consignee, 
       company.cmp_billto AS BillTo, 
       company.cmp_artype AS ARType, 
       company.cmp_invoicetype AS InvType, 
       company.cmp_revtype1 AS RevType1, 
       company.cmp_revtype2 AS RevType2,
       company.cmp_revtype3 AS RevType3, 
       company.cmp_revtype4 AS RevType4, 
       company.cmp_active AS Active, 
       company.cmp_mileagetable AS MileageTable

FROM   company INNER JOIN city ON company.cmp_city = city.cty_code










GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_CompanyInfo] TO [public]
GO
