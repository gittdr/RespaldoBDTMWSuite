SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

  create procedure [dbo].[process_carrier411_batch_sp](@batch_number int)  
as  

If @batch_number = 0  
   Return 0

Declare
@update_type varchar(20),
@batch_count int,
@userid varchar(20),
@batch_status varchar(20),
@duplicates char(1) --50545 pmill

--50545 pmill see if we should allow duplicate carrier profiles
select @duplicates = coalesce(gi_string1, 'N') from generalinfo where gi_name = 'Carrier411Audit'

--determine what type of update this is
SELECT @update_type = cbu_update_type,
      @batch_count = cbu_batchcount,
      @batch_status = cbu_batch_status
FROM carrier411_batch_update_status 
WHERE cab_batch_number = @batch_number

If isnull(@update_type, '') = '' --could not determine type of batch it is
   Return 0

If @batch_count = 0 --nothing to update
   Return 1  

EXEC @userid = gettmwuser_fn

--create log entry
INSERT INTO carrier411_activity_log (
      cal_activity_type, 
      cal_activity_datetime, 
      cab_batch_number, 
      cal_activity_userid, 
      cal_activity_text) 
   VALUES (
      'BATCH',
      getdate(),
      @batch_number,
      @userid,
      'Auditing batch'
      )

If @batch_status NOT IN ('COMPLETED','UPDATED','AUDITED')
BEGIN
   --audit the batch
   --find carrier records that match
   INSERT INTO carrier411_carrier_audit_log (
         cab_batch_number,
         cas_docket_number,
         car_id,
         car_iccnum,
         car_name,
         cab_legal_name,
         audit_result)
      SELECT
         cab_batch_number,
         cas_docket_number,
         carrier.car_id,
         carrier.car_iccnum,
         carrier.car_name,
         cab_legal_name,
         'MATCH'
      FROM carrier411_batch
      JOIN carrier ON (carrier.car_iccnum = cas_docket_number or ('MC' + carrier.car_iccnum) = cas_docket_number)
      WHERE cab_batch_number = @batch_number

   --find docket numbers that didn't match
   INSERT INTO carrier411_carrier_audit_log(
         cab_batch_number,
         cas_docket_number,
         car_id,
         cab_legal_name,
         audit_result)
      SELECT
         cab_batch_number,
         cas_docket_number,
         'UNKNOWN',
         cab_legal_name,
         'NO PROFILE'
      FROM carrier411_batch
      WHERE cab_batch_number = @batch_number
      AND cas_docket_number NOT IN (SELECT cas_docket_number FROM carrier411_carrier_audit_log WHERE cab_batch_number = @batch_number)

   --find duplicates
   UPDATE carrier411_carrier_audit_log
   SET audit_result = 'DUPLICATE'
   WHERE cab_batch_number = @batch_number
   AND cas_docket_number IN
      (SELECT cas_docket_number
      FROM carrier411_carrier_audit_log
      WHERE cab_batch_number = @batch_number
      AND cas_docket_number <> 'UNKNOWN'
      GROUP BY cas_docket_number
      HAVING count(distinct car_id) > 1)

   UPDATE carrier411_batch_update_status
   SET cbu_batch_status = 'AUDITED'
   WHERE cab_batch_number = @batch_number
   AND cbu_batch_status <> 'COMPLETE'

END -- audit

--insert/update records into carrierstatus table from carrier411_batch table 
INSERT INTO carrier411_activity_log (
      cal_activity_type, 
      cal_activity_datetime, 
      cab_batch_number, 
      cal_activity_userid, 
      cal_activity_text) 
   VALUES (
      'BATCH',
      getdate(),
      @batch_number,
      @userid,
      'Updating carrier profiles'
      )

BEGIN TRAN
If @update_type = 'ALLCARRIERS'
   --delete all existing records in carrierstatus table, and clear monitored flags in carrier profiles
   BEGIN
      DELETE FROM carrierstatus
      UPDATE carrier SET car_411_monitored = 'N'
      --BEGIN PTS 55231 SPN
      --delete all existing records in carrier411_sms table
      DELETE FROM carrier411_sms
      --END PTS 55231 SPN
   END

If @update_type IN ('BATCHADD', 'INSAUTH', 'ADDCARRIER', 'DELETECARRIER')
   --delete the records from carrierstatus if they exist, since we are updating all the fields anyway
   BEGIN
      DELETE FROM carrierstatus
      WHERE cas_docket_number in (SELECT cas_docket_number from carrier411_batch where cab_batch_number = @batch_number)
      --BEGIN PTS 55231 SPN
      --delete records in carrier411_sms table that are being processed in this batch
      DELETE FROM carrier411_sms
      WHERE sms_cas_docket_number IN (SELECT cas_docket_number
                                        FROM carrier411_batch
                                       WHERE cab_batch_number = @batch_number
                                     )
      --END PTS 55231 SPN
   END

