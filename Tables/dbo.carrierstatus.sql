CREATE TABLE [dbo].[carrierstatus]
(
[cas_docket_number] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cas_safety_rating] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_safestat_driver] [decimal] (4, 2) NULL,
[cas_safestat_safety] [decimal] (4, 2) NULL,
[cas_safestat_vehicle] [decimal] (4, 2) NULL,
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
[cas_business_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_country] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_phone] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_business_fax] [varchar] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cas_last_update] [datetime] NULL,
[cas_rate_date] [datetime] NULL,
[cas_dot_number] [int] NULL,
[cas_411_last_update] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierstatus] ADD CONSTRAINT [PK__carrierstatus__18283AAD] PRIMARY KEY CLUSTERED ([cas_docket_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierstatus] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierstatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierstatus] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierstatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierstatus] TO [public]
GO
