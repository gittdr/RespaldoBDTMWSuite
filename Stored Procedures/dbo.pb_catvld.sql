SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.pb_catvld    Script Date: 6/1/99 11:54:37 AM ******/
create procedure [dbo].[pb_catvld] as 
select pbv_name, pbv_vald, pbv_type, pbv_cntr, pbv_msg 
from dbo.pbcatvld





GO
GRANT EXECUTE ON  [dbo].[pb_catvld] TO [public]
GO
