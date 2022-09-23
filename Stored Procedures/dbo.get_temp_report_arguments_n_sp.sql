SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_temp_report_arguments_n_sp]
      ( @temp_report_name           VARCHAR(200)
      , @temp_report_argument_name  VARCHAR(200)
      , @temp_report_argument_value MONEY   OUTPUT
      , @default_value              MONEY
      )
AS

/*
*
*
* NAME:
* dbo.get_temp_report_arguments_n_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to return parameter value from temp_report_arguments table
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

   DECLARE @debug_ind CHAR(1)
   DECLARE @temp_report_argument_value_char VARCHAR(200)
   SELECT @debug_ind = 'N'
   
   SELECT @temp_report_argument_value_char = temp_report_argument_value
     FROM temp_report_arguments
    WHERE current_session_id = @@SPID
      AND temp_report_name = @temp_report_name
      AND temp_report_argument_name = @temp_report_argument_name
   If @temp_report_argument_value_char IS NULL
      SELECT @temp_report_argument_value = @default_value
   Else
      SELECT @temp_report_argument_value = convert(money,@temp_report_argument_value_char)

   If @debug_ind = 'Y'
      Print @temp_report_argument_name + ' - ' + convert(varchar,@temp_report_argument_value)

   RETURN
   
END
GO
GRANT EXECUTE ON  [dbo].[get_temp_report_arguments_n_sp] TO [public]
GO
