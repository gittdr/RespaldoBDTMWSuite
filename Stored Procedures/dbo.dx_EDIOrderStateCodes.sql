SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDIOrderStateCodes] AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDIOrderStateCodes

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

	SELECT 
		esc_code, esc_description, esc_tmwordersuspense, esc_orderplanningallowed, 
		esc_orderdispatchallowed, esc_useractionrequired 
	FROM 
		edi_orderstate

GO
GRANT EXECUTE ON  [dbo].[dx_EDIOrderStateCodes] TO [public]
GO
