SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[MobileCustomersView]
AS

     --Revision History
     --Added 
     --1. Shipper Last Business Date,Consignee Last Business Date,Bill To Last Business Date
     --   Ver 5.4 LBK   
     --2. Added Penske/Euro Specific Fields Ver 5.43 LBK


     SELECT 'TMWWF_MOBILE_CUSTOMERS' AS 'TMWWF_MOBILE_CUSTOMERS',
            LTRIM(C.cmp_id) AS 'ID',
            LTRIM(RTRIM(C.cmp_name)) AS 'Name',
            LTRIM(RTRIM(C.cmp_address1)) AS 'Address1',
            LTRIM(RTRIM(C.cmp_address2)) AS 'Address 2',
            C.cmp_city AS 'City',
			LTRIM(city.cty_name) 'CityName',
			LTRIM(RTRIM(city.cty_state)) 'State',
            LTRIM(RTRIM(C.cmp_zip)) AS 'Zip Code',
            LTRIM(RTRIM(C.cmp_primaryphone)) AS 'Primary Phone Number',
            LTRIM(RTRIM(C.cmp_secondaryphone)) AS 'Secondary Phone Number',
            LTRIM(RTRIM(C.cmp_faxphone)) AS 'Fax Phone Number',
            C.cmp_shipper AS 'Shipper',
            C.cmp_consingee AS 'Consignee',
            C.cmp_billto AS 'Bill To',
            LTRIM(C.cmp_othertype1) AS 'Other Type1',
            LTRIM(C.cmp_othertype2) AS 'Other Type2',
            LTRIM(C.cmp_revtype1) AS 'RevType1', 'RevType1 Name' = COALESCE(LTRIM(L1.name), ''),
            LTRIM(C.cmp_revtype2) AS 'RevType2', 'RevType2 Name' = COALESCE(LTRIM(L2.name), ''),
            LTRIM(C.cmp_revtype3) AS 'RevType3', 'RevType3 Name' = COALESCE(LTRIM(L3.name), ''),
            LTRIM(C.cmp_revtype4) AS 'RevType4', 'RevType4 Name' = COALESCE(LTRIM(L4.name), ''),
            LTRIM(RTRIM(C.cmp_geoloc_forsearch)) AS 'GeoLoc ForSearch',
            C.cmp_edi210 AS 'EDI 210'
     FROM dbo.company C WITH (NOLOCK)
		  LEFT OUTER JOIN city WITH (NOLOCK) ON C.cmp_city = city.cty_code
          LEFT OUTER JOIN labelfile L1 WITH (NOLOCK) ON C.cmp_revtype1 = L1.abbr AND L1.labeldefinition = 'RevType1'
          LEFT OUTER JOIN labelfile L2 WITH (NOLOCK) ON C.cmp_revtype2 = L2.abbr AND L2.labeldefinition = 'RevType2'
          LEFT OUTER JOIN labelfile L3 WITH (NOLOCK) ON C.cmp_revtype3 = L3.abbr AND L3.labeldefinition = 'RevType3'
          LEFT OUTER JOIN labelfile L4 WITH (NOLOCK) ON C.cmp_revtype4 = L4.abbr AND L4.labeldefinition = 'RevType4';
GO
GRANT SELECT ON  [dbo].[MobileCustomersView] TO [public]
GO
