SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_standing_deduction_d]
( @p_std_number         INT
) AS

/**
 *
 * NAME:
 * dbo.sp_standing_deduction_d
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for Deleting from standing deduction table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @p_std_number        INT         --> PKey
 *
 * REVISION HISTORY:
 * PTS 58141 SPN Created 06/11/12
 *
 **/

SET NOCOUNT ON

BEGIN

   --************************--
   --** Validate arguments **--
   --************************--

   --****************--
   --** STD Number **--
   --****************--
   IF @p_std_number IS NULL OR @p_std_number <= 0
      BEGIN
         RAISERROR('Invalid Standing Deduction.',16,1)
         RETURN
      END
   ELSE
      IF NOT EXISTS (SELECT 1
                       FROM standingdeduction
                      WHERE std_number = @p_std_number
                    )
      BEGIN
         RAISERROR('Standing Deduction# not found.',16,1)
         RETURN
      END

   IF EXISTS (SELECT TOP 1 pyd_number
                FROM paydetail
               WHERE std_number = @p_std_number
             )
      BEGIN
         RAISERROR('Standing Deduction is used in Settlement and cannot be deleted.',16,1)
         RETURN
      END

   --************--
   --** Delete **--
   --************--
   DELETE FROM standingdeduction
    WHERE std_number = @p_std_number

END
GO
GRANT EXECUTE ON  [dbo].[sp_standing_deduction_d] TO [public]
GO
