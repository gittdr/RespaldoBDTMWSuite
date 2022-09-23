CREATE TABLE [dbo].[CarrierCSA]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[docket] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cas_safety_rating] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_safestat_driver] [decimal] (5, 2) NULL,
[cas_safestat_safety] [decimal] (5, 2) NULL,
[cas_safestat_vehicle] [decimal] (5, 2) NULL,
[cas_authority_broker_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_broker_app_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_broker_revocation_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_common_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_common_app_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_common_revocation_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_contract_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_contract_app_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_authority_contract_revocation_pending] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_insurance_cargo_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_insurance_cargo_filed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_insurance_bond_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_insurance_bond_filed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_insurance_bipd_required] [int] NULL,
[cas_insurance_bipd_filed] [int] NULL,
[cas_legal_name] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_dba_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_city] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_state] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_zip] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_country] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_phone] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_fax] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_rate_date] [datetime] NULL,
[cas_dot_number] [int] NULL,
[sms_insp_total] [int] NULL,
[sms_driver_insp_total] [int] NULL,
[sms_driver_oos_insp_total] [int] NULL,
[sms_vehicle_insp_total] [int] NULL,
[sms_vehicle_oos_insp_total] [int] NULL,
[sms_unsafe_prcnt] [decimal] (5, 2) NULL,
[sms_unsafe_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_unsafe_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_unsafe_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fatig_prcnt] [decimal] (5, 2) NULL,
[sms_fatig_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fatig_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fatig_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fit_prcnt] [decimal] (5, 2) NULL,
[sms_fit_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fit_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_fit_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cntrl_prcnt] [decimal] (5, 2) NULL,
[sms_cntrl_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cntrl_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_cntrl_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_veh_prcnt] [decimal] (5, 2) NULL,
[sms_veh_alert] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_veh_violation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sms_veh_indicator] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_last_update] [datetime] NULL,
[carriercsalogdtl_id] [int] NULL,
[lastupdateprovidername] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__CarrierCS__lastu__60E421A6] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierCS__lastu__61D845DF] DEFAULT (suser_sname()),
[dot_isactive] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastUpdateOfDotProfile] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_carriercsa] ON [dbo].[CarrierCSA]
FOR INSERT,UPDATE
AS

BEGIN

   DECLARE @min_id      INTEGER
         , @tmwuser     VARCHAR(255)

   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @min_id = 0
   WHILE 1 = 1
   BEGIN
      SELECT @min_id = MIN(id)
        FROM inserted
       WHERE id > @min_id

      IF @min_id IS NULL
         BREAK

      UPDATE CarrierCSA
         SET lastupdateuser = @tmwuser
           , lastupdatedate = GetDate()
       WHERE id = @min_id
   END

END
GO
ALTER TABLE [dbo].[CarrierCSA] ADD CONSTRAINT [pk_CarrierCSA] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierCSA_CarrierCSALogDtl_id] ON [dbo].[CarrierCSA] ([carriercsalogdtl_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierCSA_docket] ON [dbo].[CarrierCSA] ([docket]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierCSA] ADD CONSTRAINT [fk_CarrierCSA_CarrierCSALogDtl_id] FOREIGN KEY ([carriercsalogdtl_id]) REFERENCES [dbo].[CarrierCSALogDtl] ([id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[CarrierCSA] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierCSA] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierCSA] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierCSA] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierCSA] TO [public]
GO
