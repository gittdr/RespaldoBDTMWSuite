SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.pb_cattbl    Script Date: 6/1/99 11:54:37 AM ******/
create procedure [dbo].[pb_cattbl] @tblobjid int as 
select pbd_fhgt, pbd_fwgt, pbd_fitl, pbd_funl, 
pbd_fchr, pbd_fptc, pbd_ffce, 
pbh_fhgt, pbh_fwgt, pbh_fitl, pbh_funl, 
pbh_fchr, pbh_fptc, pbh_ffce, 
pbl_fhgt, pbl_fwgt, pbl_fitl, pbl_funl, 
pbl_fchr, pbl_fptc, pbl_ffce, pbt_cmnt 
from dbo.pbcattbl where pbt_tid = @tblobjid 





GO
GRANT EXECUTE ON  [dbo].[pb_cattbl] TO [public]
GO
