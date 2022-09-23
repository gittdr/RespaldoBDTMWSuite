CREATE TABLE [dbo].[RMXML_CarrierProfile]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NOT NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[YearsInBusiness] [int] NULL,
[FlatBeds] [int] NULL,
[DryVans] [int] NULL,
[RefrigeratedVans] [int] NULL,
[RGN] [int] NULL,
[StepDecks] [int] NULL,
[Maxi] [int] NULL,
[DoubleDrops] [int] NULL,
[PayeeType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentMethod] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountsPayableContact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountsPayablePhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchContact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispatchPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrAfterHrsContact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DrAfterHrsPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherContact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherPhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectFirstMoveTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailReceived] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredOrigins] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredDestinations] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DifficultiesLoadsState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredLanes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyRep] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSpecialContract] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryEquipmentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysToPay] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factory] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCAC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasSmartwayCert] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasFastCert] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasCarbCert] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasTwicCert] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HazMatCertified] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HazMatExpirationDate] [datetime] NULL,
[HazMatCertVerifiedByRMIS] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasSafetyPermitHM232] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TractorCount] [int] NULL,
[IntermodalTrailerCount] [int] NULL,
[TankerTrailerCount] [int] NULL,
[BulkTrailerCount] [int] NULL,
[OtherTrailerCount] [int] NULL,
[MinorityWomanOwned] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SmallBusinessType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DiversityCertAgency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyMsgAgreement] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoW9] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WcWaiverDate] [datetime] NULL,
[WcWaiverContact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vans48foot] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reefer48foot] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vans53foot] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reefer53foot] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyDrivers] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Teams] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OwnerOperators] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasMexInterchange] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasCanAuth] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PadWrap] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Straps] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TriAxleVans] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VentedVans] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeatedVans] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GarmentTrailer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuperVan] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WalkingFloor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OpenTop] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StraightTrucks] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CargoVan] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hopper] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasCTPATCert] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__0EAAEC56] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__RMXML_Car__lastu__0F9F108F] DEFAULT (suser_sname()),
[IsFactoring] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FladBed48Foot] [int] NULL,
[FlatBed53foot] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RMXML_CarrierProfile] ADD CONSTRAINT [pk_rmxml_carrierprofile] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfile_LastUpdateDate] ON [dbo].[RMXML_CarrierProfile] ([lastupdatedate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RMXML_CarrierProfile_TmwXmlImportLog_id] ON [dbo].[RMXML_CarrierProfile] ([TmwXmlImportLog_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_CarrierProfile] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_CarrierProfile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_CarrierProfile] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_CarrierProfile] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_CarrierProfile] TO [public]
GO
