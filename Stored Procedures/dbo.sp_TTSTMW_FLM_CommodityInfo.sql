SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE  Procedure [dbo].[sp_TTSTMW_FLM_CommodityInfo]
As

--Author: Brent Keeton
--********************************************************************
--Purpose: Show Commodity Information in File Maintenace Reports
--********************************************************************

--Revision History: 


SELECT commodity.cmd_code AS Code, 
       commodity.cmd_name AS CommodityName, 
       commodity.cmd_class AS Class, 
       commodityclass.ccl_description AS ClassDesc, 
       Case When cmd_hazardous = 1 Then
	    'Yes'
       Else
	    'No'
       End as Hazardous
FROM   commodity INNER JOIN commodityclass ON commodity.cmd_class = commodityclass.ccl_code










GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMW_FLM_CommodityInfo] TO [public]
GO
