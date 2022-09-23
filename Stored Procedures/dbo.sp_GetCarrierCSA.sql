SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_GetCarrierCSA]
( @as_docket            CHAR(15)
)
AS

/**
 *
 * NAME:
 * dbo.sp_GetCarrierCSA
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to return rows from table CarrierCSA
 *
 * RETURNS:
 *
 * RESULTSET
 *
 * PARAMETERS:
 * @as_docket  CHAR(15)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/18/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   SELECT TOP 1
          csa.docket                                              AS docket
        , csa.cas_legal_name                                      AS cas_legal_name
        , csa.cas_dba_name                                        AS cas_dba_name
        , csa.cas_business_address                                AS cas_business_address
        , csa.cas_business_city                                   AS cas_business_city
        , csa.cas_business_state                                  AS cas_business_state
        , csa.cas_business_zip                                    AS cas_business_zip
        , csa.cas_business_country                                AS cas_business_country
        , csa.cas_business_phone                                  AS cas_business_phone
        , csa.cas_business_fax                                    AS cas_business_fax
        , dbo.fn_GetCarrierCSAStatus('SAFETYRATING',csa.cas_dot_number,csa.docket)   AS tmwstatus_SAFETYRATING
        , csa.cas_safety_rating                                   AS cas_safety_rating
        , csa.cas_rate_date                                       AS cas_rate_date
        , dbo.fn_GetCarrierCSAStatus('AUTHORITY',csa.cas_dot_number,csa.docket)      AS tmwstatus_AUTHORITY
        , csa.cas_authority_broker_status                         AS cas_authority_broker_status
        , csa.cas_authority_broker_app_pending                    AS cas_authority_broker_app_pending
        , csa.cas_authority_broker_revocation_pending             AS cas_authority_broker_revocation_pending
        , csa.cas_authority_common_status                         AS cas_authority_common_status
        , csa.cas_authority_common_app_pending                    AS cas_authority_common_app_pending
        , csa.cas_authority_common_revocation_pending             AS cas_authority_common_revocation_pending
        , csa.cas_authority_contract_status                       AS cas_authority_contract_status
        , csa.cas_authority_contract_app_pending                  AS cas_authority_contract_app_pending
        , csa.cas_authority_contract_revocation_pending           AS cas_authority_contract_revocation_pending
        , dbo.fn_GetCarrierCSAStatus('INSURANCE',csa.cas_dot_number,csa.docket)      AS tmwstatus_INSURANCE
        , csa.cas_insurance_cargo_required                        AS cas_insurance_cargo_required
        , csa.cas_insurance_cargo_filed                           AS cas_insurance_cargo_filed
        , csa.cas_insurance_bond_required                         AS cas_insurance_bond_required
        , csa.cas_insurance_bond_filed                            AS cas_insurance_bond_filed
        , csa.cas_insurance_bipd_required                         AS cas_insurance_bipd_required
        , csa.cas_insurance_bipd_filed                            AS cas_insurance_bipd_filed
        , dbo.fn_GetCarrierCSAStatus('SMS',csa.cas_dot_number,csa.docket)            AS tmwstatus_SMS
        , csa.cas_dot_number                                      AS cas_dot_number
        , csa.sms_insp_total                                      AS sms_insp_total
        , csa.sms_driver_insp_total                               AS sms_driver_insp_total
        , csa.sms_driver_oos_insp_total                           AS sms_driver_oos_insp_total
        , csa.sms_vehicle_insp_total                              AS sms_vehicle_insp_total
        , csa.sms_vehicle_oos_insp_total                          AS sms_vehicle_oos_insp_total
        , dbo.fn_GetCarrierCSAStatus('SMS_UNSAFE',csa.cas_dot_number,csa.docket)     AS tmwstatus_SMS_UNSAFE
        , csa.sms_unsafe_prcnt                                    AS sms_unsafe_prcnt
        , csa.sms_unsafe_alert                                    AS sms_unsafe_alert
        , csa.sms_unsafe_violation                                AS sms_unsafe_violation
        , csa.sms_unsafe_indicator                                AS sms_unsafe_indicator
        , dbo.fn_GetCarrierCSAStatus('SMS_FATIGUE',csa.cas_dot_number,csa.docket)    AS tmwstatus_SMS_FATIGUE
        , csa.sms_fatig_prcnt                                     AS sms_fatig_prcnt
        , csa.sms_fatig_alert                                     AS sms_fatig_alert
        , csa.sms_fatig_violation                                 AS sms_fatig_violation
        , csa.sms_fatig_indicator                                 AS sms_fatig_indicator
        , dbo.fn_GetCarrierCSAStatus('SMS_FITNESS',csa.cas_dot_number,csa.docket)    AS tmwstatus_SMS_FITNESS
        , csa.sms_fit_prcnt                                       AS sms_fit_prcnt
        , csa.sms_fit_alert                                       AS sms_fit_alert
        , csa.sms_fit_violation                                   AS sms_fit_violation
        , csa.sms_fit_indicator                                   AS sms_fit_indicator
        , dbo.fn_GetCarrierCSAStatus('SMS_CSA',csa.cas_dot_number,csa.docket)        AS tmwstatus_SMS_CSA
        , csa.sms_cntrl_prcnt                                     AS sms_cntrl_prcnt
        , csa.sms_cntrl_alert                                     AS sms_cntrl_alert
        , csa.sms_cntrl_violation                                 AS sms_cntrl_violation
        , csa.sms_cntrl_indicator                                 AS sms_cntrl_indicator
        , dbo.fn_GetCarrierCSAStatus('SMS_VEHICLE',csa.cas_dot_number,csa.docket)    AS tmwstatus_SMS_VEHICLE
        , csa.sms_veh_prcnt                                       AS sms_veh_prcnt
        , csa.sms_veh_alert                                       AS sms_veh_alert
        , csa.sms_veh_violation                                   AS sms_veh_violation
        , csa.sms_veh_indicator                                   AS sms_veh_indicator
        , csa.lastupdatedate                                      AS lastupdatedate
        , csa.cas_last_update                                     AS cas_last_update
        , csa.lastupdateprovidername                              AS lastupdateprovidername
        , IsNull(c.car_411_monitored,'N')                         AS car_411_monitored
        , IsNull(c.car_CarrierWatch_monitored,'N')                AS car_CarrierWatch_monitored
     FROM CarrierCsa csa
     LEFT OUTER JOIN carrier c ON csa.cas_dot_number = c.car_dotnum
    WHERE csa.docket = @as_docket 

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetCarrierCSA] TO [public]
GO
