SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE  Procedure [dbo].[sp_TTSTMW_FLM_CityInfo]
As

--Author: Brent Keeton
--********************************************************************
--Purpose: City Information is intended to be a File Maintenace
--Report on associated Cities 
--********************************************************************

--Revision History: 


SELECT city.cty_code AS Code, 
       city.cty_name AS CityName, 
       city.cty_state AS StateAbbrev, 
       labelfile.name AS State, 
       city.cty_zip AS Zip, 
       city.cty_county AS County

FROM  city,labelfile 
where city.cty_state = labelfile.abbr
      and labeldefinition = 'state'









GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_CityInfo] TO [public]
GO
