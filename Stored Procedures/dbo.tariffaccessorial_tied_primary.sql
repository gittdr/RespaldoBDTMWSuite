SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[tariffaccessorial_tied_primary]
               ( @retrieveby       varchar(20),
                 @rate_number      int,
                 @new_rate         int )  AS


/**
 * 
 * NAME:
 * dbo.tariffaccessorial_tied_primary
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Created for PTS 38807
 * Proc Given a secondary rate#, returns all primary that has the secondary rate#.
 * Returns result set for two new dwo:  d_bill_tar_tied_to_primary and d_stl_tar_tied_to_primary
 
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * 001 - @retrieveby       varchar(20)
 * 002 - @rate_number      int
 * 003 - @new_rate         int
 * 
 * REVISION HISTORY:
 * Created PTS 38807 JDSwindell 10-23-2007
*/


DECLARE @new_trk_number int


    SELECT @new_trk_number = MIN(trk_number)
    FROM   tariffkey
    WHERE  tar_number = @new_rate


   IF (@retrieveby = 'BILL' )
	   Begin
		  SELECT distinct k1.tar_number 'tar_number', k2.tar_number 'sec_tar_number', @new_trk_number 'trk_number'
			  FROM tariffaccessorial a, tariffkey k2, tariffkey k1
			 WHERE a.trk_number = k2.trk_number
			 and a.tar_number = k1.tar_number
			   AND k1.trk_enddate >= getdate()
			   AND k1.trk_primary = 'Y'
			   AND k2.tar_number = @rate_number
		  ORDER BY k1.tar_number
	   End
   ELSE
   -- (settlements)

	   Begin	

		  SELECT distinct k1.tar_number 'tar_number', k2.tar_number 'sec_tar_number', @new_trk_number 'trk_number'
			  FROM tariffaccessorialstl a, tariffkey k2, tariffkey k1
			 WHERE a.trk_number = k2.trk_number
			   AND a.tar_number = k1.tar_number
			   AND k1.trk_enddate >= getdate()
			   AND k1.trk_primary = 'Y'
			   AND k2.tar_number = @rate_number
		  ORDER BY k1.tar_number
		End
	
	
set nocount off
return



GO
GRANT EXECUTE ON  [dbo].[tariffaccessorial_tied_primary] TO [public]
GO
