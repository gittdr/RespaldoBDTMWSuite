SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[Dedicated_Count_SP] (@key int, @mode varchar (20)) 
as

DECLARE @proc_name varchar(100),
@ReturnValue int
            

IF (SELECT COUNT(1) from generalinfo where gi_name = 'DedicatedBillingCount' and gi_string1 = 'Y') > 0
BEGIN
		SELECT @proc_name = IsNull(gi_string2,'') from generalinfo where gi_name = 'DedicatedBillingCount' 

		If Len(isnull(@proc_name,''))> 0
			BEGIN	
				EXECUTE 	@proc_name
						@Key,
						@Mode,
						@ReturnValue OUTPUT	
				END

END

SELECT @ReturnValue

GO
GRANT EXECUTE ON  [dbo].[Dedicated_Count_SP] TO [public]
GO
