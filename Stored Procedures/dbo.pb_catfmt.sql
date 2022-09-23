SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.pb_catfmt    Script Date: 6/1/99 11:54:37 AM ******/
create procedure [dbo].[pb_catfmt] as 
select pbf_name, pbf_frmt, pbf_type, pbf_cntr 
from dbo.pbcatfmt





GO
GRANT EXECUTE ON  [dbo].[pb_catfmt] TO [public]
GO
