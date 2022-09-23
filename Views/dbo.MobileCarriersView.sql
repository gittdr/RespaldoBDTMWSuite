SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[MobileCarriersView]
AS
     SELECT LTRIM(C.car_id) AS 'ID',
            LTRIM(C.car_name) AS 'Name',
            LTRIM(RTRIM(C.car_fedid)) AS 'Carrier Federal ID',
            LTRIM(C.car_address1) AS 'Address1',
            LTRIM(C.car_address2) AS 'Address2',
            LTRIM(city.cty_name) 'City',
            LTRIM(RTRIM(city.cty_state)) 'State',
            LTRIM(RTRIM(C.car_zip)) AS 'Zip Code',
            LTRIM(C.pto_id) AS 'Pto Id',
            LTRIM(C.car_scac) AS 'Carrier Scac Code',
            LTRIM(C.car_iccnum) AS 'Icc Number',
            LTRIM(C.car_contact) AS 'Contact',
            LTRIM(RTRIM(C.car_email)) AS 'Email',
            LTRIM(C.car_type1) AS 'CarType1', 'CarType1 Name' = COALESCE(LTRIM(L1.name), ''),
            LTRIM(C.car_type2) AS 'CarType2', 'CarType2 Name' = COALESCE(LTRIM(L2.name), ''),
            LTRIM(C.car_type3) AS 'CarType3', 'CarType3 Name' = COALESCE(LTRIM(L3.name), ''),
            LTRIM(C.car_type4) AS 'CarType4', 'CarType4 Name' = COALESCE(LTRIM(L4.name), ''),
            LTRIM(RTRIM(C.car_misc1)) AS 'Misc1',
            LTRIM(RTRIM(C.car_misc2)) AS 'Misc2',
            LTRIM(RTRIM(C.car_misc3)) AS 'Misc3',
            LTRIM(RTRIM(C.car_misc4)) AS 'Misc4',
            LTRIM(C.car_phone1) AS 'Phone Number',
            LTRIM(C.car_phone2) AS 'Phone Number 2',
            LTRIM(C.car_phone3) AS 'Phone Number 3',
            C.car_lastactivity AS 'Last Activity',
            LTRIM(C.car_actg_type) AS 'Accounting Type'
     FROM carrier C WITH (NOLOCK)
          LEFT OUTER JOIN city WITH (NOLOCK) ON C.cty_code = city.cty_code
          LEFT OUTER JOIN labelfile L1 WITH (NOLOCK) ON C.car_type1 = L1.abbr AND L1.labeldefinition = 'CarType1'
          LEFT OUTER JOIN labelfile L2 WITH (NOLOCK) ON C.car_type2 = L2.abbr AND L2.labeldefinition = 'CarType2'
          LEFT OUTER JOIN labelfile L3 WITH (NOLOCK) ON C.car_type3 = L3.abbr AND L3.labeldefinition = 'CarType3'
          LEFT OUTER JOIN labelfile L4 WITH (NOLOCK) ON C.car_type4 = L4.abbr AND L4.labeldefinition = 'CarType4';
GO
GRANT SELECT ON  [dbo].[MobileCarriersView] TO [public]
GO
