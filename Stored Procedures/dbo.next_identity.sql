SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[next_identity]  @table_name  varchar(40) , @identity integer  OUTPUT as
 select @identity = ident_incr(@table_name)

GO
GRANT EXECUTE ON  [dbo].[next_identity] TO [public]
GO
