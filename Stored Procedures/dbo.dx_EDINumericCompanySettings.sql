SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDINumericCompanySettings] @p_OrderHeaderNumber varchar(50)

AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDINumericCompanySettings

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

DECLARE @v_ordhdr int,@v_tpid varchar(20)

select @v_ordhdr = ord_hdrnumber
     , @v_tpid = ord_editradingpartner 
  from orderheader
 where ord_number = @p_OrderHeaderNumber
 
 
 if isnull(@v_ordhdr, 0) = 0 return
 if isnull(@v_tpid,'') = '' return
 
 SELECT dx_xrefkey
 FROM   dx_xref
 WHERE dx_entityname = 'AutonumericCompanyID'
 	and dx_entitytype = 'TPSettings'
 	and dx_importid = 'dx_204'
	and dx_trpid = @v_tpid
	
GO
GRANT EXECUTE ON  [dbo].[dx_EDINumericCompanySettings] TO [public]
GO
