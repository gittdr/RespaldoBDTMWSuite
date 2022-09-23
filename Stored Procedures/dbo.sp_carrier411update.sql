SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_carrier411update]
( @BATCH_ID   INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_carrier411update
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to add/update rows in table CarrierCSA table
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @BATCH_ID   INT
 *
 * REVISION HISTORY:
 * PTS 59346 SPN Created 11/04/11
 * PTS 73825 SPN Changed 12/04/13
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @method                     VARCHAR(50)
   DECLARE @msg                        VARCHAR(1000)

   DECLARE @t_count                    INT
   DECLARE @t_id                       INT
   DECLARE @CarrierCSALogHdr_id        INT
   DECLARE @CarrierCSALogDtl_id        INT
   DECLARE @carrier411wslog_id         INT

   DECLARE @docket                     CHAR(8)
   DECLARE @FMCSALEGALNAME             VARCHAR(120)
   DECLARE @FMCSADBANAME               VARCHAR(60)
   DECLARE @FMCSABUSADDRESS            VARCHAR(50)
   DECLARE @FMCSABUSCITY               VARCHAR(30)
   DECLARE @FMCSABUSSTATE              CHAR(2)
   DECLARE @FMCSABUSZIP                VARCHAR(10)
   DECLARE @FMCSABUSCOUNTRY            CHAR(2)
   DECLARE @FMCSABUSPHONE              VARCHAR(14)
   DECLARE @FMCSABUSFAX                VARCHAR(14)
   DECLARE @SAFETYRATING               CHAR(1)
   DECLARE @SAFETYRATEDATE             DATETIME
   DECLARE @FMCSABROKER                CHAR(1)
   DECLARE @FMCSAPENDINGBROKER         CHAR(1)
   DECLARE @FMCSAREVOKINGBROKER        CHAR(1)
   DECLARE @FMCSACOMMON                CHAR(1)
   DECLARE @FMCSAPENDINGCOMMON         CHAR(1)
   DECLARE @FMCSAREVOKINGCOMMON        CHAR(1)
   DECLARE @FMCSACONTRACT              CHAR(1)
   DECLARE @FMCSAPENDINGCONTRACT       CHAR(1)
   DECLARE @FMCSAREVOKINGCONTRACT      CHAR(1)
   DECLARE @FMCSACARGOREQUIRED         CHAR(1)
   DECLARE @FMCSACARGOFILED            CHAR(1)
   DECLARE @FMCSABONDREQUIRED          CHAR(1)
   DECLARE @FMCSABONDFILED             CHAR(1)
   DECLARE @FMCSABIPDREQUIRED          INT
   DECLARE @FMCSABIPDFILED             INT
   DECLARE @FMCSADOTNUMBER             INT
   DECLARE @FMCSADATELASTUPDATED       DATETIME
   DECLARE @SMSINSPTOTAL               INT
   DECLARE @SMSDRIVINSPTOTAL           INT
   DECLARE @SMSDRIVOOSINSPTOTAL        INT
   DECLARE @SMSVEHINSPTOTAL            INT
   DECLARE @SMSVEHOOSINSPTOTAL         INT
   DECLARE @SMSUNSAFEDRIVPCT           DECIMAL(4,1)
   DECLARE @SMSUNSAFEDRIVBASICALERT    CHAR(1)
   DECLARE @SMSUNSAFEDRIVSV            CHAR(1)
   DECLARE @SMSUNSAFEDRIVRDALERT       CHAR(1)
   DECLARE @SMSFATIGUEDRIVPCT          DECIMAL(4,1)
   DECLARE @SMSFATIGUEDRIVBASICALERT   CHAR(1)
   DECLARE @SMSFATIGUEDRIVSV           CHAR(1)
   DECLARE @SMSFATIGUEDRIVRDALERT      CHAR(1)
   DECLARE @SMSDRIVFITPCT              DECIMAL(4,1)
   DECLARE @SMSDRIVFITBASICALERT       CHAR(1)
   DECLARE @SMSDRIVFITSV               CHAR(1)
   DECLARE @SMSDRIVFITRDALERT          CHAR(1)
   DECLARE @SMSCONTRSUBSTPCT           DECIMAL(4,1)
   DECLARE @SMSCONTRSUBSTBASICALERT    CHAR(1)
   DECLARE @SMSCONTRSUBSTSV            CHAR(1)
   DECLARE @SMSCONTRSUBSTRDALERT       CHAR(1)
   DECLARE @SMSVEHMAINTPCT             DECIMAL(4,1)
   DECLARE @SMSVEHMAINTBASICALERT      CHAR(1)
   DECLARE @SMSVEHMAINTSV              CHAR(1)
   DECLARE @SMSVEHMAINTRDALERT         CHAR(1)
   DECLARE @carrier_exists             INT

   --BEGIN PTS73825 SPN
   DECLARE @PreProcess TABLE
   ( car_id VARCHAR(8)
   , docket VARCHAR(12)
   )
   --END PTS73825 SPN

   CREATE TABLE #t_data
   ( t_id                       INT    IDENTITY NOT NULL PRIMARY KEY
   , docket                     CHAR(8)         NOT NULL
   , FMCSALEGALNAME             VARCHAR(120)    NULL
   , FMCSADBANAME               VARCHAR(60)     NULL
   , FMCSABUSADDRESS            VARCHAR(50)     NULL
   , FMCSABUSCITY               VARCHAR(30)     NULL
   , FMCSABUSSTATE              CHAR(2)         NULL
   , FMCSABUSZIP                VARCHAR(10)     NULL
   , FMCSABUSCOUNTRY            CHAR(2)         NULL
   , FMCSABUSPHONE              VARCHAR(14)     NULL
   , FMCSABUSFAX                VARCHAR(14)     NULL
   , SAFETYRATING               CHAR(1)         NULL
   , SAFETYRATEDATE             DATETIME        NULL
   , FMCSABROKER                CHAR(1)         NULL
   , FMCSAPENDINGBROKER         CHAR(1)         NULL
   , FMCSAREVOKINGBROKER        CHAR(1)         NULL
   , FMCSACOMMON                CHAR(1)         NULL
   , FMCSAPENDINGCOMMON         CHAR(1)         NULL
   , FMCSAREVOKINGCOMMON        CHAR(1)         NULL
   , FMCSACONTRACT              CHAR(1)         NULL
   , FMCSAPENDINGCONTRACT       CHAR(1)         NULL
   , FMCSAREVOKINGCONTRACT      CHAR(1)         NULL
   , FMCSACARGOREQUIRED         CHAR(1)         NULL
   , FMCSACARGOFILED            CHAR(1)         NULL
   , FMCSABONDREQUIRED          CHAR(1)         NULL
   , FMCSABONDFILED             CHAR(1)         NULL
   , FMCSABIPDREQUIRED          INT             NULL
   , FMCSABIPDFILED             INT             NULL
   , FMCSADOTNUMBER             INT             NULL
   , FMCSADATELASTUPDATED       DATETIME        NULL
   , SMSINSPTOTAL               INT             NULL
   , SMSDRIVINSPTOTAL           INT             NULL
   , SMSDRIVOOSINSPTOTAL        INT             NULL
   , SMSVEHINSPTOTAL            INT             NULL
   , SMSVEHOOSINSPTOTAL         INT             NULL
   , SMSUNSAFEDRIVPCT           DECIMAL(4,1)    NULL
   , SMSUNSAFEDRIVBASICALERT    CHAR(1)         NULL
   , SMSUNSAFEDRIVSV            CHAR(1)         NULL
   , SMSUNSAFEDRIVRDALERT       CHAR(1)         NULL
   , SMSFATIGUEDRIVPCT          DECIMAL(4,1)    NULL
   , SMSFATIGUEDRIVBASICALERT   CHAR(1)         NULL
   , SMSFATIGUEDRIVSV           CHAR(1)         NULL
   , SMSFATIGUEDRIVRDALERT      CHAR(1)         NULL
   , SMSDRIVFITPCT              DECIMAL(4,1)    NULL
   , SMSDRIVFITBASICALERT       CHAR(1)         NULL
   , SMSDRIVFITSV               CHAR(1)         NULL
   , SMSDRIVFITRDALERT          CHAR(1)         NULL
   , SMSCONTRSUBSTPCT           DECIMAL(4,1)    NULL
   , SMSCONTRSUBSTBASICALERT    CHAR(1)         NULL
   , SMSCONTRSUBSTSV            CHAR(1)         NULL
   , SMSCONTRSUBSTRDALERT       CHAR(1)         NULL
   , SMSVEHMAINTPCT             DECIMAL(4,1)    NULL
   , SMSVEHMAINTBASICALERT      CHAR(1)         NULL
   , SMSVEHMAINTSV              CHAR(1)         NULL
   , SMSVEHMAINTRDALERT         CHAR(1)         NULL
   )

   --CSALog
   EXEC dbo.sp_CarrierCSALogHdr 'Carrier411', @CarrierCSALogHdr_id OUT
   UPDATE carrier411ws
      SET CarrierCSALogHdr_id = @CarrierCSALogHdr_id
    WHERE BATCH_ID = @BATCH_ID

   EXEC sp_carrier411_write_log @BATCH_ID, '0', '*** Begin Update ***'

   BEGIN TRY

      SELECT @method = method
        FROM carrier411ws
       WHERE BATCH_ID = @BATCH_ID

      --Full Update starts with a complete clean
      IF @method = 'DownloadAllCompanies' OR @method = 'ExcelImport'
      BEGIN
         EXEC sp_carrier411_write_log @BATCH_ID, '0', '*** Begin Truncate ***'
         DELETE CarrierCSA
           FROM CarrierCSA cs
           JOIN fn_CarrierCsaDocketLastUpdate('') l ON cs.docket = l.docket
                                                   AND l.providername = 'Carrier411'
         UPDATE carrier
            SET car_411_monitored = 'N'
         EXEC sp_carrier411_write_log @BATCH_ID, '0', '*** End Truncate ***'
      END

      --BEGIN PTS 73825 SPN
      IF @method = 'FullUpdateCompanies'
      BEGIN
         INSERT INTO @PreProcess
         ( car_id
         , docket
         )
         SELECT c.car_id
              , c.car_iccnum
           FROM carrier c
           JOIN CarrierCSA cs ON c.car_iccnum = cs.docket
           LEFT OUTER JOIN (SELECT DISTINCT docket
                              FROM carrier411data
                             WHERE BATCH_ID = @BATCH_ID
                               AND submethod = 'checkallsafety'
                           ) cd ON c.car_iccnum = cd.docket
          WHERE c.car_iccnum IS NOT NULL
            AND c.car_iccnum <> ''
            AND cd.docket IS NULL

         UPDATE CarrierCSA
            SET cas_safety_rating = NULL
           FROM CarrierCSA cs
           JOIN @PreProcess pp ON cs.docket = pp.docket

         DELETE FROM expiration
          WHERE IsNull(exp_completed,'N') = 'N'
            AND exp_source = 'CARRIER411'
            AND exp_idtype = 'CAR'
            AND exp_id in (SELECT car_id from @PreProcess)
      END
      --END PTS 73825 SPN

      INSERT INTO #t_data
      ( docket
      , FMCSALEGALNAME
      , FMCSADBANAME
      , FMCSABUSADDRESS
      , FMCSABUSCITY
      , FMCSABUSSTATE
      , FMCSABUSZIP
      , FMCSABUSCOUNTRY
      , FMCSABUSPHONE
      , FMCSABUSFAX
      , SAFETYRATING
      , SAFETYRATEDATE
      , FMCSABROKER
      , FMCSAPENDINGBROKER
      , FMCSAREVOKINGBROKER
      , FMCSACOMMON
      , FMCSAPENDINGCOMMON
      , FMCSAREVOKINGCOMMON
      , FMCSACONTRACT
      , FMCSAPENDINGCONTRACT
      , FMCSAREVOKINGCONTRACT
      , FMCSACARGOREQUIRED
      , FMCSACARGOFILED
      , FMCSABONDREQUIRED
      , FMCSABONDFILED
      , FMCSABIPDREQUIRED
      , FMCSABIPDFILED
      , FMCSADOTNUMBER
      , FMCSADATELASTUPDATED
      , SMSINSPTOTAL
      , SMSDRIVINSPTOTAL
      , SMSDRIVOOSINSPTOTAL
      , SMSVEHINSPTOTAL
      , SMSVEHOOSINSPTOTAL
      , SMSUNSAFEDRIVPCT
      , SMSUNSAFEDRIVBASICALERT
      , SMSUNSAFEDRIVSV
      , SMSUNSAFEDRIVRDALERT
      , SMSFATIGUEDRIVPCT
      , SMSFATIGUEDRIVBASICALERT
      , SMSFATIGUEDRIVSV
      , SMSFATIGUEDRIVRDALERT
      , SMSDRIVFITPCT
      , SMSDRIVFITBASICALERT
      , SMSDRIVFITSV
      , SMSDRIVFITRDALERT
      , SMSCONTRSUBSTPCT
      , SMSCONTRSUBSTBASICALERT
      , SMSCONTRSUBSTSV
      , SMSCONTRSUBSTRDALERT
      , SMSVEHMAINTPCT
      , SMSVEHMAINTBASICALERT
      , SMSVEHMAINTSV
      , SMSVEHMAINTRDALERT
      )
      SELECT c.docket
           , c.FMCSALEGALNAME
           , c.FMCSADBANAME
           , c.FMCSABUSADDRESS
           , c.FMCSABUSCITY
           , c.FMCSABUSSTATE
           , c.FMCSABUSZIP
           , c.FMCSABUSCOUNTRY
           , c.FMCSABUSPHONE
           , c.FMCSABUSFAX
           , c.SAFETYRATING
           , c.SAFETYRATEDATE
           , c.FMCSABROKER
           , c.FMCSAPENDINGBROKER
           , c.FMCSAREVOKINGBROKER
           , c.FMCSACOMMON
           , c.FMCSAPENDINGCOMMON
           , c.FMCSAREVOKINGCOMMON
           , c.FMCSACONTRACT
           , c.FMCSAPENDINGCONTRACT
           , c.FMCSAREVOKINGCONTRACT
           , c.FMCSACARGOREQUIRED
           , c.FMCSACARGOFILED
           , c.FMCSABONDREQUIRED
           , c.FMCSABONDFILED
           , c.FMCSABIPDREQUIRED
           , c.FMCSABIPDFILED
           , c.FMCSADOTNUMBER
           , c.FMCSADATELASTUPDATED
           , c.SMSINSPTOTAL
           , c.SMSDRIVINSPTOTAL
           , c.SMSDRIVOOSINSPTOTAL
           , c.SMSVEHINSPTOTAL
           , c.SMSVEHOOSINSPTOTAL
           , c.SMSUNSAFEDRIVPCT
           , c.SMSUNSAFEDRIVBASICALERT
           , c.SMSUNSAFEDRIVSV
           , c.SMSUNSAFEDRIVRDALERT
           , c.SMSFATIGUEDRIVPCT
           , c.SMSFATIGUEDRIVBASICALERT
           , c.SMSFATIGUEDRIVSV
           , c.SMSFATIGUEDRIVRDALERT
           , c.SMSDRIVFITPCT
           , c.SMSDRIVFITBASICALERT
           , c.SMSDRIVFITSV
           , c.SMSDRIVFITRDALERT
           , c.SMSCONTRSUBSTPCT
           , c.SMSCONTRSUBSTBASICALERT
           , c.SMSCONTRSUBSTSV
           , c.SMSCONTRSUBSTRDALERT
           , c.SMSVEHMAINTPCT
           , c.SMSVEHMAINTBASICALERT
           , c.SMSVEHMAINTSV
           , c.SMSVEHMAINTRDALERT
        FROM carrier411data c
       WHERE c.BATCH_ID = @BATCH_ID

      SELECT @t_count = COUNT(1)
        FROM #t_data

      SELECT @msg = 'Rows to be processed: ' + Convert(Varchar,@t_count)
      EXEC sp_carrier411_write_log @BATCH_ID, '0', @msg

      SELECT @t_id = 0

      SELECT @msg = 'Updating row 0 of ' + Convert(Varchar,@t_count)
      INSERT INTO carrier411wslog(BATCH_ID, FaultCode, FaultMessage)
      VALUES(@BATCH_ID,'0',@msg)
      SELECT @carrier411wslog_id = Max(id)
        FROM carrier411wslog
       WHERE BATCH_ID = @BATCH_ID
         AND FaultMessage Like 'Updating row %'

      WHILE @t_id < @t_count
      BEGIN
         SELECT @t_id = @t_id + 1

         If @carrier411wslog_id IS NOT NULL AND @carrier411wslog_id <> 0
         BEGIN
            SELECT @msg = 'Updating row ' + Convert(Varchar,@t_id) + ' of ' + Convert(Varchar,@t_count)
            UPDATE carrier411wslog
               SET FaultMessage = @msg
             WHERE id = @carrier411wslog_id
         END

         SELECT @docket                    =  c.docket
              , @FMCSALEGALNAME            =  IsNull(c.FMCSALEGALNAME,cs.cas_legal_name)
              , @FMCSADBANAME              =  IsNull(c.FMCSADBANAME,cs.cas_dba_name)
              , @FMCSABUSADDRESS           =  IsNull(c.FMCSABUSADDRESS,cs.cas_business_address)
              , @FMCSABUSCITY              =  IsNull(c.FMCSABUSCITY,cs.cas_business_city)
              , @FMCSABUSSTATE             =  IsNull(c.FMCSABUSSTATE,cs.cas_business_state)
              , @FMCSABUSZIP               =  IsNull(c.FMCSABUSZIP,cs.cas_business_zip)
              , @FMCSABUSCOUNTRY           =  IsNull(c.FMCSABUSCOUNTRY,cs.cas_business_country)
              , @FMCSABUSPHONE             =  IsNull(c.FMCSABUSPHONE,cs.cas_business_phone)
              , @FMCSABUSFAX               =  IsNull(c.FMCSABUSFAX,cs.cas_business_fax)
              , @SAFETYRATING              =  IsNull(c.SAFETYRATING,cs.cas_safety_rating)
              , @SAFETYRATEDATE            =  IsNull(c.SAFETYRATEDATE,cs.cas_rate_date)
              , @FMCSABROKER               =  IsNull(c.FMCSABROKER,cs.cas_authority_broker_status)
              , @FMCSAPENDINGBROKER        =  IsNull(c.FMCSAPENDINGBROKER,cs.cas_authority_broker_app_pending)
              , @FMCSAREVOKINGBROKER       =  IsNull(c.FMCSAREVOKINGBROKER,cs.cas_authority_broker_revocation_pending)
              , @FMCSACOMMON               =  IsNull(c.FMCSACOMMON,cs.cas_authority_common_status)
              , @FMCSAPENDINGCOMMON        =  IsNull(c.FMCSAPENDINGCOMMON,cs.cas_authority_common_app_pending)
              , @FMCSAREVOKINGCOMMON       =  IsNull(c.FMCSAREVOKINGCOMMON,cs.cas_authority_common_revocation_pending)
              , @FMCSACONTRACT             =  IsNull(c.FMCSACONTRACT,cs.cas_authority_contract_status)
              , @FMCSAPENDINGCONTRACT      =  IsNull(c.FMCSAPENDINGCONTRACT,cs.cas_authority_contract_app_pending)
              , @FMCSAREVOKINGCONTRACT     =  IsNull(c.FMCSAREVOKINGCONTRACT,cs.cas_authority_contract_revocation_pending)
              , @FMCSACARGOREQUIRED        =  IsNull(c.FMCSACARGOREQUIRED,cs.cas_insurance_cargo_required)
              , @FMCSACARGOFILED           =  IsNull(c.FMCSACARGOFILED,cs.cas_insurance_cargo_filed)
              , @FMCSABONDREQUIRED         =  IsNull(c.FMCSABONDREQUIRED,cs.cas_insurance_bond_required)
              , @FMCSABONDFILED            =  IsNull(c.FMCSABONDFILED,cs.cas_insurance_bond_filed)
              , @FMCSABIPDREQUIRED         =  IsNull(c.FMCSABIPDREQUIRED,cs.cas_insurance_bipd_required)
              , @FMCSABIPDFILED            =  IsNull(c.FMCSABIPDFILED,cs.cas_insurance_bipd_filed)
              , @FMCSADOTNUMBER            =  IsNull(c.FMCSADOTNUMBER,cs.cas_dot_number)
              , @SMSINSPTOTAL              =  IsNull(c.SMSINSPTOTAL,cs.sms_insp_total)
              , @SMSDRIVINSPTOTAL          =  IsNull(c.SMSDRIVINSPTOTAL,cs.sms_driver_insp_total)
              , @SMSDRIVOOSINSPTOTAL       =  IsNull(c.SMSDRIVOOSINSPTOTAL,cs.sms_driver_oos_insp_total)
              , @SMSVEHINSPTOTAL           =  IsNull(c.SMSVEHINSPTOTAL,cs.sms_vehicle_insp_total)
              , @SMSVEHOOSINSPTOTAL        =  IsNull(c.SMSVEHOOSINSPTOTAL,cs.sms_vehicle_oos_insp_total)
              , @SMSUNSAFEDRIVPCT          =  IsNull(c.SMSUNSAFEDRIVPCT,cs.sms_unsafe_prcnt)
              , @SMSUNSAFEDRIVBASICALERT   =  IsNull(c.SMSUNSAFEDRIVBASICALERT,cs.sms_unsafe_alert)
              , @SMSUNSAFEDRIVSV           =  IsNull(c.SMSUNSAFEDRIVSV,cs.sms_unsafe_violation)
              , @SMSUNSAFEDRIVRDALERT      =  IsNull(c.SMSUNSAFEDRIVRDALERT,cs.sms_unsafe_indicator)
              , @SMSFATIGUEDRIVPCT         =  IsNull(c.SMSFATIGUEDRIVPCT,cs.sms_fatig_prcnt)
              , @SMSFATIGUEDRIVBASICALERT  =  IsNull(c.SMSFATIGUEDRIVBASICALERT,cs.sms_fatig_alert)
              , @SMSFATIGUEDRIVSV          =  IsNull(c.SMSFATIGUEDRIVSV,cs.sms_fatig_violation)
              , @SMSFATIGUEDRIVRDALERT     =  IsNull(c.SMSFATIGUEDRIVRDALERT,cs.sms_fatig_indicator)
              , @SMSDRIVFITPCT             =  IsNull(c.SMSDRIVFITPCT,cs.sms_fit_prcnt)
              , @SMSDRIVFITBASICALERT      =  IsNull(c.SMSDRIVFITBASICALERT,cs.sms_fit_alert)
              , @SMSDRIVFITSV              =  IsNull(c.SMSDRIVFITSV,cs.sms_fit_violation)
              , @SMSDRIVFITRDALERT         =  IsNull(c.SMSDRIVFITRDALERT,cs.sms_fit_indicator)
              , @SMSCONTRSUBSTPCT          =  IsNull(c.SMSCONTRSUBSTPCT,cs.sms_cntrl_prcnt)
              , @SMSCONTRSUBSTBASICALERT   =  IsNull(c.SMSCONTRSUBSTBASICALERT,cs.sms_cntrl_alert)
              , @SMSCONTRSUBSTSV           =  IsNull(c.SMSCONTRSUBSTSV,cs.sms_cntrl_violation)
              , @SMSCONTRSUBSTRDALERT      =  IsNull(c.SMSCONTRSUBSTRDALERT,cs.sms_cntrl_indicator)
              , @SMSVEHMAINTPCT            =  IsNull(c.SMSVEHMAINTPCT,cs.sms_veh_prcnt)
              , @SMSVEHMAINTBASICALERT     =  IsNull(c.SMSVEHMAINTBASICALERT,cs.sms_veh_alert)
              , @SMSVEHMAINTSV             =  IsNull(c.SMSVEHMAINTSV,cs.sms_veh_violation)
              , @SMSVEHMAINTRDALERT        =  IsNull(c.SMSVEHMAINTRDALERT,cs.sms_veh_indicator)
              , @FMCSADATELASTUPDATED      =  IsNull(c.FMCSADATELASTUPDATED,cs.cas_last_update)
              , @carrier_exists            =  (CASE WHEN cs.docket IS NULL THEN 0 ELSE 1 END)
           FROM #t_data c
           LEFT OUTER JOIN CarrierCSA cs ON c.docket = cs.docket
          WHERE c.t_id = @t_id

         --CSA Log Dtl
         EXECUTE dbo.sp_CarrierCSALogDtl @CarrierCSALogHdr_id, @docket, @CarrierCSALogDtl_id OUT

         --Insert
         IF @carrier_exists = 0
            BEGIN
               INSERT INTO CarrierCSA
               ( docket
               , CarrierCSALogDtl_id
               , cas_legal_name
               , cas_dba_name
               , cas_business_address
               , cas_business_city
               , cas_business_state
               , cas_business_zip
               , cas_business_country
               , cas_business_phone
               , cas_business_fax
               , cas_safety_rating
               , cas_rate_date
               , cas_authority_broker_status
               , cas_authority_broker_app_pending
               , cas_authority_broker_revocation_pending
               , cas_authority_common_status
               , cas_authority_common_app_pending
               , cas_authority_common_revocation_pending
               , cas_authority_contract_status
               , cas_authority_contract_app_pending
               , cas_authority_contract_revocation_pending
               , cas_insurance_cargo_required
               , cas_insurance_cargo_filed
               , cas_insurance_bond_required
               , cas_insurance_bond_filed
               , cas_insurance_bipd_required
               , cas_insurance_bipd_filed
               , cas_dot_number
               , sms_insp_total
               , sms_driver_insp_total
               , sms_driver_oos_insp_total
               , sms_vehicle_insp_total
               , sms_vehicle_oos_insp_total
               , sms_unsafe_prcnt
               , sms_unsafe_alert
               , sms_unsafe_violation
               , sms_unsafe_indicator
               , sms_fatig_prcnt
               , sms_fatig_alert
               , sms_fatig_violation
               , sms_fatig_indicator
               , sms_fit_prcnt
               , sms_fit_alert
               , sms_fit_violation
               , sms_fit_indicator
               , sms_cntrl_prcnt
               , sms_cntrl_alert
               , sms_cntrl_violation
               , sms_cntrl_indicator
               , sms_veh_prcnt
               , sms_veh_alert
               , sms_veh_violation
               , sms_veh_indicator
               , cas_last_update
               , lastupdateprovidername
               )
               VALUES
               ( @docket
               , @CarrierCSALogDtl_id
               , @FMCSALEGALNAME
               , @FMCSADBANAME
               , @FMCSABUSADDRESS
               , @FMCSABUSCITY
               , @FMCSABUSSTATE
               , @FMCSABUSZIP
               , @FMCSABUSCOUNTRY
               , @FMCSABUSPHONE
               , @FMCSABUSFAX
               , @SAFETYRATING
               , @SAFETYRATEDATE
               , @FMCSABROKER
               , @FMCSAPENDINGBROKER
               , @FMCSAREVOKINGBROKER
               , @FMCSACOMMON
               , @FMCSAPENDINGCOMMON
               , @FMCSAREVOKINGCOMMON
               , @FMCSACONTRACT
               , @FMCSAPENDINGCONTRACT
               , @FMCSAREVOKINGCONTRACT
               , @FMCSACARGOREQUIRED
               , @FMCSACARGOFILED
               , @FMCSABONDREQUIRED
               , @FMCSABONDFILED
               , @FMCSABIPDREQUIRED
               , @FMCSABIPDFILED
               , @FMCSADOTNUMBER
               , @SMSINSPTOTAL
               , @SMSDRIVINSPTOTAL
               , @SMSDRIVOOSINSPTOTAL
               , @SMSVEHINSPTOTAL
               , @SMSVEHOOSINSPTOTAL
               , @SMSUNSAFEDRIVPCT
               , @SMSUNSAFEDRIVBASICALERT
               , @SMSUNSAFEDRIVSV
               , @SMSUNSAFEDRIVRDALERT
               , @SMSFATIGUEDRIVPCT
               , @SMSFATIGUEDRIVBASICALERT
               , @SMSFATIGUEDRIVSV
               , @SMSFATIGUEDRIVRDALERT
               , @SMSDRIVFITPCT
               , @SMSDRIVFITBASICALERT
               , @SMSDRIVFITSV
               , @SMSDRIVFITRDALERT
               , @SMSCONTRSUBSTPCT
               , @SMSCONTRSUBSTBASICALERT
               , @SMSCONTRSUBSTSV
               , @SMSCONTRSUBSTRDALERT
               , @SMSVEHMAINTPCT
               , @SMSVEHMAINTBASICALERT
               , @SMSVEHMAINTSV
               , @SMSVEHMAINTRDALERT
               , @FMCSADATELASTUPDATED
               , 'Carrier411'
               )
            END
         ELSE
         --Update
            BEGIN
               UPDATE CarrierCSA
                  SET CarrierCSALogDtl_id                         = @CarrierCSALogDtl_id
                    , cas_legal_name                              = @FMCSALEGALNAME
                    , cas_dba_name                                = @FMCSADBANAME
                    , cas_business_address                        = @FMCSABUSADDRESS
                    , cas_business_city                           = @FMCSABUSCITY
                    , cas_business_state                          = @FMCSABUSSTATE
                    , cas_business_zip                            = @FMCSABUSZIP
                    , cas_business_country                        = @FMCSABUSCOUNTRY
                    , cas_business_phone                          = @FMCSABUSPHONE
                    , cas_business_fax                            = @FMCSABUSFAX
                    , cas_safety_rating                           = @SAFETYRATING
                    , cas_rate_date                               = @SAFETYRATEDATE
                    , cas_authority_broker_status                 = @FMCSABROKER
                    , cas_authority_broker_app_pending            = @FMCSAPENDINGBROKER
                    , cas_authority_broker_revocation_pending     = @FMCSAREVOKINGBROKER
                    , cas_authority_common_status                 = @FMCSACOMMON
                    , cas_authority_common_app_pending            = @FMCSAPENDINGCOMMON
                    , cas_authority_common_revocation_pending     = @FMCSAREVOKINGCOMMON
                    , cas_authority_contract_status               = @FMCSACONTRACT
                    , cas_authority_contract_app_pending          = @FMCSAPENDINGCONTRACT
                    , cas_authority_contract_revocation_pending   = @FMCSAREVOKINGCONTRACT
                    , cas_insurance_cargo_required                = @FMCSACARGOREQUIRED
                    , cas_insurance_cargo_filed                   = @FMCSACARGOFILED
                    , cas_insurance_bond_required                 = @FMCSABONDREQUIRED
                    , cas_insurance_bond_filed                    = @FMCSABONDFILED
                    , cas_insurance_bipd_required                 = @FMCSABIPDREQUIRED
                    , cas_insurance_bipd_filed                    = @FMCSABIPDFILED
                    , cas_dot_number                              = @FMCSADOTNUMBER
                    , sms_insp_total                              = @SMSINSPTOTAL
                    , sms_driver_insp_total                       = @SMSDRIVINSPTOTAL
                    , sms_driver_oos_insp_total                   = @SMSDRIVOOSINSPTOTAL
                    , sms_vehicle_insp_total                      = @SMSVEHINSPTOTAL
                    , sms_vehicle_oos_insp_total                  = @SMSVEHOOSINSPTOTAL
                    , sms_unsafe_prcnt                            = @SMSUNSAFEDRIVPCT
                    , sms_unsafe_alert                            = @SMSUNSAFEDRIVBASICALERT
                    , sms_unsafe_violation                        = @SMSUNSAFEDRIVSV
                    , sms_unsafe_indicator                        = @SMSUNSAFEDRIVRDALERT
                    , sms_fatig_prcnt                             = @SMSFATIGUEDRIVPCT
                    , sms_fatig_alert                             = @SMSFATIGUEDRIVBASICALERT
                    , sms_fatig_violation                         = @SMSFATIGUEDRIVSV
                    , sms_fatig_indicator                         = @SMSFATIGUEDRIVRDALERT
                    , sms_fit_prcnt                               = @SMSDRIVFITPCT
                    , sms_fit_alert                               = @SMSDRIVFITBASICALERT
                    , sms_fit_violation                           = @SMSDRIVFITSV
                    , sms_fit_indicator                           = @SMSDRIVFITRDALERT
                    , sms_cntrl_prcnt                             = @SMSCONTRSUBSTPCT
                    , sms_cntrl_alert                             = @SMSCONTRSUBSTBASICALERT
                    , sms_cntrl_violation                         = @SMSCONTRSUBSTSV
                    , sms_cntrl_indicator                         = @SMSCONTRSUBSTRDALERT
                    , sms_veh_prcnt                               = @SMSVEHMAINTPCT
                    , sms_veh_alert                               = @SMSVEHMAINTBASICALERT
                    , sms_veh_violation                           = @SMSVEHMAINTSV
                    , sms_veh_indicator                           = @SMSVEHMAINTRDALERT
                    , cas_last_update                             = @FMCSADATELASTUPDATED
                    , lastupdateprovidername                      = 'Carrier411'
                WHERE docket = @docket
            END

         --Set Monitor flag
         EXEC sp_carrier411updateMonitored @docket, 'Y'
      END

   END TRY
   BEGIN CATCH
      SELECT @msg = 'Update Error: ' + error_message()
      EXEC sp_carrier411_write_log @BATCH_ID, '0', @msg
   END CATCH

   SELECT @msg = '*** End Update ***'
   EXEC sp_carrier411_write_log @BATCH_ID, '0', @msg

   DROP TABLE #t_data

   --Update Expirations
   SELECT @msg = '*** Begin Expiration ***'
   EXEC sp_carrier411_write_log @BATCH_ID, '0', @msg

   EXEC sp_carriercsa_generate_expiration @CarrierCSALogHdr_id

   SELECT @msg = '*** End Expiration ***'
   EXEC sp_carrier411_write_log @BATCH_ID, '0', @msg

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_carrier411update] TO [public]
GO
