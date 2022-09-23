SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE   Procedure [dbo].[sp_TTSTMW_FLM_CompanyWithDirections] (@justcompanyid char(1),
                                                      @companyid varchar(255),
                                                      @moveno integer)
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show Company Directions Information in File Maintenance Reports
--********************************************************************

--Revision History: 

SELECT  @companyid = ',' + LTRIM(RTRIM(ISNULL(@companyid, ''))) + ','

If @justcompanyid = 'Y'
Begin

SELECT   company.cmp_id, 
         company.cmp_name,
         city.cty_name, 
         company.cmp_directions
FROM     company Left Join city ON (company.cmp_city = city.cty_code)
WHERE   (@companyid = ',,' OR CHARINDEX(',' + company.cmp_id + ',', @companyid) > 0)
         And
         company.cmp_directions Is Not Null
ORDER BY company.cmp_id

End

Else --User wants to see each stop on the move and the directions 
     --for each stop
Begin

SELECT   company.cmp_id, 
         company.cmp_name,
         city.cty_name, 
         company.cmp_directions
FROM     stops Left Join company ON stops.cmp_id = company.cmp_id 
               Left Join city ON company.cmp_city = city.cty_code
WHERE   (@companyid = ',,' OR CHARINDEX(',' + stops.cmp_id + ',', @companyid) > 0)
         And
        (stops.mov_number = @moveno)
ORDER BY stops.stp_mfh_sequence ASC

End










GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_CompanyWithDirections] TO [public]
GO
