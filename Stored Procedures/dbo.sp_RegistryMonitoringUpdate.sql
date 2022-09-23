SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[sp_RegistryMonitoringUpdate]
( @TmwXmlImportLog_id   INT
)
AS

/**
 *
 * NAME:
 * dbo.sp_RegistryMonitoringUpdate
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
 * @TmwXmlImportLog_id   INT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/18/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @msg                        VARCHAR(1000)

   DECLARE @t_count                    INT
   DECLARE @t_id                       INT
   DECLARE @TmwXmlImportLogError_id    INT
   DECLARE @CarrierCSALogHdr_id        INT
   DECLARE @CarrierCSALogDtl_id        INT

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
   DECLARE @FMCSADATELASTUPDATED       DATETIME
   DECLARE @carrier_exists             INT

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
   , FMCSADATELASTUPDATED       DATETIME        NULL
   )

   --CSA Log
   EXEC dbo.sp_CarrierCSALogHdr 'RegistryMonitoring', @CarrierCSALogHdr_id OUT
   UPDATE TmwXmlImportLog
      SET CarrierCSALogHdr_id = @CarrierCSALogHdr_id
    WHERE id = @TmwXmlImportLog_id

   SELECT @msg = '*** Begin Update ***'
   EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg

   BEGIN TRY

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
      )
      SELECT dbo.fn_GetDocketByRootElementID(TmwXmlImportLog_id, RootElementID)
           , dot_LegalName
           , dot_DBAName
           , dot_Business_Addr
           , dot_Business_City
           , dot_Business_St
           , dot_Business_Zip
           , dot_Business_Country
           , dot_Business_Phone
           , dot_Business_Fax
           , dot_BrokerAuthority
           , dot_PendingBrokerAuthority
           , dot_BrokerAuthorityRevocation
           , dot_CommonAuthority
           , dot_PendingCommonAuthority
           , dot_CommonAuthRevocation
           , dot_ContractAuthority
           , dot_PendingContractAuthority
           , dot_ContractAuthRevocation
           , dot_CargoRequired
           , dot_CargoOnFile
           , dot_BondSuretyRequired
           , dot_BondSuretyOnFile
           , dot_BIPDRequired
           , dot_BIPDOnFile
           , dot_USDOTNumber
           , dot_DateLastUpdated
        FROM RMXML_DOT
       WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id

      INSERT INTO #t_data
      ( docket
      , SAFETYRATING
      , SAFETYRATEDATE
      )
      SELECT dbo.fn_GetDocketByRootElementID(TmwXmlImportLog_id, RootElementID)
           , Left(SafetyRating,1)
           , SafetyRatingDate
        FROM RMXML_DOTTestingInfo
       WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id

      INSERT INTO #t_data
      ( docket
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
      SELECT dbo.fn_GetDocketByRootElementID(TmwXmlImportLog_id, RootElementID)
           , dotSmsSafety_InspTotal
           , dotSmsSafety_DriverInspTotal
           , dotSmsSafety_DriverOosInspTotal
           , dotSmsSafety_VehicleInspTotal
           , dotSmsSafety_VehicleOosInspTotal
           , dotSmsSafety_UnsafeDrivingPercentile
           , dotSmsSafety_UnsafeDrivingBasicAlert
           , dotSmsSafety_UnsafeDrivingSeriousViolation
           , dotSmsSafety_UnsafeDrivingRoadsideAlert
           , dotSmsSafety_FatiguedDrivingPercentile
           , dotSmsSafety_FatiguedDrivingBasicAlert
           , dotSmsSafety_FatiguedDrivingSeriousViolation
           , dotSmsSafety_FatiguedUnsafeDrivingRoadsideAlert
           , dotSmsSafety_DriverFitnessPercentile
           , dotSmsSafety_DriverFitnessBasicAlert
           , dotSmsSafety_DriverFitnessSeriousViolation
           , dotSmsSafety_DriverFitnessDrivingRoadsideAlert
           , dotSmsSafety_ControlledSubstancePercentile
           , dotSmsSafety_ControlledSubstanceBasicAlert
           , dotSmsSafety_ControlledSubstanceSeriousViolation
           , dotSmsSafety_ControlledSubstanceRoadsideAlert
           , dotSmsSafety_VehicleMaintPercentile
           , dotSmsSafety_VehicleMaintBasicAlert
           , dotSmsSafety_VehicleMaintSeriousViolation
           , dotSmsSafety_VehicleMaintRoadsideAlert
        FROM RMXML_DOTSMSSafety
       WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id

      SELECT @t_count = COUNT(1)
        FROM #t_data

      SELECT @t_id = 0

      SELECT @msg = 'Updating row 0 of ' + Convert(Varchar,@t_count)
      EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
      SELECT @TmwXmlImportLogError_id = Max(id)
        FROM TmwXmlImportLogError
       WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id
         AND ErrorInfo Like ('Updating row %')

      WHILE @t_id < @t_count
      BEGIN
         SELECT @t_id = @t_id + 1

         If @TmwXmlImportLogError_id IS NOT NULL AND @TmwXmlImportLogError_id <> 0
         BEGIN
            SELECT @msg = 'Updating row ' + Convert(Varchar,@t_id) + ' of ' + Convert(Varchar,@t_count)
            UPDATE TmwXmlImportLogError
               SET ErrorInfo = @msg
             WHERE id = @TmwXmlImportLogError_id
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
               , 'RegistryMonitoring'
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
                    , lastupdateprovidername                      = 'RegistryMonitoring'
                WHERE docket = @docket
            END

      END

   END TRY
   BEGIN CATCH
      SELECT @msg = 'Update Error: ' + error_message()
      EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
   END CATCH
   SELECT @msg = '*** End Update ***'
   EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg

   DROP TABLE #t_data

   --Update Expirations
   SELECT @msg = '*** Begin Expiration ***'
   EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg

   EXEC sp_carriercsa_generate_expiration @CarrierCSALogHdr_id

   SELECT @msg = '*** End Expiration ***'
   EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_RegistryMonitoringUpdate] TO [public]
GO
