SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_tripstat_update_sp    Script Date: 6/1/99 11:54:12 AM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_tripstat_update_sp](@v_legnumber int, 
                                        @v_dispatchstatus VarChar(12),
					@v_triptype VarChar(12))
					
       
                                     
                                 

AS

BEGIN
--Update legheader information       
update legheader
   set lgh_type1 = @v_triptype,
       lgh_outstatus = @v_dispatchstatus

 where lgh_number = @v_legnumber

END

GO
GRANT EXECUTE ON  [dbo].[d_hddwn_tripstat_update_sp] TO [public]
GO