If @update_type in ('ALLCARRIERS', 'BATCHADD', 'INSAUTH', 'ADDCARRIER') 
   --BEGIN PTS 55231 SPN
   BEGIN
   --END PTS 55231 SPN
   --do inserts 
      INSERT INTO carrierstatus (
         cas_docket_number,
         cas_safety_rating,
         --BEGIN PTS 55231 SPN
         --cas_safestat_driver,
         --cas_safestat_safety,
         --cas_safestat_vehicle,
         --END PTS 55231 SPN
         cas_authority_broker_status,
         cas_authority_broker_app_pending,
         cas_authority_broker_revocation_pending,
         cas_authority_common_status,
         cas_authority_common_app_pending,
         cas_authority_common_revocation_pending,
         cas_authority_contract_status,
         cas_authority_contract_app_pending,
         cas_authority_contract_revocation_pending,
         cas_insurance_cargo_required,
         cas_insurance_cargo_filed,
         cas_insurance_bond_required,
         cas_insurance_bond_filed,
         cas_insurance_bipd_required,
         cas_insurance_bipd_filed,
         cas_legal_name,
         cas_dba_name,
         cas_business_address,
         cas_business_city,
         cas_business_state,
         cas_business_zip,
         cas_business_country,
         cas_business_phone,
         cas_business_fax,
         cas_411_last_update,
         cas_rate_date,
         cas_dot_number,
         cas_last_update) 
      SELECT 
         cas_docket_number,
         cab_safety_rating,
         --BEGIN PTS 55231 SPN
         --cab_safestat_driver,
         --cab_safestat_safety,
         --cab_safestat_vehicle,
         --END PTS 55231 SPN
         cab_authority_broker_status,
         cab_authority_broker_app_pending,
         cab_authority_broker_revocation_pending,
         cab_authority_common_status,
         cab_authority_common_app_pending,
         cab_authority_common_revocation_pending,
         cab_authority_contract_status,
         cab_authority_contract_app_pending,
         cab_authority_contract_revocation_pending,
         cab_insurance_cargo_required,
         cab_insurance_cargo_filed,
         cab_insurance_bond_required,
         cab_insurance_bond_filed,
         cab_insurance_bipd_required,
         cab_insurance_bipd_filed,
         cab_legal_name,
         cab_dba_name,
         cab_business_address,
         cab_business_city,
         cab_business_state,
         cab_business_zip,
         cab_business_country,
         cab_business_phone,
         cab_business_fax,
         cab_411_last_update,
         cab_rate_date,
         cab_dot_number,
         getdate()
      FROM carrier411_batch 
      WHERE cab_batch_number = @batch_number
--For now, inserting all records regardless if they have a matching carrier profile, since they are monitored by the client's Carrier411 account
--       AND cas_docket_number in
--          (SELECT cas_docket_number
--             FROM carrier411_carrier_audit_log
--             WHERE cab_batch_number = @batch_number
--                AND car_id <> 'UNKNOWN')

   --BEGIN PTS 55231 SPN
   INSERT INTO carrier411_sms
   ( sms_cas_docket_number
   , sms_insp_total
   , sms_driver_insp_total
   , sms_driver_oos_insp_total
   , sms_vehicle_insp_total
   , sms_vehicle_oos_insp_total
   , sms_fit_last
   , sms_safe_fit
   , sms_basic_last
   , sms_ins_other_violation
   , sms_ins_other_indicator
   , sms_unsafe_prcnt
   , sms_unsafe_alert
   , sms_unsafe_violation
   , sms_unsafe_indicator
   , sms_unsafe_inspect
   , sms_unsafe_score
   , sms_fatig_prcnt
   , sms_fatig_alert
   , sms_fatig_violation
   , sms_fatig_indicator
   , sms_fatig_inspect
   , sms_fatig_score
   , sms_fit_prcnt
   , sms_fit_alert
   , sms_fit_violation
   , sms_fit_indicator
   , sms_fit_inspect
   , sms_fit_score
   , sms_cntrl_prcnt
   , sms_cntrl_alert
   , sms_cntrl_violation
   , sms_cntrl_indicator
   , sms_cntrl_inspect
   , sms_cntrl_score
   , sms_veh_prcnt
   , sms_veh_alert
   , sms_veh_violation
   , sms_veh_indicator
   , sms_veh_inspect
   , sms_veh_score
   , sms_cargo_prcnt
   , sms_cargo_alert
   , sms_cargo_violation
   , sms_cargo_indicator
   , sms_cargo_inspect
   , sms_cargo_score
   )
   SELECT cas_docket_number
        , cab_sms_insp_total
        , cab_sms_driver_insp_total
        , cab_sms_driver_oos_insp_total
        , cab_sms_vehicle_insp_total
        , cab_sms_vehicle_oos_insp_total
        , cab_sms_fit_last
        , cab_sms_safe_fit
        , cab_sms_basic_last
        , cab_sms_ins_other_violation
        , cab_sms_ins_other_indicator
        , cab_sms_unsafe_prcnt
        , cab_sms_unsafe_alert
        , cab_sms_unsafe_violation
        , cab_sms_unsafe_indicator
        , cab_sms_unsafe_inspect
        , cab_sms_unsafe_score
        , cab_sms_fatig_prcnt
        , cab_sms_fatig_alert
        , cab_sms_fatig_violation
        , cab_sms_fatig_indicator
        , cab_sms_fatig_inspect
        , cab_sms_fatig_score
        , cab_sms_fit_prcnt
        , cab_sms_fit_alert
        , cab_sms_fit_violation
        , cab_sms_fit_indicator
        , cab_sms_fit_inspect
        , cab_sms_fit_score
        , cab_sms_cntrl_prcnt
        , cab_sms_cntrl_alert
        , cab_sms_cntrl_violation
        , cab_sms_cntrl_indicator
        , cab_sms_cntrl_inspect
        , cab_sms_cntrl_score
        , cab_sms_veh_prcnt
        , cab_sms_veh_alert
        , cab_sms_veh_violation
        , cab_sms_veh_indicator
        , cab_sms_veh_inspect
        , cab_sms_veh_score
        , cab_sms_cargo_prcnt
        , cab_sms_cargo_alert
        , cab_sms_cargo_violation
        , cab_sms_cargo_indicator
        , cab_sms_cargo_inspect
        , cab_sms_cargo_score
     FROM carrier411_batch 
    WHERE cab_batch_number = @batch_number
   --END PTS 55231 SPN
   --BEGIN PTS 55231 SPN
   END
   --END PTS 55231 SPN
   
