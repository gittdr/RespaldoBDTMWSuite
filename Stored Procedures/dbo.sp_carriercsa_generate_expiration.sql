SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[sp_carriercsa_generate_expiration]
( @CarrierCSALogHdr_id INT
) AS
/**
 *
 * NAME:
 * dbo.sp_carriercsa_generate_expiration
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for creating carrier csa expirations
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @CarrierCSALogHdr_id   INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 13/02/15 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @debug_ind                           CHAR(1)

   DECLARE @ib_create_overall_expiration        BIT
   DECLARE @ib_create_authority_expiration      BIT
   DECLARE @ib_create_insurance_expiration      BIT
   DECLARE @ib_create_safety_expiration         BIT
   DECLARE @ib_create_sms_expiration            BIT
   DECLARE @ib_create_sms_Unsafe_expiration     BIT
   DECLARE @ib_create_sms_Fatigue_expiration    BIT
   DECLARE @ib_create_sms_Fitness_expiration    BIT
   DECLARE @ib_create_sms_CSA_expiration        BIT
   DECLARE @ib_create_sms_Vehicle_expiration    BIT

   DECLARE @msg                                 VARCHAR(1000)
   DECLARE @count                               INT
   DECLARE @next_id                             INT

   DECLARE @ls_carrier_id                       VARCHAR(13)
   DECLARE @ls_docket                           VARCHAR(15)
   DECLARE @carriercsalogdtl_id                 INT

   DECLARE @exp_source                          VARCHAR(30)
   DECLARE @asgn_type                           VARCHAR(3)
   DECLARE @ls_exp_code                         VARCHAR(6)
   DECLARE @ls_exp_enabled                      CHAR(1)
   DECLARE @Action                              CHAR(1)
   DECLARE @priority                            VARCHAR(6)
   DECLARE @exp_description                     VARCHAR(255)
   DECLARE @exp_expirationdate                  DATETIME

   DECLARE @is_overall_exp_code                 VARCHAR(6)
   DECLARE @ii_red_overall_exp                  INT
   DECLARE @ii_yellow_overall_exp               INT

   DECLARE @is_auth_exp_code                    VARCHAR(6)
   DECLARE @ii_red_auth_exp                     INT
   DECLARE @ii_yellow_auth_exp                  INT

   DECLARE @is_ins_exp_code                     VARCHAR(6)
   DECLARE @ii_red_ins_exp                      INT
   DECLARE @ii_yellow_ins_exp                   INT

   DECLARE @is_safety_exp_code                  VARCHAR(6)
   DECLARE @ii_red_safety_exp                   INT
   DECLARE @ii_yellow_safety_exp                INT

   DECLARE @is_sms_overall_exp_code             VARCHAR(6)
   DECLARE @ii_red_sms_overall_exp              INT
   DECLARE @ii_yellow_sms_overall_exp           INT

   DECLARE @is_sms_Unsafe_exp_code              VARCHAR(6)
   DECLARE @ii_alert_sms_Unsafe_exp             INT

   DECLARE @is_sms_Fatigue_exp_code             VARCHAR(6)
   DECLARE @ii_alert_sms_Fatigue_exp            INT

   DECLARE @is_sms_Fitness_exp_code             VARCHAR(6)
   DECLARE @ii_alert_sms_Fitness_exp            INT

   DECLARE @is_sms_CSA_exp_code                 VARCHAR(6)
   DECLARE @ii_alert_sms_CSA_exp                INT

   DECLARE @is_sms_Vehicle_exp_code             VARCHAR(6)
   DECLARE @ii_alert_sms_Vehicle_exp            INT

   DECLARE @li_CarrierCSAStatus                 INT

   DECLARE @TEMP_EXP_CODES TABLE
   ( exp_code     VARCHAR(6)
   , is_enable    INT
   )

   DECLARE @myCarriers TABLE
   ( id                    INT IDENTITY
   , car_id                VARCHAR(13) NULL
   , docket                VARCHAR(15) NULL
   , carriercsalogdtl_id   INT         NOT NULL
   )

   --Initialize
   SELECT @debug_ind    = 'N'
   SELECT @exp_source   = ProviderName FROM CarrierCSALogHdr WHERE id = @CarrierCSALogHdr_id
   SELECT @asgn_type    = 'CAR'
   SELECT @exp_expirationdate = GetDate()

   SELECT @ib_create_overall_expiration      = 0
   SELECT @ib_create_authority_expiration    = 0
   SELECT @ib_create_insurance_expiration    = 0
   SELECT @ib_create_safety_expiration       = 0
   SELECT @ib_create_sms_expiration          = 0
   SELECT @ib_create_sms_Unsafe_expiration   = 0
   SELECT @ib_create_sms_Fatigue_expiration  = 0
   SELECT @ib_create_sms_Fitness_expiration  = 0
   SELECT @ib_create_sms_CSA_expiration      = 0
   SELECT @ib_create_sms_Vehicle_expiration  = 0


   --BEGIN ***GI Settings***
   -- Expirations
   SELECT @ls_exp_enabled        = gi_string1
        , @is_overall_exp_code   = gi_string2
        , @ii_red_overall_exp    = gi_integer1
        , @ii_yellow_overall_exp = gi_integer2
     FROM generalinfo
    WHERE gi_name = 'Carrier411OverallExpiration'
   If @ls_exp_enabled IS NOT NULL AND @ls_exp_enabled = 'Y' AND @is_overall_exp_code IS NOT NULL AND RTrim(@is_overall_exp_code) <> ''
      SELECT @ib_create_overall_expiration  = 1
   If @ii_red_overall_exp IS NULL Or @ii_red_overall_exp <> 1
      SELECT @ii_red_overall_exp = 9
   If @ii_yellow_overall_exp IS NULL OR @ii_yellow_overall_exp <> 1
      SELECT @ii_yellow_overall_exp = 9

   SELECT @ls_exp_enabled     = gi_string1
        , @is_auth_exp_code   = gi_string2
        , @ii_red_auth_exp    = gi_integer1
        , @ii_yellow_auth_exp = gi_integer2
     FROM generalinfo
    WHERE gi_name = 'Carrier411AuthExpiration'
   If @ls_exp_enabled IS NOT NULL AND @ls_exp_enabled = 'Y' AND @is_auth_exp_code IS NOT NULL AND RTrim(@is_auth_exp_code) <> ''
      SELECT @ib_create_authority_expiration  = 1
   If @ii_red_auth_exp IS NULL Or @ii_red_auth_exp <> 1
      SELECT @ii_red_auth_exp = 9
   If @ii_yellow_auth_exp IS NULL OR @ii_yellow_auth_exp <> 1
      SELECT @ii_yellow_auth_exp = 9

   SELECT @ls_exp_enabled     = gi_string1
        , @is_ins_exp_code    = gi_string2
        , @ii_red_ins_exp     = gi_integer1
        , @ii_yellow_ins_exp  = gi_integer2
     FROM generalinfo
    WHERE gi_name = 'Carrier411InsuranceExpiration'
   If @ls_exp_enabled IS NOT NULL AND @ls_exp_enabled = 'Y' AND @is_ins_exp_code IS NOT NULL AND RTrim(@is_ins_exp_code) <> ''
      SELECT @ib_create_insurance_expiration  = 1
   If @ii_red_ins_exp IS NULL Or @ii_red_ins_exp <> 1
      SELECT @ii_red_ins_exp = 9
   If @ii_yellow_ins_exp IS NULL OR @ii_yellow_ins_exp <> 1
      SELECT @ii_yellow_ins_exp = 9

   SELECT @ls_exp_enabled        = gi_string1
        , @is_safety_exp_code    = gi_string2
        , @ii_red_safety_exp     = gi_integer1
        , @ii_yellow_safety_exp  = gi_integer2
     FROM generalinfo
    WHERE gi_name = 'Carrier411SafetyExpiration'
   If @ls_exp_enabled IS NOT NULL AND @ls_exp_enabled = 'Y' AND @is_safety_exp_code IS NOT NULL AND RTrim(@is_safety_exp_code) <> ''
      SELECT @ib_create_safety_expiration  = 1
   If @ii_red_safety_exp IS NULL Or @ii_red_safety_exp <> 1
      SELECT @ii_red_safety_exp = 9
   If @ii_yellow_safety_exp IS NULL OR @ii_yellow_safety_exp <> 1
      SELECT @ii_yellow_safety_exp = 9

   --SMS Expirations
   SELECT @ls_exp_enabled              = gi_string1
        , @is_sms_overall_exp_code     = gi_string2
        , @ii_red_sms_overall_exp      = gi_integer1
        , @ii_yellow_sms_overall_exp   = gi_integer2
     FROM generalinfo
    WHERE gi_name = 'Carrier411smsOverallExpiration'
   IF @ls_exp_enabled IS NOT NULL AND @ls_exp_enabled = 'Y' AND @is_sms_overall_exp_code IS NOT NULL AND RTrim(@is_sms_overall_exp_code) <> ''
      SELECT @ib_create_sms_expiration = 1
   If @ii_red_sms_overall_exp IS NULL Or @ii_red_sms_overall_exp <> 1
      SELECT @ii_red_sms_overall_exp = 9
   If @ii_yellow_sms_overall_exp IS NULL Or @ii_yellow_sms_overall_exp <> 1
      SELECT @ii_yellow_sms_overall_exp = 9

   SELECT @ls_exp_enabled              = gi_string1
        , @is_sms_Unsafe_exp_code      = gi_string2
        , @ii_alert_sms_Unsafe_exp     = gi_integer1
     FROM generalinfo
    WHERE gi_name = 'Carrier411smsUnsafeExpiration'
   IF @ib_create_sms_expiration = 0 AND @ls_exp_enabled IS NOT NULL And @ls_exp_enabled = 'Y' And @is_sms_Unsafe_exp_code IS NOT NULL And RTrim(@is_sms_Unsafe_exp_code) <> ''
      SELECT @ib_create_sms_Unsafe_expiration = 1
   If @ii_alert_sms_Unsafe_exp IS NULL Or @ii_alert_sms_Unsafe_exp <> 1
      SELECT @ii_alert_sms_Unsafe_exp = 9

   SELECT @ls_exp_enabled              = gi_string1
        , @is_sms_Fatigue_exp_code     = gi_string2
        , @ii_alert_sms_Fatigue_exp    = gi_integer1
     FROM generalinfo
    WHERE gi_name = 'Carrier411smsFatigueExpiration'
   IF @ib_create_sms_expiration = 0 AND @ls_exp_enabled IS NOT NULL And @ls_exp_enabled = 'Y' And @is_sms_Fatigue_exp_code IS NOT NULL And RTrim(@is_sms_Fatigue_exp_code) <> ''
      SELECT @ib_create_sms_Fatigue_expiration = 1
   If @ii_alert_sms_Fatigue_exp IS NULL Or @ii_alert_sms_Fatigue_exp <> 1
      SELECT @ii_alert_sms_Fatigue_exp = 9

   SELECT @ls_exp_enabled              = gi_string1
        , @is_sms_Fitness_exp_code     = gi_string2
        , @ii_alert_sms_Fitness_exp    = gi_integer1
     FROM generalinfo
    WHERE gi_name = 'Carrier411smsFitnessExpiration'
   IF @ib_create_sms_expiration = 0 AND @ls_exp_enabled IS NOT NULL And @ls_exp_enabled = 'Y' And @is_sms_Fitness_exp_code IS NOT NULL And RTrim(@is_sms_Fitness_exp_code) <> ''
      SELECT @ib_create_sms_Fitness_expiration = 1
   If @ii_alert_sms_Fitness_exp IS NULL Or @ii_alert_sms_Fitness_exp <> 1
      SELECT @ii_alert_sms_Fitness_exp = 9

   SELECT @ls_exp_enabled              = gi_string1
        , @is_sms_CSA_exp_code         = gi_string2
        , @ii_alert_sms_CSA_exp        = gi_integer1
     FROM generalinfo
    WHERE gi_name = 'Carrier411smsCSAExpiration'
   IF @ib_create_sms_expiration = 0 AND @ls_exp_enabled IS NOT NULL And @ls_exp_enabled = 'Y' And @is_sms_CSA_exp_code IS NOT NULL And RTrim(@is_sms_CSA_exp_code) <> ''
      SELECT @ib_create_sms_CSA_expiration = 1
   If @ii_alert_sms_CSA_exp IS NULL Or @ii_alert_sms_CSA_exp <> 1
      SELECT @ii_alert_sms_CSA_exp = 9

   SELECT @ls_exp_enabled              = gi_string1
        , @is_sms_Vehicle_exp_code     = gi_string2
        , @ii_alert_sms_Vehicle_exp    = gi_integer1
     FROM generalinfo
    WHERE gi_name = 'Carrier411smsVehicleExpiration'
   IF @ib_create_sms_expiration = 0 AND @ls_exp_enabled IS NOT NULL And @ls_exp_enabled = 'Y' And @is_sms_Vehicle_exp_code IS NOT NULL And RTrim(@is_sms_Vehicle_exp_code) <> ''
      SELECT @ib_create_sms_Vehicle_expiration = 1
   If @ii_alert_sms_Vehicle_exp IS NULL Or @ii_alert_sms_Vehicle_exp <> 1
      SELECT @ii_alert_sms_Vehicle_exp = 9

   --END ***GI Settings***


   -- When overall expiration is enabled individual expirations are disabled
   IF @ib_create_overall_expiration = 1
      BEGIN
         SELECT @ib_create_authority_expiration    = 0
         SELECT @ib_create_insurance_expiration    = 0
         SELECT @ib_create_safety_expiration       = 0
         SELECT @ib_create_sms_expiration          = 0
         SELECT @ib_create_sms_Unsafe_expiration   = 0
         SELECT @ib_create_sms_Fatigue_expiration  = 0
         SELECT @ib_create_sms_Fitness_expiration  = 0
         SELECT @ib_create_sms_CSA_expiration      = 0
         SELECT @ib_create_sms_Vehicle_expiration  = 0
      END
   ELSE IF @ib_create_authority_expiration    = 1 OR @ib_create_insurance_expiration    = 1 OR
           @ib_create_safety_expiration       = 1 OR @ib_create_sms_expiration          = 1 OR
           @ib_create_sms_Unsafe_expiration   = 1 OR @ib_create_sms_Fatigue_expiration  = 1 OR
           @ib_create_sms_Fitness_expiration  = 1 OR @ib_create_sms_CSA_expiration      = 1 OR
           @ib_create_sms_Vehicle_expiration  = 1
         BEGIN
            --make sure expiration label file abbr are unique for each expiration
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_auth_exp_code,@ib_create_authority_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_ins_exp_code,@ib_create_insurance_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_safety_exp_code,@ib_create_safety_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_sms_overall_exp_code,@ib_create_sms_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_sms_unsafe_exp_code,@ib_create_sms_unsafe_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_sms_fatigue_exp_code,@ib_create_sms_fatigue_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_sms_fitness_exp_code,@ib_create_sms_fitness_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_sms_csa_exp_code,@ib_create_sms_csa_expiration)
            INSERT INTO @TEMP_EXP_CODES(exp_code,is_enable) VALUES (@is_sms_vehicle_exp_code,@ib_create_sms_vehicle_expiration)
            SELECT @count = COUNT(1)
              FROM (SELECT exp_code
                      FROM @TEMP_EXP_CODES
                     WHERE is_enable = 1
                    GROUP BY exp_code
                    HAVING COUNT(1) > 1
                   ) tec

            If @count > 0
               BEGIN
                  EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, 'Configuration Error: Expiration codes must be unique'
                  SELECT @ib_create_overall_expiration      = 0
                  SELECT @ib_create_authority_expiration    = 0
                  SELECT @ib_create_insurance_expiration    = 0
                  SELECT @ib_create_safety_expiration       = 0
                  SELECT @ib_create_sms_expiration          = 0
                  SELECT @ib_create_sms_Unsafe_expiration   = 0
                  SELECT @ib_create_sms_Fatigue_expiration  = 0
                  SELECT @ib_create_sms_Fitness_expiration  = 0
                  SELECT @ib_create_sms_CSA_expiration      = 0
                  SELECT @ib_create_sms_Vehicle_expiration  = 0
               END
         END
      ELSE
         BEGIN
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, 'At least one Expiration must be configured'
         END

   --Are there any expiration configured
   If @ib_create_overall_expiration       = 0 AND @ib_create_authority_expiration   = 0 AND
      @ib_create_insurance_expiration     = 0 AND @ib_create_safety_expiration      = 0 AND
      @ib_create_sms_expiration           = 0 AND @ib_create_sms_unsafe_expiration  = 0 AND
      @ib_create_sms_fatigue_expiration   = 0 AND @ib_create_sms_fitness_expiration = 0 AND
      @ib_create_sms_csa_expiration       = 0 AND @ib_create_sms_vehicle_expiration = 0
   RETURN

   --BEGIN Process
   EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, 'Updating carrier expirations'

   INSERT INTO @myCarriers(car_id,docket,carriercsalogdtl_id)
   SELECT c.car_id
        , csa.docket
        , csa.CarrierCSALogDtl_id
     FROM carrier c
     JOIN CarrierCSA csa ON c.car_iccnum = csa.docket
     JOIN CarrierCSALogDtl ld ON csa.CarrierCSALogDtl_id = ld.id
    WHERE ld.CarrierCSALogHdr_Id = @CarrierCSALogHdr_id

   SELECT @count = COUNT(1) FROM @myCarriers
   IF @count = 0
      BEGIN
         EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, 'No Carrier Docket matched with Carrier profiles for updating expirations'
      END

   SELECT @next_id = 0
   WHILE @next_id < @count
   BEGIN
      SELECT @next_id = @next_id + 1
      SELECT @ls_carrier_id = car_id
           , @ls_docket = docket
           , @carriercsalogdtl_id = carriercsalogdtl_id
        FROM @myCarriers
       WHERE id = @next_id

      --Overall Expiration
      If @ib_create_overall_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'Overall Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'ALL', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 2
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_yellow_overall_exp)
               SELECT @exp_description = 'Carrier CSA Caution'
            END
         ELSE IF @li_CarrierCsaStatus = 3
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_red_overall_exp)
               SELECT @exp_description = 'Carrier CSA Issue'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA OK'
            END

         SELECT @ls_exp_code = @is_overall_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'Overall Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --Insurance Expiration
      If @ib_create_insurance_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'Insurance Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'INSURANCE', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 2
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_yellow_ins_exp)
               SELECT @exp_description = 'Carrier CSA insufficient or no Insurance on file'
            END
         ELSE IF @li_CarrierCsaStatus = 3
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_red_ins_exp)
               SELECT @exp_description = 'Carrier CSA insufficient or no Insurance on file'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA Insurance OK'
            END

         SELECT @ls_exp_code = @is_ins_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'Insurance Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --Authority Expiration
      If @ib_create_authority_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'Authority Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'AUTHORITY', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 2
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_yellow_auth_exp)
               SELECT @exp_description = 'Carrier CSA common/contract authority pending revocation'
            END
         ELSE IF @li_CarrierCsaStatus = 3
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_red_auth_exp)
               SELECT @exp_description = 'Carrier CSA no common/contract authority'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA Authority OK'
            END

         SELECT @ls_exp_code = @is_auth_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'Authority Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --Safety Expiration
      If @ib_create_safety_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'Safety Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SAFETY', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 2
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_yellow_safety_exp)
               SELECT @exp_description = 'Carrier CSA conditional safety rating and/or SMS score'
            END
         ELSE IF @li_CarrierCsaStatus = 3
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_red_safety_exp)
               SELECT @exp_description = 'Carrier CSA unsatisfactory safety rating and/or unacceptable SMS score'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA safety OK'
            END

         SELECT @ls_exp_code = @is_safety_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'Safety Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --SMS Overall Expiration
      If @ib_create_sms_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'SMS Overall Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SMS', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 2
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_yellow_sms_overall_exp)
               SELECT @exp_description = 'Carrier CSA SMS Overall score'
            END
         ELSE IF @li_CarrierCsaStatus = 3
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_red_sms_overall_exp)
               SELECT @exp_description = 'Carrier CSA SMS issue'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA SMS Overall OK'
            END

         SELECT @ls_exp_code = @is_sms_overall_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'SMS Overall Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --SMS Unsafe Driving Expiration
      If @ib_create_sms_Unsafe_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'SMS Unsafe Driving Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SMS_UNSAFE', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 1
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_alert_sms_unsafe_exp)
               SELECT @exp_description = 'Carrier CSA SMS Unsafe Driving score alert'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA SMS Unsafe Driving score OK'
            END

         SELECT @ls_exp_code = @is_sms_unsafe_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'SMS Unsafe Driving Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --SMS Fatigued Driving Expiration
      If @ib_create_sms_Fatigue_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'SMS Fatigued Driving Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SMS_FATIGUE', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 1
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_alert_sms_fatigue_exp)
               SELECT @exp_description = 'Carrier CSA SMS Fatigued Driving score alert'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA SMS Fatigued Driving score OK'
            END

         SELECT @ls_exp_code = @is_sms_fatigue_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'SMS Fatigued Driving Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --SMS Driver Fitness Expiration
      If @ib_create_sms_Fitness_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'SMS Driver Fitness Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SMS_FITNESS', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 1
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_alert_sms_fitness_exp)
               SELECT @exp_description = 'Carrier CSA SMS Driver Fitness score alert'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA SMS Driver Fitness score OK'
            END

         SELECT @ls_exp_code = @is_sms_fitness_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'SMS Driver Fitness Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --SMS Controlled Substance / Alcohol Expiration
      If @ib_create_sms_CSA_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'SMS Controlled Substance / Alcohol Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SMS_CSA', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 1
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_alert_sms_csa_exp)
               SELECT @exp_description = 'Carrier CSA SMS Controlled Substance / Alcohol score alert'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA SMS Controlled Substance / Alcohol score OK'
            END

         SELECT @ls_exp_code = @is_sms_csa_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'SMS CSA Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

      --SMS Vehicle Maintenance Expiration
      If @ib_create_sms_Vehicle_expiration = 1
      BEGIN
         IF @debug_ind = 'Y'
            Print 'SMS Vehicle Maintenance Expiration: ' + @ls_carrier_id

         SELECT @li_CarrierCsaStatus = 0
         EXEC sp_carrierCsa_status 'SMS_VEHICLE', @ls_docket, @li_CarrierCsaStatus OUT

         IF @li_CarrierCsaStatus = 1
            BEGIN
               SELECT @Action = 'E'
               SELECT @priority = CONVERT(varchar,@ii_alert_sms_vehicle_exp)
               SELECT @exp_description = 'Carrier CSA SMS Vehicle Maintenance score alert'
            END
         ELSE
            BEGIN
               SELECT @priority = '9'
               SELECT @Action = 'D'
               SELECT @exp_description = 'Carrier CSA SMS Vehicle Maintenance score OK'
            END

         SELECT @ls_exp_code = @is_sms_vehicle_exp_code
         BEGIN TRY
            EXEC sp_generate_expiration
                 @exp_source = @exp_source
               , @asgn_type = @asgn_type
               , @asgn_id = @ls_carrier_id
               , @exp_code = @ls_exp_code
               , @exp_priority = @priority
               , @exp_expirationdate = @exp_expirationdate
               , @exp_description = @exp_description
               , @Action = @action
               , @carriercsalogdtl_id = @CarrierCSALogDtl_id
         END TRY
         BEGIN CATCH
            SELECT @msg = 'SMS Vehicle Maintenance Expiration: ' + error_message()
            EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, @msg
         END CATCH
      END

   END

   EXEC sp_CarrierCSALogHdrMessage @CarrierCSALogHdr_id, 'Carrier expiration update complete'
   --END Process

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carriercsa_generate_expiration] TO [public]
GO
