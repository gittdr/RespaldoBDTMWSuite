SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWageLog_d_sp]
( @smwlh_id INT
, @smwld_id INT
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWageLog_d_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to delete rows from stateminimumwagelog_hdr and stateminimumwagelog_dtl
*
* RETURNS:
*
* NOTHING:
*
* 08/15/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   --Data Validation
   IF @smwlh_id IS NULL OR @smwlh_id <= 0
      BEGIN
         RAISERROR('Log Header ID is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM stateminimumwagelog_hdr
                   WHERE smwlh_id = @smwlh_id
                 )
      BEGIN
         RAISERROR('Log Header ID is not found',16,1)
         RETURN
      END

   IF @smwld_id IS NULL OR @smwld_id <= 0
      BEGIN
         RAISERROR('Log Detail ID is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM stateminimumwagelog_dtl
                   WHERE smwld_id = @smwld_id
                 )
      BEGIN
         RAISERROR('Log Detail ID is not found',16,1)
         RETURN
      END

   --Delete stateminimumwagelog_dtl
   BEGIN
      DELETE FROM stateminimumwagelog_dtl
       WHERE smwld_id = @smwld_id
   END

   --Delete stateminimumwagelog_hdr (if the last detail is deleted)
   IF NOT EXISTS (SELECT 1
                    FROM stateminimumwagelog_dtl
                   WHERE smwlh_id = @smwlh_id
                 )
      BEGIN
         DELETE FROM stateminimumwagelog_hdr
          WHERE smwlh_id = @smwlh_id
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWageLog_d_sp] TO [public]
GO
