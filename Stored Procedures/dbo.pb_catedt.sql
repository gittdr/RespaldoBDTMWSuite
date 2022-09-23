SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.pb_catedt    Script Date: 6/1/99 11:54:37 AM ******/
create procedure [dbo].[pb_catedt] as 
select pbe_name, pbe_edit, pbe_type, pbe_cntr, pbe_work, pbe_seqn, pbe_flag 
from dbo.pbcatedt order by pbe_name, pbe_seqn





GO
GRANT EXECUTE ON  [dbo].[pb_catedt] TO [public]
GO
