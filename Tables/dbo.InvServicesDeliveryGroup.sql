CREATE TABLE [dbo].[InvServicesDeliveryGroup]
(
[DelGroup] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descripiton] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Active] DEFAULT ('Y'),
[Priority] [int] NOT NULL,
[HoursOutForSearch] [int] NOT NULL,
[MinVolumeForSearch] [int] NOT NULL,
[OneInvForBillTo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_InvServicesDeliveryGroup_OneInvForBillTo] DEFAULT ('N'),
[MaxVolume] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_MaxVolume] DEFAULT ((0)),
[SpecificGravity] [decimal] (9, 4) NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_SpecificGravity] DEFAULT ((0)),
[Compartment1] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment1] DEFAULT ((0)),
[Compartment2] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment2] DEFAULT ((0)),
[Compartment3] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment3] DEFAULT ((0)),
[Compartment4] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment4] DEFAULT ((0)),
[Compartment5] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment5] DEFAULT ((0)),
[Compartment6] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment6] DEFAULT ((0)),
[Compartment7] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment7] DEFAULT ((0)),
[Compartment8] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment8] DEFAULT ((0)),
[Compartment9] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment9] DEFAULT ((0)),
[Compartment10] [int] NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroup_Compartment10] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvServicesDeliveryGroup] ADD CONSTRAINT [PK__InvServicesDeliv__15A53004] PRIMARY KEY CLUSTERED ([DelGroup]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvServicesDeliveryGroup] TO [public]
GO
GRANT INSERT ON  [dbo].[InvServicesDeliveryGroup] TO [public]
GO
GRANT SELECT ON  [dbo].[InvServicesDeliveryGroup] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvServicesDeliveryGroup] TO [public]
GO
