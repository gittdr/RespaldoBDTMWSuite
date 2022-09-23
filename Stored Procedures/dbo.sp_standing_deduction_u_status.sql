SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_standing_deduction_u_status]
( @p_std_number   INT
, @action         CHAR(1)
, @p_closedate    DATETIME
) AS

/**
 *
 * NAME:
 * dbo.sp_standing_deduction_u_status
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for updating standing deduction table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @p_std_number  INT         --> PKey
 * @action        CHAR(1)     --> O=Open;C=Close
 *
 * REVISION HISTORY:
 * PTS 58141 SPN Created 05/31/12
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @cur_status  VARCHAR(6)
   DECLARE @new_status  VARCHAR(6)

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

   --************--
   --** Action **--
   --************--
   IF @action IS NULL OR @action NOT IN ('O','C')
      BEGIN
         RAISERROR('Standing Deduction can be (O)pened or (C)losed.',16,1)
         RETURN
      END

   --*****************************************--
   --** Get current Standing Deduction info **--
   --*****************************************--
   SELECT @cur_status = std_status
     FROM standingdeduction
    WHERE std_number = @p_std_number

   --*********************--
   --** Data Validation **--
   --*********************--

   --************--
   --** Status **--
   --************--
   IF @action = 'O'
      BEGIN
         IF @cur_status = 'CLD'
            SELECT @new_status = 'DRN'
         ELSE
            BEGIN
               RAISERROR('The Standing Deduction cannot be reopened because it is not closed.',16,1)
               RETURN
            END
      END
   ELSE IF @action = 'C'
      BEGIN
         IF @cur_status = 'CLD'
            BEGIN
               RAISERROR('The Standing Deduction is already closed.',16,1)
               RETURN
            END
               SELECT @new_status = 'CLD'
      END

   --************--
   --** Update **--
   --************--
   UPDATE standingdeduction
      SET std_status = @new_status
    WHERE std_number = @p_std_number

   IF @p_closedate IS NOT NULL
      UPDATE standingdeduction
         SET std_closedate = @p_closedate
       WHERE std_number = @p_std_number

END
GO
GRANT EXECUTE ON  [dbo].[sp_standing_deduction_u_status] TO [public]
GO
