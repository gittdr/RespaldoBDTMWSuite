SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[set_temp_report_arguments_sp]
      ( @temp_report_name           VARCHAR(200)
      , @temp_report_argument_name  VARCHAR(200)
      , @temp_report_argument_value VARCHAR(200)
      )
AS

/*
*
*
* NAME:
* dbo.set_temp_report_arguments_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to set parameter value into temp_report_arguments table
*
* RETURNS:
*
* NOTHING:
*
* 04/12/2011 PTS56599/PTS51912 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   BEGIN TRY
      DELETE FROM temp_report_arguments
       WHERE temp_report_name = @temp_report_name
         AND temp_report_argument_name = @temp_report_argument_name
         --BEGIN PTS 62378 SPN
         AND current_session_id = @@SPID
         --END PTS 62378 SPN
   END TRY
   BEGIN CATCH
     SELECT @temp_report_argument_value = @temp_report_argument_value
   END CATCH

   INSERT INTO temp_report_arguments
   ( temp_report_name
   , temp_report_argument_name
   , temp_report_argument_value
   )
   VALUES
   ( @temp_report_name
   , @temp_report_argument_name
   , @temp_report_argument_value
   )

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[set_temp_report_arguments_sp] TO [public]
GO
