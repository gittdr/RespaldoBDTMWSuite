SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_standing_deduction_i]
( @p_asgn_type          VARCHAR(6)
, @p_asgn_id            VARCHAR(8)
, @p_sdm_itemcode       VARCHAR(6)
, @p_maxamount          MONEY
, @p_remainder_or_paid  MONEY
, @p_deductionrate      MONEY       = NULL
, @p_reductionrate      MONEY       = NULL
, @p_issuedate          DATETIME    = NULL
, @p_priority           CHAR(6)     = NULL
) AS

/**
 *
 * NAME:
 * dbo.sp_standing_deduction_i
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for inserting into standing deduction table
 *
 * RETURNS:
 *
 * @std_number
 *
 * PARAMETERS:
 * @p_asgn_type         VARCHAR(6)  --> DRV=Driver;TRC=Tractor;TRL=Trailer;CAR=Carrier;TPR=ThirdParty;PTO=CoOwner;
 * @p_asgn_id           VARCHAR(8)  --> manpowerprofile.mpp_id;tractorprofile.trc_number;trailerprofile.trl_number;carrier.car_id;thirdpartyprofile.tpr_id;payto.pto_id;
 * @p_sdm_itemcode      VARCHAR(6)  --> Type
 * @p_maxamount         MONEY       --> Max Amount
 * @p_remainder_or_paid MONEY       --> Remainder / Paid To Date
 * @p_deductionrate     MONEY       --> Optional: Deduct
 * @p_reductionrate     MONEY       --> Optional: Reduce
 * @p_issuedate         DATETIME    --> Optional: Issue Date
 * @p_priority          CHAR(6)     --> Optional: 1=Draw First;2=Second;3=Third;4=Fourth;5=Manual;
 *
 * REVISION HISTORY:
 * PTS 58141 SPN Created 05/24/12
 * PTS 65428 SPN Returns @std_number / -1 when errors
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @std_number        INT
   DECLARE @status            VARCHAR(6)
   DECLARE @issuedate         DATETIME
   DECLARE @closedate         DATETIME
   DECLARE @sdm_description   VARCHAR(50)
   DECLARE @sdm_priority      CHAR(6)
   DECLARE @sdm_minusbalance  CHAR(1)
   DECLARE @sdm_deductionrate MONEY
   DECLARE @sdm_reductionrate MONEY
   DECLARE @sdm_reductionterm VARCHAR(6)
   DECLARE @startbalance      MONEY
   DECLARE @endbalance        MONEY
   DECLARE @balance           MONEY

   --************************--
   --** Validate arguments **--
   --************************--

   --***********--
   --** Asset **--
   --***********--
   IF @p_asgn_type = 'DRV'
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM manpowerprofile
                         WHERE mpp_id = @p_asgn_id
                       )
            BEGIN
               RAISERROR('Driver Not Found.',16,1)
               RETURN -1
            END
      END
   ELSE IF @p_asgn_type = 'TRC'
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM tractorprofile
                         WHERE trc_number = @p_asgn_id
                       )
            BEGIN
               RAISERROR('Tractor Not Found.',16,1)
               RETURN -1
            END
      END
   ELSE IF @p_asgn_type = 'TRL'
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM trailerprofile
                         WHERE trl_number = @p_asgn_id
                       )
            BEGIN
               RAISERROR('Trailer Not Found.',16,1)
               RETURN -1
            END
      END
   ELSE IF @p_asgn_type = 'CAR'
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM carrier
                         WHERE car_id = @p_asgn_id
                       )
            BEGIN
               RAISERROR('Carrier Not Found.',16,1)
               RETURN -1
            END
      END
   ELSE IF @p_asgn_type = 'TPR'
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM thirdpartyprofile
                         WHERE tpr_id = @p_asgn_id
                       )
            BEGIN
               RAISERROR('Third-Party Not Found.',16,1)
               RETURN -1
            END
      END
   ELSE IF @p_asgn_type = 'PTO'
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM payto
                         WHERE pto_id = @p_asgn_id
                       )
            BEGIN
               RAISERROR('PayTo Not Found.',16,1)
               RETURN -1
            END
      END
   ELSE
      BEGIN
         RAISERROR('Invalid Asset Type.',16,1)
         RETURN -1
      END

   --**************--
   --** ItemCode **--
   --**************--
   IF NOT EXISTS (SELECT 1
                    FROM stdmaster
                   WHERE sdm_itemcode = @p_sdm_itemcode
                 )
      BEGIN
         RAISERROR('Invalid Standing Deduction ItemCode.',16,1)
         RETURN -1
      END

   --****************--
   --** Max Amount **--
   --****************--
   IF @p_maxamount IS NULL
      SELECT @p_maxamount = 0

   --****************--
   --** Issue Date **--
   --****************--
   IF @p_issuedate IS NULL
      SELECT @p_issuedate = DATEADD(dd, DATEDIFF(dd, 0, GetDate()), 0)

   --****************************--
   --** Initialize some values **--
   --****************************--
   SELECT @status    = 'INI'
        , @issuedate = @p_issuedate
        , @closedate = Convert(DATETIME,'2049-12-31 23:59')

   --***************************************--
   --** Get Defaults for the SDM_ITEMCODE **--
   --***************************************--
   SELECT @sdm_description    = sdm_description
        , @sdm_priority       = sdm_priority
        , @sdm_minusbalance   = sdm_minusbalance
        , @sdm_deductionrate  = sdm_deductionrate
        , @sdm_reductionrate  = sdm_reductionrate
        , @sdm_reductionterm  = sdm_reductionterm
     FROM stdmaster
    WHERE sdm_itemcode = @p_sdm_itemcode

   --*********************--
   --** Data Validation **--
   --*********************--
   IF @sdm_reductionterm <> 'NOT' AND @p_maxamount = 0
   BEGIN
      RAISERROR('Your choice of reduction terms requires you to enter a <<Max Amount>>.',16,1)
      RETURN -1
   END

   --********************************************************--
   --** Warning for incorrect Max Amount vs Deduction Rate **--
   --********************************************************--
   IF @sdm_reductionterm <> 'NOT' AND @p_maxamount < @sdm_deductionrate
      RAISERROR('The <<Max Amount>> is less than the Deduction Amount. Proceeding anyway.',10,1) WITH NOWAIT

   --*************************************************************--
   --** Overwrite defaults with args when passed-in a valid one **--
   --*************************************************************--

   --**************--
   --** Priority **--
   --**************--
   IF @p_priority IS NOT NULL
      IF @p_priority NOT IN ('1','2','3','4','5')
         --Warning and Rejecting passed in value with Default from master
         RAISERROR('Bad Priority passed in thus using one from Standing Deduction Master.',10,1) WITH NOWAIT
      ELSE
         SELECT @sdm_priority = @p_priority

   --************--
   --** Deduct **--
   --************--
   IF @p_deductionrate IS NOT NULL
      SELECT @sdm_deductionrate = @p_deductionrate

   --************--
   --** Reduce **--
   --************--
   IF @p_reductionrate IS NOT NULL
      SELECT @sdm_reductionrate = @p_reductionrate

   --*****************--
   --** Computation **--
   --*****************--
   --STD Start and End Balance
   IF @sdm_minusbalance = 'Y'
      BEGIN
         SELECT @startbalance = 0
         SELECT @endbalance = -1 * @p_maxamount
      END
   ELSE
      BEGIN
         SELECT @startbalance = @p_maxamount
         SELECT @endbalance = 0
      END

   --STD Balance
   SELECT @balance = @startbalance

   --**********************************************************************--
   --** Remainder/Paid To Date could cause warning or revise STD Balance **--
   --**********************************************************************--
   IF @p_remainder_or_paid IS NOT NULL
      BEGIN
         IF @p_remainder_or_paid < 0 OR (@p_remainder_or_paid > @p_maxamount AND @p_maxamount > 0)
            RAISERROR('Balance out of range.  Balance must be greater than zero and less than the amount issued.',10,1) WITH NOWAIT
         ELSE
            BEGIN
               If @sdm_minusbalance = 'Y'
                  SELECT @balance = -1 * @p_remainder_or_paid
               Else
                  SELECT @balance = @p_remainder_or_paid
            END
      END

   --************--
   --** Insert **--
   --************--
   EXEC @std_number = getsystemnumber 'STDNUM', ''
   INSERT INTO standingdeduction
   ( std_number
   , sdm_itemcode
   , std_description
   , asgn_type
   , asgn_id
   , std_priority
   , std_status
   , std_deductionrate
   , std_reductionrate
   , std_issuedate
   , std_lastdeddate
   , std_lastreddate
   , std_lastcompdate
   , std_lastcalcdate
   , std_closedate
   , std_balance
   , std_startbalance
   , std_endbalance
   , std_lastdedqty
   , std_lastredqty
   , std_lastcompqty
   , std_lastcalcqty
   , std_refnumtype
   )
   VALUES
   ( @std_number
   , @p_sdm_itemcode
   , @sdm_description
   , @p_asgn_type
   , @p_asgn_id
   , @sdm_priority
   , @status
   , @sdm_deductionrate
   , @sdm_reductionrate
   , @issuedate
   , @issuedate
   , @issuedate
   , @issuedate
   , @issuedate
   , @closedate
   , @balance
   , @startbalance
   , @endbalance
   , 0
   , 0
   , 0
   , 0
   , 'UNK'
   )

   RETURN @std_number

END
GO
GRANT EXECUTE ON  [dbo].[sp_standing_deduction_i] TO [public]
GO