ELSE
   IF @update_type IN ('SAFETY','ALLSAFETY')
      --update safety rating and rate date only
      UPDATE carrierstatus
      SET cas_safety_rating = cab_safety_rating,
         cas_rate_date = cab_rate_date,
         cas_last_update = getdate()
      FROM carrier411_batch
      WHERE cab_batch_number = @batch_number
         AND carrierstatus.cas_docket_number = carrier411_batch.cas_docket_number
   ELSE
      --BEGIN PTS 55231 SPN
      --IF @update_type = 'SAFESTAT'
      --   --update safestat scores only
      --   UPDATE carrierstatus
      --   SET cas_safestat_driver = cab_safestat_driver,
      --      cas_safestat_safety = cab_safestat_safety,
      --      cas_safestat_vehicle = cab_safestat_vehicle,
      --      cas_last_update = getdate()
      --   FROM carrier411_batch
      --   WHERE cab_batch_number = @batch_number
      --      AND carrierstatus.cas_docket_number = carrier411_batch.cas_docket_number
      --ELSE
      --END PTS 55231 SPN
         IF @update_type = 'ALLINSAUTH'
            --update insurance and authority only
            UPDATE carrierstatus
            SET cas_authority_broker_status = cab_authority_broker_status,
               cas_authority_broker_app_pending = cab_authority_broker_app_pending,
               cas_authority_broker_revocation_pending = cab_authority_broker_revocation_pending,
               cas_authority_common_status = cab_authority_common_status,
               cas_authority_common_app_pending = cab_authority_common_app_pending,
               cas_authority_common_revocation_pending = cab_authority_common_revocation_pending,
               cas_authority_contract_status = cab_authority_contract_status,
               cas_authority_contract_app_pending = cab_authority_contract_app_pending,
               cas_authority_contract_revocation_pending = cab_authority_contract_revocation_pending,
               cas_insurance_cargo_required = cab_insurance_cargo_required,
               cas_insurance_cargo_filed = cab_insurance_cargo_filed,
               cas_insurance_bond_required = cab_insurance_bond_required,
               cas_insurance_bond_filed = cab_insurance_bond_filed,
               cas_insurance_bipd_required = cab_insurance_bipd_required,
               cas_insurance_bipd_filed = cab_insurance_bipd_filed,
               cas_dot_number = cab_dot_number,
               cas_411_last_update = cab_411_last_update,
               cas_last_update = getdate()
            FROM carrier411_batch
            WHERE cab_batch_number = @batch_number
               AND carrierstatus.cas_docket_number = carrier411_batch.cas_docket_number
         --BEGIN PTS 55231 SPN
         ELSE
            IF @update_type = 'SMS'
            --update SMS only
            UPDATE carrier411_sms
               SET sms_insp_total               = cab_sms_insp_total
                 , sms_driver_insp_total        = cab_sms_driver_insp_total
                 , sms_driver_oos_insp_total    = cab_sms_driver_oos_insp_total
                 , sms_vehicle_insp_total       = cab_sms_vehicle_insp_total
                 , sms_vehicle_oos_insp_total   = cab_sms_vehicle_oos_insp_total
                 , sms_fit_last                 = cab_sms_fit_last
                 , sms_safe_fit                 = cab_sms_safe_fit
                 , sms_basic_last               = cab_sms_basic_last
                 , sms_ins_other_violation      = cab_sms_ins_other_violation
                 , sms_ins_other_indicator      = cab_sms_ins_other_indicator
                 , sms_unsafe_prcnt             = cab_sms_unsafe_prcnt
                 , sms_unsafe_alert             = cab_sms_unsafe_alert
                 , sms_unsafe_violation         = cab_sms_unsafe_violation
                 , sms_unsafe_indicator         = cab_sms_unsafe_indicator
                 , sms_unsafe_inspect           = cab_sms_unsafe_inspect
                 , sms_unsafe_score             = cab_sms_unsafe_score
                 , sms_fatig_prcnt              = cab_sms_fatig_prcnt
                 , sms_fatig_alert              = cab_sms_fatig_alert
                 , sms_fatig_violation          = cab_sms_fatig_violation
                 , sms_fatig_indicator          = cab_sms_fatig_indicator
                 , sms_fatig_inspect            = cab_sms_fatig_inspect
                 , sms_fatig_score              = cab_sms_fatig_score
                 , sms_fit_prcnt                = cab_sms_fit_prcnt
                 , sms_fit_alert                = cab_sms_fit_alert
                 , sms_fit_violation            = cab_sms_fit_violation
                 , sms_fit_indicator            = cab_sms_fit_indicator
                 , sms_fit_inspect              = cab_sms_fit_inspect
                 , sms_fit_score                = cab_sms_fit_score
                 , sms_cntrl_prcnt              = cab_sms_cntrl_prcnt
                 , sms_cntrl_alert              = cab_sms_cntrl_alert
                 , sms_cntrl_violation          = cab_sms_cntrl_violation
                 , sms_cntrl_indicator          = cab_sms_cntrl_indicator
                 , sms_cntrl_inspect            = cab_sms_cntrl_inspect
                 , sms_cntrl_score              = cab_sms_cntrl_score
                 , sms_veh_prcnt                = cab_sms_veh_prcnt
                 , sms_veh_alert                = cab_sms_veh_alert
                 , sms_veh_violation            = cab_sms_veh_violation
                 , sms_veh_indicator            = cab_sms_veh_indicator
                 , sms_veh_inspect              = cab_sms_veh_inspect
                 , sms_veh_score                = cab_sms_veh_score
                 , sms_cargo_prcnt              = cab_sms_cargo_prcnt
                 , sms_cargo_alert              = cab_sms_cargo_alert
                 , sms_cargo_violation          = cab_sms_cargo_violation
                 , sms_cargo_indicator          = cab_sms_cargo_indicator
                 , sms_cargo_inspect            = cab_sms_cargo_inspect
                 , sms_cargo_score              = cab_sms_cargo_score
              FROM carrier411_batch
             WHERE cab_batch_number = @batch_number
               AND carrier411_sms.sms_cas_docket_number = carrier411_batch.cas_docket_number
         --END PTS 55231 SPN

