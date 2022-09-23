SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411getcompany]
( @al_batch_id    INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_carrier411getcompany
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to return rows from table carrierstatus and carrier411_sms OR carrier411data
 *
 * RETURNS:
 *
 * RESULTSET
 *
 * PARAMETERS:
 * @al_batch_id      INT
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/08/11
 * PTS 56555 SPN Edited  02/19/13
 *
 **/

SET NOCOUNT ON

BEGIN

   SELECT c.docket                     AS cas_docket_number
        , c.FMCSALEGALNAME             AS cas_legal_name
        , c.FMCSADBANAME               AS cas_dba_name
        , c.FMCSABUSADDRESS            AS cas_business_address
        , c.FMCSABUSCITY               AS cas_business_city
        , c.FMCSABUSSTATE              AS cas_business_state
        , c.FMCSABUSZIP                AS cas_business_zip
        , c.FMCSABUSCOUNTRY            AS cas_business_country
        , c.FMCSABUSPHONE              AS cas_business_phone
        , c.FMCSABUSFAX                AS cas_business_fax
        , c.SAFETYRATING               AS cas_safety_rating
        , c.SAFETYRATEDATE             AS cas_rate_date
        , c.FMCSABROKER                AS cas_authority_broker_status
        , c.FMCSAPENDINGBROKER         AS cas_authority_broker_app_pending
        , c.FMCSAREVOKINGBROKER        AS cas_authority_broker_revocation_pending
        , c.FMCSACOMMON                AS cas_authority_common_status
        , c.FMCSAPENDINGCOMMON         AS cas_authority_common_app_pending
        , c.FMCSAREVOKINGCOMMON        AS cas_authority_common_revocation_pending
        , c.FMCSACONTRACT              AS cas_authority_contract_status
        , c.FMCSAPENDINGCONTRACT       AS cas_authority_contract_app_pending
        , c.FMCSAREVOKINGCONTRACT      AS cas_authority_contract_revocation_pending
        , c.FMCSACARGOREQUIRED         AS cas_insurance_cargo_required
        , c.FMCSACARGOFILED            AS cas_insurance_cargo_filed
        , c.FMCSABONDREQUIRED          AS cas_insurance_bond_required
        , c.FMCSABONDFILED             AS cas_insurance_bond_filed
        , c.FMCSABIPDREQUIRED          AS cas_insurance_bipd_required
        , c.FMCSABIPDFILED             AS cas_insurance_bipd_filed
        , c.FMCSADOTNUMBER             AS cas_dot_number
        , c.SMSINSPTOTAL               AS sms_insp_total
        , c.SMSDRIVINSPTOTAL           AS sms_driver_insp_total
        , c.SMSDRIVOOSINSPTOTAL        AS sms_driver_oos_insp_total
        , c.SMSVEHINSPTOTAL            AS sms_vehicle_insp_total
        , c.SMSVEHOOSINSPTOTAL         AS sms_vehicle_oos_insp_total
        , c.SMSUNSAFEDRIVPCT           AS sms_unsafe_prcnt
        , c.SMSUNSAFEDRIVBASICALERT    AS sms_unsafe_alert
        , c.SMSUNSAFEDRIVSV            AS sms_unsafe_violation
        , c.SMSUNSAFEDRIVRDALERT       AS sms_unsafe_indicator
        , c.SMSFATIGUEDRIVPCT          AS sms_fatig_prcnt
        , c.SMSFATIGUEDRIVBASICALERT   AS sms_fatig_alert
        , c.SMSFATIGUEDRIVSV           AS sms_fatig_violation
        , c.SMSFATIGUEDRIVRDALERT      AS sms_fatig_indicator
        , c.SMSDRIVFITPCT              AS sms_fit_prcnt
        , c.SMSDRIVFITBASICALERT       AS sms_fit_alert
        , c.SMSDRIVFITSV               AS sms_fit_violation
        , c.SMSDRIVFITRDALERT          AS sms_fit_indicator
        , c.SMSCONTRSUBSTPCT           AS sms_cntrl_prcnt
        , c.SMSCONTRSUBSTBASICALERT    AS sms_cntrl_alert
        , c.SMSCONTRSUBSTSV            AS sms_cntrl_violation
        , c.SMSCONTRSUBSTRDALERT       AS sms_cntrl_indicator
        , c.SMSVEHMAINTPCT             AS sms_veh_prcnt
        , c.SMSVEHMAINTBASICALERT      AS sms_veh_alert
        , c.SMSVEHMAINTSV              AS sms_veh_violation
        , c.SMSVEHMAINTRDALERT         AS sms_veh_indicator
        , GetDate()                    AS lastupdatedate
        , c.FMCSADATELASTUPDATED       AS cas_last_update
        , 'Y'                          AS car_411_monitored
     FROM carrier411data c
    WHERE c.BATCH_ID = @al_batch_id

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411getcompany] TO [public]
GO
