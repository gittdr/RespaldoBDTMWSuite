SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC	[dbo].[d_commodity_compatibility] 
AS

/************************************************************************************
 NAME:	          d_commodity_compatibility
 DOS NAME:	      tmwsp_d_commodity_compatibility.sql
 TYPE:		      stored procedure
 DATABASE:	      TMW
 PURPOSE:	      Retrieve the information in the commodity compatibility table
 DEPENDANCIES:

REVISION LOG

DATE		  WHO	   REASON
----		  ---	   ------
27-Nov-02     TJD      Created.  	


exec d_commodity_compatibility 

*************************************************************************************/

select cc_id,
       cc_cmd_code_1,
       cc_cmd_code_2,
       cc_created_by,
       cc_createdate,
       cc_updated_by,
       cc_updatedate
from compatible_commodities





GO
GRANT EXECUTE ON  [dbo].[d_commodity_compatibility] TO [public]
GO