--update monitored flag in carrier profile

--IF @update_type in ('ALLCARRIERS','BATCHADD','ADDCARRIER')  --pmill 04/27/2009 if a carrier is downloaded update the monitored flag regardless of type of update
IF @update_type not in ('DELETECARRIER')
   --50545 pmill check setting to see if we allow duplicate carrier profiles
   IF @duplicates = 'Y' 
      UPDATE carrier
      SET car_411_monitored = 'Y'
      WHERE car_id IN (
         SELECT car_id 
         FROM carrier411_carrier_audit_log
         WHERE cab_batch_number = @batch_number
         AND cas_docket_number <> 'UNKNOWN'
         AND car_id <> 'UNKNOWN')      
   ELSE
      UPDATE carrier
      SET car_411_monitored = 'Y'
      WHERE car_id IN (
         SELECT car_id 
         FROM carrier411_carrier_audit_log
         WHERE cab_batch_number = @batch_number
         AND cas_docket_number <> 'UNKNOWN'
         AND car_id <> 'UNKNOWN'
         AND audit_result <> 'DUPLICATE')       

COMMIT TRAN

UPDATE carrier411_batch_update_status
SET cbu_batch_status = 'UPDATED'
WHERE cab_batch_number = @batch_number
AND cbu_batch_status <> 'COMPLETE'

RETURN 1

GO
GRANT EXECUTE ON  [dbo].[process_carrier411_batch_sp] TO [public]
GO
