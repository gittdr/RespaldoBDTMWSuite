SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_standing_deduction_s]
( @p_std_number         INT         = NULL
, @p_asgn_type          VARCHAR(6)  = NULL
, @p_asgn_id            VARCHAR(8)  = NULL
, @p_sdm_itemcode       VARCHAR(6)  = NULL
) AS

/**
 *
 * NAME:
 * dbo.sp_standing_deduction_s
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for selecting rows from standing deduction table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @p_std_number        INT         --> PKey
 * @p_asgn_type         VARCHAR(6)  --> DRV=Driver;TRC=Tractor;TRL=Trailer;CAR=Carrier;TPR=ThirdParty;PTO=CoOwner;
 * @p_asgn_id           VARCHAR(8)  --> manpowerprofile.mpp_id;tractorprofile.trc_number;trailerprofile.trl_number;carrier.car_id;thirdpartyprofile.tpr_id;payto.pto_id;
 * @p_sdm_itemcode      VARCHAR(6)  --> Type
 *
 * REVISION HISTORY:
 * PTS 58141 SPN Created 06/06/12
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @Asset TABLE
   ( AssetType    CHAR(3)
   , AssetID      VARCHAR(13)
   , AssetName    VARCHAR(60)
   )

   DECLARE @lb_AnyArg BIT

   SELECT @lb_AnyArg = 0

   --************************--
   --** Validate arguments **--
   --************************--

   --****************--
   --** STD Number **--
   --****************--
   IF @p_std_number IS NOT NULL
      BEGIN
         IF NOT EXISTS (SELECT 1
                          FROM standingdeduction
                         WHERE std_number = @p_std_number
                       )
         BEGIN
            RAISERROR('Standing Deduction# not found.',16,1)
            RETURN
         END
         SELECT @lb_AnyArg = 1
      END

   --***********--
   --** Asset **--
   --***********--
   IF @p_asgn_type IS NOT NULL
      BEGIN
         IF @p_asgn_type = 'DRV'
            BEGIN
               IF @p_asgn_id IS NULL
                  BEGIN
                     RAISERROR('Driver ID Required.',16,1)
                     RETURN
                  END
               IF NOT EXISTS (SELECT 1
                                FROM manpowerprofile
                               WHERE mpp_id = @p_asgn_id
                             )
                  BEGIN
                     RAISERROR('Driver Not Found.',16,1)
                     RETURN
                  END
               SELECT @lb_AnyArg = 1
            END
         ELSE IF @p_asgn_type = 'TRC'
            BEGIN
               IF @p_asgn_id IS NULL
                  BEGIN
                     RAISERROR('Tractor ID Required.',16,1)
                     RETURN
                  END
               IF NOT EXISTS (SELECT 1
                                FROM tractorprofile
                               WHERE trc_number = @p_asgn_id
                             )
                  BEGIN
                     RAISERROR('Tractor Not Found.',16,1)
                     RETURN
                  END
               SELECT @lb_AnyArg = 1
            END
         ELSE IF @p_asgn_type = 'TRL'
            BEGIN
               IF @p_asgn_id IS NULL
                  BEGIN
                     RAISERROR('Trailer ID Required.',16,1)
                     RETURN
                  END
               IF NOT EXISTS (SELECT 1
                                FROM trailerprofile
                               WHERE trl_number = @p_asgn_id
                             )
                  BEGIN
                     RAISERROR('Trailer Not Found.',16,1)
                     RETURN
                  END
               SELECT @lb_AnyArg = 1
            END
         ELSE IF @p_asgn_type = 'CAR'
            BEGIN
               IF @p_asgn_id IS NULL
                  BEGIN
                     RAISERROR('Carrier ID Required.',16,1)
                     RETURN
                  END
               IF NOT EXISTS (SELECT 1
                                FROM carrier
                               WHERE car_id = @p_asgn_id
                             )
                  BEGIN
                     RAISERROR('Carrier Not Found.',16,1)
                     RETURN
                  END
               SELECT @lb_AnyArg = 1
            END
         ELSE IF @p_asgn_type = 'TPR'
            BEGIN
               IF @p_asgn_id IS NULL
                  BEGIN
                     RAISERROR('Third-Party ID Required.',16,1)
                     RETURN
                  END
               IF NOT EXISTS (SELECT 1
                                FROM thirdpartyprofile
                               WHERE tpr_id = @p_asgn_id
                             )
                  BEGIN
                     RAISERROR('Third-Party Not Found.',16,1)
                     RETURN
                  END
               SELECT @lb_AnyArg = 1
            END
         ELSE IF @p_asgn_type = 'PTO'
            BEGIN
               IF @p_asgn_id IS NULL
                  BEGIN
                     RAISERROR('PayTo ID Required.',16,1)
                     RETURN
                  END
               IF NOT EXISTS (SELECT 1
                                FROM payto
                               WHERE pto_id = @p_asgn_id
                             )
                  BEGIN
                     RAISERROR('PayTo Not Found.',16,1)
                     RETURN
                  END
               SELECT @lb_AnyArg = 1
            END
         ELSE
            BEGIN
               RAISERROR('Invalid Asset Type.',16,1)
               RETURN
            END
      END

   --**************--
   --** ItemCode **--
   --**************--
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
         SELECT @lb_AnyArg = 1
      END

   --***************************************--
   --** At least one argument is required **--
   --***************************************--
   IF @lb_AnyArg <> 1
      BEGIN
         RAISERROR('At least one argument is required.',16,1)
         RETURN
      END

   INSERT INTO @Asset
   ( AssetType
   , AssetID
   , AssetName
   )
   SELECT 'DRV'                        AS AssetType
        , mpp_id                       AS AssetID
        , mpp_lastfirst                AS AssetName
     FROM manpowerprofile
   UNION ALL
   SELECT 'TRC'                        AS AssetType
        , trc_number                   AS AssetID
        , trc_make + ', ' + trc_model  AS AssetName
     FROM tractorprofile
   UNION ALL
   SELECT 'TRL'                        AS AssetType
        , trl_number                   AS AssetID
        , trl_make + ', ' + trl_model  AS AssetName
     FROM trailerprofile
   UNION ALL
   SELECT 'CAR'                        AS AssetType
        , car_id                       AS AssetID
        , car_name                     AS AssetName
     FROM carrier
   UNION ALL
   SELECT 'TPR'                        AS AssetType
        , tpr_id                       AS AssetID
        , tpr_name                     AS AssetName
     FROM thirdpartyprofile
   UNION ALL
   SELECT 'PTO'                        AS AssetType
        , pto_id                       AS AssetID
        , pto_lastfirst                AS AssetName
     FROM payto

   --************--
   --** Select **--
   --************--
   SELECT q3.STD_number                                                                                                       AS STD_number
        , q3.AssetType                                                                                                        AS AssetType
        , q3.AssetID                                                                                                          AS AssetID
        , pr.AssetName                                                                                                        AS AssetName
        , q3.ItemCode                                                                                                         AS ItemCode
        , q3.Description                                                                                                      AS Description
        , q3.Priority                                                                                                         AS Priority
        , dp.PriorityName                                                                                                     AS PriorityName
        , q3.Status                                                                                                           AS Status
        , ds.StatusName                                                                                                       AS StatusName
        , (CASE WHEN q3.Due = 'N' THEN 'Company' ELSE 'Payee' END)                                                            AS Due
        , q3.MaxAmount                                                                                                        AS MaxAmount
        , (CASE WHEN q3.balance_display_mode = 0 OR q3.balance_display_mode = -1 THEN q3.PaidToDate ELSE q3.CABS_Balance END) AS Remainder
        , (CASE WHEN q3.balance_display_mode = 0 OR q3.balance_display_mode = -1 THEN q3.CABS_Balance ELSE q3.PaidToDate END) AS PaidToDate
        , q3.Deduct                                                                                                           AS Deduct
        , q3.DeductionBasis                                                                                                   AS DeductionBasis
        , db.DeductionBasisName                                                                                               AS DeductionBasisName
        , q3.DeductionTerm                                                                                                    AS DeductionTerm
        , dt.DeductionTermName                                                                                                AS DeductionTermName
        , q3.DeductionSchedule                                                                                                AS DeductionSchedule
        , q3.DeductionQty                                                                                                     AS DeductionQty
        , q3.Reduce                                                                                                           AS Reduce
        , q3.ReductionBasis                                                                                                   AS ReductionBasis
        , rb.ReductionBasisName                                                                                               AS ReductionBasisName
        , q3.ReductionTerm                                                                                                    AS ReductionTerm
        , rt.ReductionTermName                                                                                                AS ReductionTermName
        , q3.ReductionSchedule                                                                                                AS ReductionSchedule
        , q3.ReductionQty                                                                                                     AS ReductionQty
        , q3.IssueDate                                                                                                        AS IssueDate
        , q3.LastDedDate                                                                                                      AS LastDedDate
        , q3.CloseDate                                                                                                        AS CloseDate
        , q3.RefType                                                                                                          AS RefType
        , q3.RefNumber                                                                                                        AS RefNumber
     FROM (
            SELECT q2.STD_number                                                                                              AS STD_number
                 , q2.AssetType                                                                                               AS AssetType
                 , q2.AssetID                                                                                                 AS AssetID
                 , q2.ItemCode                                                                                                AS ItemCode
                 , q2.Description                                                                                             AS Description
                 , q2.Priority                                                                                                AS Priority
                 , q2.Status                                                                                                  AS Status
                 , q2.MaxAmount                                                                                               AS MaxAmount
                 , q2.CABS_Balance                                                                                            AS CABS_Balance
                 , (CASE WHEN q2.ReductionTerm = 'NOT' THEN 0
                         ELSE (CASE WHEN q2.balance_display_mode = 0 THEN q2.CABS_Balance
                                    ELSE (q2.std_startbalance - q2.std_endbalance) - q2.CABS_Balance
                               END
                              )
                    END
                   )                                                                                                          AS PaidToDate
                 , q2.Deduct                                                                                                  AS Deduct
                 , q2.DeductionBasis                                                                                          AS DeductionBasis
                 , q2.DeductionTerm                                                                                           AS DeductionTerm
                 , q2.DeductionSchedule                                                                                       AS DeductionSchedule
                 , q2.DeductionQty                                                                                            AS DeductionQty
                 , q2.Reduce                                                                                                  AS Reduce
                 , q2.ReductionBasis                                                                                          AS ReductionBasis
                 , q2.ReductionTerm                                                                                           AS ReductionTerm
                 , q2.ReductionSchedule                                                                                       AS ReductionSchedule
                 , q2.ReductionQty                                                                                            AS ReductionQty
                 , q2.IssueDate                                                                                               AS IssueDate
                 , q2.LastDedDate                                                                                             AS LastDedDate
                 , q2.CloseDate                                                                                               AS CloseDate
                 , q2.RefType                                                                                                 AS RefType
                 , q2.RefNumber                                                                                               AS RefNumber
                 , q2.balance_display_mode                                                                                    AS balance_display_mode
                 , q2.std_balance                                                                                             AS std_balance
                 , q2.std_startbalance                                                                                        AS std_startbalance
                 , q2.std_endbalance                                                                                          AS std_endbalance
                 , q2.Due                                                                                                     AS Due
              FROM
                   (
                     SELECT q1.STD_number                                                                                     AS STD_number
                          , q1.AssetType                                                                                      AS AssetType
                          , q1.AssetID                                                                                        AS AssetID
                          , q1.ItemCode                                                                                       AS ItemCode
                          , q1.Description                                                                                    AS Description
                          , q1.Priority                                                                                       AS Priority
                          , q1.Status                                                                                         AS Status
                          , q1.MaxAmount                                                                                      AS MaxAmount
                          , q1.CABS_Balance                                                                                   AS CABS_Balance
                          , q1.Deduct                                                                                         AS Deduct
                          , q1.DeductionBasis                                                                                 AS DeductionBasis
                          , q1.DeductionTerm                                                                                  AS DeductionTerm
                          , q1.DeductionSchedule                                                                              AS DeductionSchedule
                          , q1.DeductionQty                                                                                   AS DeductionQty
                          , q1.Reduce                                                                                         AS Reduce
                          , q1.ReductionBasis                                                                                 AS ReductionBasis
                          , q1.ReductionTerm                                                                                  AS ReductionTerm
                          , q1.ReductionSchedule                                                                              AS ReductionSchedule
                          , q1.ReductionQty                                                                                   AS ReductionQty
                          , q1.IssueDate                                                                                      AS IssueDate
                          , q1.LastDedDate                                                                                    AS LastDedDate
                          , q1.CloseDate                                                                                      AS CloseDate
                          , q1.RefType                                                                                        AS RefType
                          , q1.RefNumber                                                                                      AS RefNumber
                          , (CASE WHEN q1.MaxAmount = 0 THEN 0
                                  ELSE (CASE WHEN q1.Due = 'Y' THEN -1
                                             ELSE 1
                                        END
                                       )
                             END
                            )                                                                                                 AS balance_display_mode
                          , q1.std_balance                                                                                    AS std_balance
                          , q1.std_startbalance                                                                               AS std_startbalance
                          , q1.std_endbalance                                                                                 AS std_endbalance
                          , q1.Due                                                                                            AS Due
                      FROM
                           ( SELECT d.std_number                                                                              AS STD_number
                                  , d.asgn_type                                                                               AS AssetType
                                  , d.asgn_id                                                                                 AS AssetID
                                  , d.sdm_itemcode                                                                            AS ItemCode
                                  , d.std_description                                                                         AS Description
                                  , d.std_priority                                                                            AS Priority
                                  , d.std_status                                                                              AS Status
                                  , d.std_startbalance - d.std_endbalance                                                     AS MaxAmount
                                  , d.std_balance * (CASE WHEN d.std_startbalance = 0 AND d.std_endbalance = 0 THEN -1
                                                          WHEN m.sdm_minusbalance = 'N' THEN 1
                                                          ELSE -1
                                                     END
                                                    )                                                                         AS CABS_Balance
                                  , d.std_deductionrate                                                                       AS Deduct
                                  , m.sdm_deductionbasis                                                                      AS DeductionBasis
                                  , m.sdm_deductionterm                                                                       AS DeductionTerm
                                  , m.sdm_dedschedule                                                                         AS DeductionSchedule
                                  , m.sdm_deductionqty                                                                        AS DeductionQty
                                  , d.std_reductionrate                                                                       AS Reduce
                                  , m.sdm_reductionbasis                                                                      AS ReductionBasis
                                  , m.sdm_reductionterm                                                                       AS ReductionTerm
                                  , m.sdm_redschedule                                                                         AS ReductionSchedule
                                  , m.sdm_reductionqty                                                                        AS ReductionQty
                                  , d.std_issuedate                                                                           AS IssueDate
                                  , d.std_lastdeddate                                                                         AS LastDedDate
                                  , d.std_closedate                                                                           AS CloseDate
                                  , d.std_refnumtype                                                                          AS RefType
                                  , d.std_refnum                                                                              AS RefNumber
                                  , d.std_balance                                                                             AS std_balance
                                  , d.std_startbalance                                                                        AS std_startbalance
                                  , d.std_endbalance                                                                          AS std_endbalance
                                  , IsNull(m.sdm_minusbalance,'N')                                                            AS Due
                               FROM standingdeduction d
                               JOIN stdmaster m ON d.sdm_itemcode = m.sdm_itemcode
                              WHERE (d.std_number = @p_std_number OR @p_std_number IS NULL)
                                AND (d.asgn_type = @p_asgn_type OR @p_asgn_type IS NULL)
                                AND (d.asgn_id = @p_asgn_id OR @p_asgn_id IS NULL)
                                AND (d.sdm_itemcode = @p_sdm_itemcode OR @p_sdm_itemcode IS NULL)
                           ) q1
                   ) q2
          ) q3
   LEFT OUTER JOIN (SELECT abbr  AS PriorityCode
                         , name  AS PriorityName
                      FROM labelfile
                     WHERE labeldefinition = 'DeductionPriority'
                   ) dp ON q3.Priority = dp.PriorityCode
   LEFT OUTER JOIN (SELECT abbr  AS StatusCode
                         , name  AS StatusName
                      FROM labelfile
                     WHERE labeldefinition = 'DeductionStatus'
                   ) ds ON q3.Status = ds.StatusCode
   LEFT OUTER JOIN (SELECT abbr  AS DeductionBasisCode
                         , name  AS DeductionBasisName
                      FROM labelfile
                     WHERE labeldefinition = 'DeductionBasis'
                   ) db ON q3.DeductionBasis = db.DeductionBasisCode
   LEFT OUTER JOIN (SELECT abbr  AS DeductionTermCode
                         , name  AS DeductionTermName
                      FROM labelfile
                     WHERE labeldefinition = 'DeductionTerm'
                   ) dt ON q3.DeductionTerm = dt.DeductionTermCode
   LEFT OUTER JOIN (SELECT abbr  AS ReductionBasisCode
                         , name  AS ReductionBasisName
                      FROM labelfile
                     WHERE labeldefinition = 'DeductionBasis'
                   ) rb ON q3.ReductionBasis = rb.ReductionBasisCode
   LEFT OUTER JOIN (SELECT abbr  AS ReductionTermCode
                         , name  AS ReductionTermName
                      FROM labelfile
                     WHERE labeldefinition = 'DeductionTerm'
                   ) rt ON q3.ReductionTerm = rt.ReductionTermCode
   LEFT OUTER JOIN @Asset pr ON q3.AssetType = pr.AssetType
                            AND q3.AssetID = pr.AssetID


END
GO
GRANT EXECUTE ON  [dbo].[sp_standing_deduction_s] TO [public]
GO
