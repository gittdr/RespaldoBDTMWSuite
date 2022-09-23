SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[dx_update_remarks] @ord_remark VARCHAR(254),@ord_hdrnumber INT

AS

IF(SELECT 1 FROM orderheader WITH(NOLOCK) where ord_hdrnumber = @ord_hdrnumber) <> 1
  RETURN -1
ELSE
  UPDATE orderheader 
   SET ord_remark = @ord_remark
  WHERE ord_hdrnumber = @ord_hdrnumber
 
 
 RETURN 1
 
GO
GRANT EXECUTE ON  [dbo].[dx_update_remarks] TO [public]
GO
