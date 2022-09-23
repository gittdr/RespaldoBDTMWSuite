SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetCarrierCSAStatus]
( @CarrierCSA_category     VARCHAR(30)
, @dotNum                  VARCHAR(15) = null
, @docket				   VARCHAR(15) = null	
) RETURNS INT

AS
/**
 *
 * NAME:
 * dbo.fn_GetCarrierCSAStatus
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function Procedure returns Carrier CSA Status
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @CarrierCSA_category   VARCHAR(30)
 * 002 @docket                VARCHAR(15)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 02/19/2013 - Initial Version Created
 * PTS 72555 SPN 10/01/2013 - Brought the SP into CarrierCSA from TMWSuite; Reference to GI removed.
 *
 **/

BEGIN

   DECLARE @li_CarrierCsaStatus INT

   --Settings
   DECLARE @is_authority                                    CHAR(1)

   DECLARE @is_insurance                                    CHAR(1)

   DECLARE @is_safetysms                                    CHAR(1)
   DECLARE @is_safetysms_Score_X_Factor                     CHAR(1)
   DECLARE @idc_safetysms_Satisfactory_Yellow_Threshold     DECIMAL(15,4)
   DECLARE @idc_safetysms_Satisfactory_Red_Threshold        DECIMAL(15,4)
   DECLARE @idc_safetysms_Conditional_Yellow_Threshold      DECIMAL(15,4)
   DECLARE @idc_safetysms_Conditional_Red_Threshold         DECIMAL(15,4)
   DECLARE @idc_safetysms_Unsatisfactory_Yellow_Threshold   DECIMAL(15,4)
   DECLARE @idc_safetysms_Unsatisfactory_Red_Threshold      DECIMAL(15,4)
   DECLARE @idc_safetysms_Unknown_Yellow_Threshold          DECIMAL(15,4)
   DECLARE @idc_safetysms_Unknown_Red_Threshold             DECIMAL(15,4)

   DECLARE @is_safetyrating                                 CHAR(1)

   DECLARE @is_sms                                          CHAR(1)
   DECLARE @is_sms_Overall_Score_X_Factor                   CHAR(1)
   DECLARE @idc_sms_Overall_Yellow_Threshold                DECIMAL(15,4)
   DECLARE @idc_sms_Overall_Red_Threshold                   DECIMAL(15,4)

   DECLARE @idc_sms_Unsafe_Threshold                        DECIMAL(15,4)
   DECLARE @idc_sms_Unsafe_Factor_Overall                   DECIMAL(15,4)

   DECLARE @idc_sms_HOS_Threshold                           DECIMAL(15,4)
   DECLARE @idc_sms_HOS_Factor_Overall                      DECIMAL(15,4)

   DECLARE @idc_sms_Fitness_Threshold                       DECIMAL(15,4)
   DECLARE @idc_sms_Fitness_Factor_Overall                  DECIMAL(15,4)

   DECLARE @idc_sms_CSA_Threshold                           DECIMAL(15,4)
   DECLARE @idc_sms_CSA_Factor_Overall                      DECIMAL(15,4)

   DECLARE @idc_sms_Vehicle_Threshold                       DECIMAL(15,4)
   DECLARE @idc_sms_Vehicle_Factor_Overall                  DECIMAL(15,4)

   --Current Values
   DECLARE @cas_authority_common_status                     CHAR(1)
   DECLARE @cas_authority_contract_status                   CHAR(1)
   DECLARE @cas_authority_common_revocation_pending         CHAR(1)
   DECLARE @cas_authority_contract_revocation_pending       CHAR(1)

   DECLARE @cas_insurance_cargo_required                    CHAR(1)
   DECLARE @cas_insurance_cargo_filed                       CHAR(1)
   DECLARE @cas_insurance_bipd_required                     INT
   DECLARE @cas_insurance_bipd_filed                        INT

   DECLARE @cas_safety_rating                               CHAR(1)

   DECLARE @sms_unsafe_prcnt                                DECIMAL(15,4)
   DECLARE @sms_fatig_prcnt                                 DECIMAL(15,4)
   DECLARE @sms_fit_prcnt                                   DECIMAL(15,4)
   DECLARE @sms_cntrl_prcnt                                 DECIMAL(15,4)
   DECLARE @sms_veh_prcnt                                   DECIMAL(15,4)

   --Variables
   DECLARE @li_auth_status                                  INT
   DECLARE @li_auth_revoke                                  INT
   DECLARE @ii_authority                                    INT

   DECLARE @li_ins_cargo                                   INT
   DECLARE @li_ins_liability                                INT
   DECLARE @ii_insurance                                    INT

   DECLARE @ii_safety_rating                                INT
   DECLARE @ii_sms                                          INT
   DECLARE @ii_safetysms                                    INT

   DECLARE @ii_sms_unsafe                                   INT
   DECLARE @ii_sms_hos                                      INT
   DECLARE @ii_sms_fitness                                  INT
   DECLARE @ii_sms_csa                                      INT
   DECLARE @ii_sms_vehicle                                  INT

   DECLARE @ldc_sms_Unsafe_Factor                           DECIMAL(15,4)
   DECLARE @ldc_sms_Hos_Factor                              DECIMAL(15,4)
   DECLARE @ldc_sms_Fitness_Factor                          DECIMAL(15,4)
   DECLARE @ldc_sms_CSA_Factor                              DECIMAL(15,4)
   DECLARE @ldc_sms_Vehicle_Factor                          DECIMAL(15,4)

   DECLARE @ldc_safetysms                                   DECIMAL(15,4)
   DECLARE @ldc_sms_overall                                 DECIMAL(15,4)

   DECLARE @TEMP TABLE(Scores INT)

   --BEGIN ***Settings***
   SELECT @is_safetysms_Score_X_Factor = 'N'
        , @idc_safetysms_Satisfactory_Yellow_Threshold = 10
        , @idc_safetysms_Satisfactory_Red_Threshold = 10
        , @idc_safetysms_Conditional_Yellow_Threshold = 10
        , @idc_safetysms_Conditional_Red_Threshold = 10
        , @idc_safetysms_Unsatisfactory_Yellow_Threshold = 10
        , @idc_safetysms_Unsatisfactory_Red_Threshold = 10
        , @idc_safetysms_Unknown_Yellow_Threshold = 10
        , @idc_safetysms_Unknown_Red_Threshold = 10
        , @is_sms_Overall_Score_X_Factor = 'N'
        , @idc_sms_Overall_Yellow_Threshold = 2
        , @idc_sms_Overall_Red_Threshold = 3
        , @idc_sms_Unsafe_Threshold = 65
        , @idc_sms_Unsafe_Factor_Overall = 1
        , @idc_sms_Hos_Threshold = 65
        , @idc_sms_Hos_Factor_Overall = 1
        , @idc_sms_Fitness_Threshold = 80
        , @idc_sms_Fitness_Factor_Overall = 1
        , @idc_sms_CSA_Threshold = 80
        , @idc_sms_CSA_Factor_Overall = 1
        , @idc_sms_Vehicle_Threshold = 80
        , @idc_sms_Vehicle_Factor_Overall = 1
   BEGIN
      --Authority
      SELECT @is_authority = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Overall'
         AND d.keyname = 'Include Authority (Y/N)?'
      --Insurance
      SELECT @is_insurance = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Overall'
         AND d.keyname = 'Include Insurance (Y/N)?'
      --Safety Rating
      SELECT @is_safetyrating = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Overall'
         AND d.keyname = 'Include Safety Rating (Y/N)?'
      --Carrier SMS Overall
      SELECT @is_sms = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Overall'
         AND d.keyname = 'Include SMS (Y/N)?'
      --Safety And SMS Overall
      SELECT @is_safetysms = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Overall'
         AND d.keyname = 'Include Safety And SMS (Y/N)?'

      SELECT @is_safetysms_Score_X_Factor = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Multiply Weight with Score (Y/N)?'

      SELECT @idc_safetysms_Satisfactory_Yellow_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Satisfactory Yellow SMS Threshold'

      SELECT @idc_safetysms_Satisfactory_Red_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Satisfactory Red SMS Threshold'

      SELECT @idc_safetysms_Conditional_Yellow_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Conditional Yellow SMS Threshold'

      SELECT @idc_safetysms_Conditional_Red_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Conditional Red SMS Threshold'

      SELECT @idc_safetysms_Unsatisfactory_Yellow_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Unsatisfactory Yellow SMS Threshold'

      SELECT @idc_safetysms_Unsatisfactory_Red_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Unsatisfactory Red SMS Threshold'

      SELECT @idc_safetysms_Unknown_Yellow_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Unknown Yellow SMS Threshold'

      SELECT @idc_safetysms_Unknown_Red_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier Safety and SMS Overall'
         AND d.keyname = 'Safety Rating Unknown Red SMS Threshold'

      --SMS Overall Thresholds
      SELECT @is_sms_Overall_Score_X_Factor = IsNull(d.keyvalueString,'N')
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier SMS Overall'
         AND d.keyname = 'Multiply Weight with Score (Y/N)?'

      SELECT @idc_sms_Overall_Yellow_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier SMS Overall'
         AND d.keyname = 'Yellow Threshold'

      SELECT @idc_sms_Overall_Red_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'Carrier SMS Overall'
         AND d.keyname = 'Red Threshold'

      --SMS Unsafe Driving Thresholds
      SELECT @idc_sms_Unsafe_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Unsafe Driving'
         AND d.keyname = 'Threshold'

      SELECT @idc_sms_Unsafe_Factor_Overall = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Unsafe Driving'
         AND d.keyname = 'Weight Assigned'

      --SMS Hours of Service Thresholds
      SELECT @idc_sms_Hos_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Hours of Service'
         AND d.keyname = 'Threshold'

      SELECT @idc_sms_Hos_Factor_Overall = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Hours of Service'
         AND d.keyname = 'Weight Assigned'

      --SMS Driver Fitness Thresholds
      SELECT @idc_sms_Fitness_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Driver Fitness'
         AND d.keyname = 'Threshold'

      SELECT @idc_sms_Fitness_Factor_Overall = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Driver Fitness'
         AND d.keyname = 'Weight Assigned'

      --SMS Control Substance Thresholds
      SELECT @idc_sms_CSA_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Control Substance'
         AND d.keyname = 'Threshold'

      SELECT @idc_sms_CSA_Factor_Overall = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Control Substance'
         AND d.keyname = 'Weight Assigned'

      --SMS Vehicle Maintenance Thresholds
      SELECT @idc_sms_Vehicle_Threshold = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Vehicle Maintenance'
         AND d.keyname = 'Threshold'

      SELECT @idc_sms_Vehicle_Factor_Overall = IsNull(d.keyvalueNumber,0)
        FROM CarrierQualificationInfoHdr h
        JOIN CarrierQualificationInfoDtl d ON h.id = d.CarrierQualificationInfoHdr_id
       WHERE h.FeatureName = 'Carrier Qualification Policies'
         AND d.elementname = 'SMS Vehicle Maintenance'
         AND d.keyname = 'Weight Assigned'
   END
   --END ***Settings***

   --Initialize
   SELECT @li_auth_status           = 0
   SELECT @li_auth_revoke           = 0
   SELECT @ii_authority             = 0

   SELECT @li_ins_cargo             = 0
   SELECT @li_ins_liability         = 0
   SELECT @ii_insurance             = 0

   SELECT @ii_safetysms             = 0
   SELECT @ii_safety_rating         = 0
   SELECT @ii_sms                   = 0

   SELECT @ii_sms_unsafe            = 0
   SELECT @ii_sms_hos               = 0
   SELECT @ii_sms_fitness           = 0
   SELECT @ii_sms_csa               = 0
   SELECT @ii_sms_vehicle           = 0

   SELECT @ldc_sms_Unsafe_Factor    = 0
   SELECT @ldc_sms_Hos_Factor       = 0
   SELECT @ldc_sms_Fitness_Factor   = 0
   SELECT @ldc_sms_CSA_Factor       = 0
   SELECT @ldc_sms_Vehicle_Factor   = 0

   SELECT @ldc_safetysms            = 0
   SELECT @ldc_sms_overall          = 0


   --Carrier CSA Info
   IF EXISTS(SELECT 1
               FROM CarrierCSA
              WHERE cas_dot_number = @dotNum OR docket = @docket
            )
      SELECT @cas_authority_common_status               = cas_authority_common_status
           , @cas_authority_contract_status             = cas_authority_contract_status
           , @cas_authority_common_revocation_pending   = cas_authority_common_revocation_pending
           , @cas_authority_contract_revocation_pending = cas_authority_contract_revocation_pending
           , @cas_insurance_cargo_required              = cas_insurance_cargo_required
           , @cas_insurance_cargo_filed                 = cas_insurance_cargo_filed
           , @cas_insurance_bipd_required               = cas_insurance_bipd_required
           , @cas_insurance_bipd_filed                  = cas_insurance_bipd_filed
           , @cas_safety_rating                         = cas_safety_rating
           , @sms_unsafe_prcnt                          = IsNull(sms_unsafe_prcnt,0)
           , @sms_fatig_prcnt                           = IsNull(sms_fatig_prcnt,0)
           , @sms_fit_prcnt                             = IsNull(sms_fit_prcnt,0)
           , @sms_cntrl_prcnt                           = IsNull(sms_cntrl_prcnt,0)
           , @sms_veh_prcnt                             = IsNull(sms_veh_prcnt,0)
        FROM CarrierCSA
       WHERE cas_dot_number = @dotNum or docket = @docket

   --***Authority***
   --Status
   If @cas_authority_common_status IS NULL AND @cas_authority_contract_status IS NULL
      SELECT @li_auth_status = 0    --Unknown
   Else If @cas_authority_common_status = 'A' OR @cas_authority_contract_status = 'A'
      SELECT @li_auth_status = 1    --Green
   Else
      SELECT @li_auth_status = 3    --Red

   --Any Revocation Pending
   If @cas_authority_common_revocation_pending IS NULL AND @cas_authority_contract_revocation_pending IS NULL
      SELECT @li_auth_revoke = 0    --Unknown
   Else If @cas_authority_common_revocation_pending = 'Y' OR @cas_authority_contract_revocation_pending = 'Y'
      SELECT @li_auth_revoke = 2    --Yellow
   Else
  SELECT @li_auth_revoke = 1    --Green

   --Status Vs Revocation
   SELECT @ii_authority = (CASE WHEN @li_auth_status > @li_auth_revoke THEN @li_auth_status ELSE @li_auth_revoke END)


   --***Insurance***
   --Required Cargo vs Cargo on file
   If @cas_insurance_cargo_required IS NULL AND @cas_insurance_cargo_filed IS NULL
      SELECT @li_ins_cargo = 0         --Unknown
   Else If @cas_insurance_cargo_required = 'Y' AND @cas_insurance_cargo_filed <> 'Y'
      SELECT @li_ins_cargo = 3         --Red
   Else
      SELECT @li_ins_cargo = 1         --Green

   --Required Liability vs Liability on file
   If @cas_insurance_bipd_required IS NULL AND @cas_insurance_bipd_filed IS NULL
      SELECT @li_ins_liability = 0     --Unknown
   Else
      If @cas_insurance_bipd_filed >= @cas_insurance_bipd_required
         SELECT @li_ins_liability = 1   --Green
      Else If @cas_insurance_bipd_filed < @cas_insurance_bipd_required AND @cas_insurance_bipd_required > 0
         SELECT @li_ins_liability = 3  --Red
      Else
         SELECT @li_ins_liability = 1  --Green

   --Cargo and Liability
   SELECT @ii_insurance = (CASE WHEN @li_ins_cargo > @li_ins_liability THEN @li_ins_cargo ELSE @li_ins_liability END)


   --***Safety Rating***
   IF @cas_safety_rating = 'S'      --Satisfactory
      SELECT @ii_safety_rating = 1  --Green
   ELSE IF @cas_safety_rating = 'C' --Conditional
      SELECT @ii_safety_rating = 2  --Yellow
   ELSE IF @cas_safety_rating = 'U' --Unsatisfactory
      SELECT @ii_safety_rating = 3  --Red
   ELSE                             --Unknown
      SELECT @ii_safety_rating = 0  --Unknown

   --***SMS Scores***
   If @sms_unsafe_prcnt >= @idc_sms_Unsafe_Threshold
   BEGIN
      SELECT @ii_sms_Unsafe = 1     --Alert
      SELECT @ldc_sms_Unsafe_Factor = @idc_sms_Unsafe_Factor_Overall
   END
   If @sms_fatig_prcnt >= @idc_sms_Hos_Threshold
   BEGIN
      SELECT @ii_sms_Hos = 1    --Alert
      SELECT @ldc_sms_Hos_Factor = @idc_sms_Hos_Factor_Overall
   END
   If @sms_fit_prcnt >= @idc_sms_Fitness_Threshold
   BEGIN
      SELECT @ii_sms_Fitness = 1    --Alert
      SELECT @ldc_sms_Fitness_Factor = @idc_sms_Fitness_Factor_Overall
   END
   If @sms_cntrl_prcnt >= @idc_sms_CSA_Threshold
   BEGIN
      SELECT @ii_sms_CSA = 1        --Alert
      SELECT @ldc_sms_CSA_Factor = @idc_sms_CSA_Factor_Overall
   END
   If @sms_veh_prcnt >= @idc_sms_Vehicle_Threshold
   BEGIN
      SELECT @ii_sms_Vehicle = 1    --Alert
      SELECT @ldc_sms_Vehicle_Factor = @idc_sms_Vehicle_Factor_Overall
   END

   --***Compute Safety And SMS Overall
   If @is_safetysms_Score_X_Factor = 'Y'
      BEGIN
         SELECT @ldc_safetysms = (@sms_unsafe_prcnt  * @ldc_sms_Unsafe_Factor)    +
                                 (@sms_fatig_prcnt   * @ldc_sms_Hos_Factor)       +
                                 (@sms_fit_prcnt     * @ldc_sms_Fitness_Factor)   +
                                 (@sms_cntrl_prcnt   * @ldc_sms_CSA_Factor)       +
                                 (@sms_veh_prcnt     * @ldc_sms_Vehicle_Factor)
      END
   Else
      BEGIN
         SELECT @ldc_safetysms = @ldc_sms_Unsafe_Factor  + @ldc_sms_Hos_Factor    +
                                 @ldc_sms_Fitness_Factor + @ldc_sms_CSA_Factor    +
                                 @ldc_sms_Vehicle_Factor
      END
   --Safety and SMS Overall
   IF @cas_safety_rating = 'S'      --Satisfactory
      BEGIN
         If @ldc_safetysms < @idc_safetysms_Satisfactory_Yellow_Threshold
            SELECT @ii_safetysms = 1   --Green
         Else If @ldc_safetysms >= @idc_safetysms_Satisfactory_Yellow_Threshold And @ldc_safetysms < @idc_safetysms_Satisfactory_Red_Threshold
            SELECT @ii_safetysms = 2   --Yellow
         Else
            SELECT @ii_safetysms = 3    --Red
      END
   ELSE IF @cas_safety_rating = 'C' --Conditional
      BEGIN
         If @ldc_safetysms < @idc_safetysms_Conditional_Yellow_Threshold
    SELECT @ii_safetysms = 1   --Green
         Else If @ldc_safetysms >= @idc_safetysms_Conditional_Yellow_Threshold And @ldc_safetysms < @idc_safetysms_Conditional_Red_Threshold
            SELECT @ii_safetysms = 2   --Yellow
         Else
            SELECT @ii_safetysms = 3    --Red
      END
   ELSE IF @cas_safety_rating = 'U' --Unsatisfactory
      BEGIN
         If @ldc_safetysms < @idc_safetysms_Unsatisfactory_Yellow_Threshold
            SELECT @ii_safetysms = 1   --Green
         Else If @ldc_safetysms >= @idc_safetysms_Unsatisfactory_Yellow_Threshold And @ldc_safetysms < @idc_safetysms_Unsatisfactory_Red_Threshold
            SELECT @ii_safetysms = 2   --Yellow
         Else
            SELECT @ii_safetysms = 3    --Red
      END
   ELSE                             --Unknown
      BEGIN
         If @ldc_safetysms < @idc_safetysms_Unknown_Yellow_Threshold
            SELECT @ii_safetysms = 1   --Green
         Else If @ldc_safetysms >= @idc_safetysms_Unknown_Yellow_Threshold And @ldc_safetysms < @idc_safetysms_Unknown_Red_Threshold
            SELECT @ii_safetysms = 2   --Yellow
         Else
            SELECT @ii_safetysms = 3    --Red
      END


   --***Compute SMS Overall
   If @is_sms_Overall_Score_X_Factor = 'Y'
      BEGIN
         SELECT @ldc_sms_overall = (@sms_unsafe_prcnt  * @ldc_sms_Unsafe_Factor)    +
                                   (@sms_fatig_prcnt   * @ldc_sms_Hos_Factor)       +
                                   (@sms_fit_prcnt     * @ldc_sms_Fitness_Factor)   +
                                   (@sms_cntrl_prcnt   * @ldc_sms_CSA_Factor)       +
                                   (@sms_veh_prcnt     * @ldc_sms_Vehicle_Factor)
      END
   Else
      BEGIN
         SELECT @ldc_sms_overall = @ldc_sms_Unsafe_Factor  + @ldc_sms_Hos_Factor    +
                                   @ldc_sms_Fitness_Factor + @ldc_sms_CSA_Factor    +
                                   @ldc_sms_Vehicle_Factor
      END
   --SMS Overall
   If @ldc_sms_overall < @idc_sms_Overall_Yellow_Threshold
      SELECT @ii_sms = 1   --Green
   Else If @ldc_sms_overall >= @idc_sms_Overall_Yellow_Threshold And @ldc_sms_overall < @idc_sms_Overall_Red_Threshold
      SELECT @ii_sms = 2   --Yellow
   Else
      SELECT @ii_sms = 3    --Red


   --Return Status
   IF @CarrierCSA_category = 'AUTHORITY'
      SELECT @li_CarrierCSAStatus = @ii_authority
   ELSE IF @CarrierCSA_category = 'INSURANCE'
      SELECT @li_CarrierCSAStatus = @ii_insurance
   ELSE IF @CarrierCSA_category = 'SAFETYSMSOVERALL'
      SELECT @li_CarrierCSAStatus = @ii_safetysms
   ELSE IF @CarrierCSA_category = 'SAFETYRATING'
      SELECT @li_CarrierCSAStatus = @ii_safety_rating
   ELSE IF @CarrierCSA_category = 'SMS'
      SELECT @li_CarrierCSAStatus = @ii_sms
   ELSE IF @CarrierCSA_category = 'SMS_UNSAFE'
      SELECT @li_CarrierCSAStatus = @ii_sms_unsafe
   ELSE IF @CarrierCSA_category = 'SMS_FATIGUE' OR @CarrierCSA_category = 'SMS_HOS'
      SELECT @li_CarrierCSAStatus = @ii_sms_hos
   ELSE IF @CarrierCSA_category = 'SMS_FITNESS'
      SELECT @li_CarrierCSAStatus = @ii_sms_fitness
   ELSE IF @CarrierCSA_category = 'SMS_CSA'
      SELECT @li_CarrierCSAStatus = @ii_sms_csa
   ELSE IF @CarrierCSA_category = 'SMS_VEHICLE'
      SELECT @li_CarrierCSAStatus = @ii_sms_vehicle
   ELSE --'ALL'
      BEGIN
         INSERT INTO @TEMP (Scores)
         SELECT (CASE WHEN @is_authority = 'Y' THEN @ii_authority ELSE 0 END)
         UNION ALL
         SELECT (CASE WHEN @is_insurance = 'Y' THEN @ii_insurance ELSE 0 END)
         UNION ALL
         SELECT (CASE WHEN @is_safetysms = 'Y' THEN @ii_safetysms ELSE 0 END)
         UNION ALL
         SELECT (CASE WHEN @is_safetysms = 'N' THEN (CASE WHEN @is_safetyrating = 'Y' THEN @ii_safety_rating ELSE 0 END) ELSE 0 END)
         UNION ALL
         SELECT (CASE WHEN @is_safetysms = 'N' THEN (CASE WHEN @is_sms = 'Y' THEN @ii_sms ELSE 0 END) ELSE 0 END)

 SELECT @li_CarrierCSAStatus = MAX(Scores) FROM @TEMP
      END

   RETURN @li_CarrierCsaStatus

END

GO
GRANT EXECUTE ON  [dbo].[fn_GetCarrierCSAStatus] TO [public]
GO
