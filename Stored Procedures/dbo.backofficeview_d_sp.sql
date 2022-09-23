SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[backofficeview_d_sp]
( @mode                    VARCHAR(10)
, @bov_appid               VARCHAR(20)
, @bov_type                CHAR(6)
, @bov_id                  CHAR(6)
) AS

/*
*
*
* NAME:
* dbo.backofficeview_d_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to Delete rows from backofficeview and backofficeview_temp
*
* RETURNS:
*
* NOTHING:
*
* 10/31/2012 PTS63020 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

DECLARE @tmwuser  VARCHAR(255)

EXEC gettmwuser @tmwuser OUTPUT

   IF @mode = 'MAINTAIN'
      BEGIN
         DELETE FROM backofficeview_temp
          WHERE bov_appid = @bov_appid
            AND bov_id = @bov_id
            AND bov_type = @bov_type

         DELETE FROM backofficeview
          WHERE bov_appid = @bov_appid
            AND bov_type = @bov_type
            AND bov_id = @bov_id
      END
   ELSE IF @mode = 'RESTRICT' AND @bov_id = '*ALL*'
      BEGIN
         DELETE FROM backofficeview_temp
          WHERE bov_appid = @bov_appid
            AND bov_type = @bov_type
            AND tmwuser = @tmwuser
      END
   ELSE
      BEGIN
         IF EXISTS(SELECT 1
                     FROM backofficeview_temp
                    WHERE bov_appid = @bov_appid
                      AND bov_id = @bov_id
                      AND bov_type = @bov_type
                      AND tmwuser = @tmwuser
                  )
            BEGIN
               DELETE FROM backofficeview_temp
                WHERE bov_appid = @bov_appid
                  AND bov_id = @bov_id
                  AND bov_type = @bov_type
                  AND tmwuser = @tmwuser
            END
      END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[backofficeview_d_sp] TO [public]
GO
