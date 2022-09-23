CREATE TABLE [dbo].[core_carrierlanecommitment]
(
[carrierlanecommitmentid] [int] NOT NULL IDENTITY(1, 1),
[laneid] [int] NOT NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effectivedate] [datetime] NOT NULL CONSTRAINT [DF_core_CarrierLaneCommitment_EffectiveDate] DEFAULT (getdate()),
[expiresdate] [datetime] NULL,
[commitmentnumber] [int] NOT NULL,
[commitmentperiod] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_core_CarrierLaneCommitment_CommitmentPeriod] DEFAULT ('month'),
[timestamp] [timestamp] NOT NULL,
[updatedt] [datetime] NOT NULL CONSTRAINT [DF_core_CarrierLaneCommitment_Updated] DEFAULT (getdate()),
[car_preferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_commitment_cap] [int] NULL,
[car_factor] [decimal] (4, 2) NULL,
[IsEligible] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExclusivePriority] [int] NULL,
[car_rating] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commitment_cap_period] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[roundrobin_percent] [decimal] (5, 2) NULL,
[IsFrontLoadedCommitment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clc_loads_offered] [int] NULL,
[clc_loads_responded_to] [int] NULL,
[clc_loads_not_responded_to] [int] NULL,
[clc_loads_awarded] [int] NULL,
[clc_email_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clc_loads_on_time] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_carrierlanecommitment] ADD CONSTRAINT [PK_core_CarrierLaneCommitment] PRIMARY KEY CLUSTERED ([carrierlanecommitmentid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_core_carrierlanecommitment_laneid] ON [dbo].[core_carrierlanecommitment] ([laneid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[core_carrierlanecommitment] TO [public]
GO
GRANT INSERT ON  [dbo].[core_carrierlanecommitment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[core_carrierlanecommitment] TO [public]
GO
GRANT SELECT ON  [dbo].[core_carrierlanecommitment] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_carrierlanecommitment] TO [public]
GO
