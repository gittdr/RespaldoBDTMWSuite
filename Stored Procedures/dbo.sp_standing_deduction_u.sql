SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_standing_deduction_u]
( @p_std_number         INT
, @p_sdm_itemcode       VARCHAR(6)  = NULL
, @p_maxamount          MONEY       = NULL
, @p_remainder_or_paid  MONEY       = NULL
, @p_deductionrate      MONEY       = NULL
, @p_reductionrate      MONEY       = NULL
, @p_issuedate          DATETIME    = NULL
, @p_priority           CHAR(6)     = NULL
, @p_status             VARCHAR(6)  = NULL
, @p_closedate          DATETIME    = NULL
) AS

/**
 *
 * NAME:
 * dbo.sp_standing_deduction_u
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
 * @p_std_number        INT         --> PKey
 * @p_status            VARCHAR(6)  --> LabelFile->DeductionStatus
 * @p_sdm_itemcode      VARCHAR(6)  --> Type
 * @p_maxamount         MONEY       --> Max Amount
 * @p_remainder_or_paid MONEY       --> Remainder / Paid To Date
 * @p_deductionrate     MONEY       --> Optional: Deduct
 * @p_reductionrate     MONEY       --> Optional: Reduce
 * @p_issuedate         DATETIME    --> Optional: Issue Date
 * @p_priority          CHAR(6)     --> Optional: 1=Draw First;2=Second;3=Third;4=Fourth;5=Manual;
 *
 * REVISION HISTORY:
 * PTS 58141 SPN Created 05/31/12
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @cur_sdm_itemcode        VARCHAR(6)
   DECLARE @cur_description         VARCHAR(50)
   DECLARE @cur_priority            CHAR(6)
   DECLARE @cur_status              VARCHAR(6)
   DECLARE @cur_deductionrate       MONEY
   DECLARE @cur_reductionrate       MONEY
   DECLARE @cur_issuedate           DATETIME
   DECLARE @cur_max_amount          MONEY
   DECLARE @cur_remainder_or_paid   MONEY
   DECLARE @cur_startbalance        MONEY
   DECLARE @cur_endbalance          MONEY
   DECLARE @cur_balance             MONEY
   DECLARE @cur_sdm_minusbalance    CHAR(1)
   DECLARE @cur_sdm_reductionterm   VARCHAR(6)

   DECLARE @new_sdm_itemcode        VARCHAR(6)
   DECLARE @new_sdm_description     VARCHAR(50)
   DECLARE @new_sdm_priority        CHAR(6)
   DECLARE @new_status              VARCHAR(6)
   DECLARE @new_sdm_deductionrate   MONEY
   DECLARE @new_sdm_reductionrate   MONEY
   DECLARE @new_sdm_minusbalance    CHAR(1)
   DECLARE @new_sdm_reductionterm   VARCHAR(6)
   DECLARE @new_max_amount          MONEY
   DECLARE @new_remainder_or_paid   MONEY
   DECLARE @new_issuedate           DATETIME

   DECLARE @v_DrawnAmt              MONEY
   DECLARE @startbalance            MONEY
   DECLARE @endbalance              MONEY
   DECLARE @balance                 MONEY

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

   --*****************************************--
   --** Get current Standing Deduction info **--
   --*****************************************--
   SELECT @cur_sdm_itemcode      = d.sdm_itemcode
        , @cur_description       = d.std_description
        , @cur_priority          = d.std_priority
        , @cur_status            = d.std_status
        , @cur_deductionrate     = d.std_deductionrate
        , @cur_reductionrate     = d.std_reductionrate
        , @cur_issuedate         = d.std_issuedate
        , @cur_max_amount        = d.std_startbalance - d.std_endbalance
        , @cur_remainder_or_paid = d.std_balance * (CASE WHEN d.std_startbalance = 0 AND d.std_endbalance = 0 THEN -1
                                                         WHEN m.sdm_minusbalance = 'N' THEN 1
                                                         ELSE -1
                                                    END
                                                   )
        , @cur_startbalance      = d.std_startbalance
        , @cur_endbalance        = d.std_endbalance
        , @cur_balance           = d.std_balance
        , @cur_sdm_minusbalance  = m.sdm_minusbalance
        , @cur_sdm_reductionterm = m.sdm_reductionterm
     FROM standingdeduction d
     JOIN stdmaster m ON d.sdm_itemcode = m.sdm_itemcode
    WHERE d.std_number = @p_std_number

   --**********************************************************--
   --** Changing ItemCode?  *It will change other properties **--
   --**********************************************************--
   IF @p_sdm_itemcode IS NOT NULL
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM stdmaster
                         WHERE sdm_itemcode = @p_sdm_itemcode
                       )
            BEGIN
               RAISERROR('Invalid Standing Deduction ItemCode.',16,1)
               RETURN
            END
         ELSE
            BEGIN
               --Get Defaults for the NEW @p_sdm_itemcode
               SELECT @new_sdm_itemcode      = @p_sdm_itemcode
                    , @new_sdm_description   = sdm_description
                    , @new_sdm_priority      = sdm_priority
                    , @new_sdm_deductionrate = sdm_deductionrate
                    , @new_sdm_reductionrate = sdm_reductionrate
                    , @new_sdm_minusbalance  = sdm_minusbalance
                    , @new_sdm_reductionterm = sdm_reductionterm
                 FROM stdmaster
                WHERE sdm_itemcode = @p_sdm_itemcode
            END
      END
   ELSE
      BEGIN
         SELECT @new_sdm_itemcode      = @cur_sdm_itemcode
              , @new_sdm_description   = @cur_description
              , @new_sdm_priority      = @cur_priority
              , @new_sdm_deductionrate = @cur_deductionrate
              , @new_sdm_reductionrate = @cur_reductionrate
              , @new_sdm_minusbalance  = @cur_sdm_minusbalance
              , @new_sdm_reductionterm = @cur_sdm_reductionterm
      END

   --**************************--
   --** Changing Max Amount? **--
   --**************************--
   IF @p_maxamount IS NOT NULL
      SELECT @new_max_amount = @p_maxamount
   ELSE
      SELECT @new_max_amount = @cur_max_amount

   --*********************************--
   --** Changing remainder_or_paid? **--
   --*********************************--
   IF @p_remainder_or_paid IS NOT NULL
      SELECT @new_remainder_or_paid = @p_remainder_or_paid
   ELSE
      SELECT @new_remainder_or_paid = @cur_remainder_or_paid

   --**************************--
   --** Changing Issue Date? **--
   --**************************--
   IF @p_issuedate IS NOT NULL
      SELECT @new_issuedate = @p_issuedate
   ELSE
      SELECT @new_issuedate = @cur_issuedate

   --************************--
   --** Changing Priority? **--
   --************************--
   IF @p_priority IS NOT NULL
      IF @p_priority NOT IN ('1','2','3','4','5')
         BEGIN
            --Warning and Rejecting passed in value with Default from master
            RAISERROR('Bad Priority passed in thus ignoring this priority.',10,1) WITH NOWAIT
         END
      ELSE
         SELECT @new_sdm_priority = @p_priority

   --**********************--
   --** Changing Deduct? **--
   --**********************--
   IF @p_deductionrate IS NOT NULL
      SELECT @new_sdm_deductionrate = @p_deductionrate

   --**********************--
   --** Changing Reduce? **--
   --**********************--
   IF @p_reductionrate IS NOT NULL
      SELECT @new_sdm_reductionrate = @p_reductionrate


   --*********************--
   --** Data Validation **--
   --*********************--
   IF @new_sdm_reductionterm <> 'NOT' AND @new_max_amount = 0
   BEGIN
      RAISERROR('Your choice of reduction terms requires you to enter a <<Max Amount>>.',16,1)
      RETURN
   END

   --********************************************************--
   --** Warning for incorrect Max Amount vs Deduction Rate **--
   --********************************************************--
   IF @new_sdm_reductionterm <> 'NOT' AND @new_max_amount < @new_sdm_reductionrate
      RAISERROR('The <<Max Amount>> is less than the Deduction Amount. Proceeding anyway.',10,1) WITH NOWAIT

   --*****************--
   --** Computation **--
   --*****************--
   --STD Start and End Balance
   SELECT @v_DrawnAmt = @cur_startbalance - @cur_balance
   IF @new_sdm_minusbalance = 'Y'
      BEGIN
         SELECT @startbalance = 0
         SELECT @endbalance = -1 * @new_max_amount
      END
   ELSE
      BEGIN
         SELECT @startbalance = @new_max_amount
         SELECT @endbalance = 0
      END

   --STD Balance
   SELECT @balance = @startbalance - @v_DrawnAmt

   --**********************************************************************--
   --** Remainder/Paid To Date could cause warning or revise STD Balance **--
   --**********************************************************************--
   IF @new_remainder_or_paid IS NOT NULL
      BEGIN
         IF @new_remainder_or_paid < 0 OR (@new_remainder_or_paid > @new_max_amount AND @new_max_amount > 0)
            RAISERROR('Balance out of range.  Balance must be greater than zero and less than the amount issued.',10,1) WITH NOWAIT
         ELSE
            BEGIN
               If @new_sdm_minusbalance = 'Y'
                  SELECT @balance = -1 * @new_remainder_or_paid
               Else
                  SELECT @balance = @new_remainder_or_paid
            END
      END

   --************--
   --** Status **--
   --************--
   IF @p_status IS NOT NULL
      BEGIN
         IF @cur_status = 'INI' OR @cur_status = 'CLD'
            BEGIN
               RAISERROR('Status cannot be changed from Initial/Closed.',16,1)
               RETURN
            END
         ELSE
            BEGIN
               IF NOT EXISTS (SELECT 1
                                FROM labelfile
                               WHERE labeldefinition = 'DeductionStatus'
                                 AND abbr = @p_status
                             )
                  BEGIN
                     RAISERROR('Invalid Status.',16,1)
                     RETURN
                  END
               ELSE
                  SELECT @new_status = @p_status
            END
      END
   ELSE
      SELECT @new_status = @cur_status

   --************--
   --** Update **--
   --************--
   UPDATE standingdeduction
      SET sdm_itemcode        = @new_sdm_itemcode
        , std_description     = @new_sdm_description
        , std_priority        = @new_sdm_priority
        , std_status          = @new_status
        , std_deductionrate   = @new_sdm_deductionrate
        , std_reductionrate   = @new_sdm_reductionrate
        , std_issuedate       = @new_issuedate
        , std_lastdeddate     = @new_issuedate
        , std_lastreddate     = @new_issuedate
        , std_lastcompdate    = @new_issuedate
        , std_lastcalcdate    = @new_issuedate
        , std_balance         = @balance
        , std_startbalance    = @startbalance
        , std_endbalance      = @endbalance
    WHERE std_number = @p_std_number

   IF @p_closedate IS NOT NULL
      UPDATE standingdeduction
         SET std_closedate = @p_closedate
       WHERE std_number = @p_std_number

END
GO
GRANT EXECUTE ON  [dbo].[sp_standing_deduction_u] TO [public]
GO
