CREATE TABLE [dbo].[tblCabUnits]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[UnitID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [int] NULL,
[Truck] [int] NULL,
[CurrentDispatcher] [int] NULL,
[InBox] [int] NULL,
[OutBox] [int] NULL,
[Retired] [bit] NOT NULL,
[GroupFlag] [int] NULL CONSTRAINT [DF__tblCabUni__Group__44CA3770] DEFAULT (0),
[UpdateGroup] [int] NULL CONSTRAINT [DF__tblCabUni__Updat__45BE5BA9] DEFAULT (0),
[MCPassword] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LinkedAddrType] [int] NULL,
[LinkedObjSN] [int] NULL,
[InstanceId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RouteSyncEnabled] [bit] NOT NULL CONSTRAINT [DF__tblCabUni__Route__0EA4BF39] DEFAULT ((0)),
[PositionOnly] [bit] NOT NULL CONSTRAINT [DF__tblCabUni__Posit__0F98E372] DEFAULT ((0)),
[EnableZippedBlobs] [bit] NULL CONSTRAINT [DF__tblCabUni__Enabl__145D988F] DEFAULT ((0)),
[OutInstanceId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCabUnits] ADD CONSTRAINT [PK_tblCabUnits_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [InBox] ON [dbo].[tblCabUnits] ([InBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LinkedFields] ON [dbo].[tblCabUnits] ([LinkedAddrType], [LinkedObjSN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [OutBox] ON [dbo].[tblCabUnits] ([OutBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblCabUnitsTruck] ON [dbo].[tblCabUnits] ([Truck]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblUnitTypetblCabUnits] ON [dbo].[tblCabUnits] ([Type]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [UnitId] ON [dbo].[tblCabUnits] ([UnitID], [Type], [LinkedAddrType], [InstanceId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCabUnits] ADD CONSTRAINT [FK_MobileCommTypeSN] FOREIGN KEY ([Type]) REFERENCES [dbo].[tblMobileCommType] ([SN])
GO
EXEC sp_bindefault N'[dbo].[tblCabUnits_UnitID_D]', N'[dbo].[tblCabUnits].[UnitID]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblCabUnits].[Type]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblCabUnits].[Truck]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblCabUnits].[CurrentDispatcher]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblCabUnits].[InBox]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblCabUnits].[OutBox]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblCabUnits].[Retired]'
GO
GRANT DELETE ON  [dbo].[tblCabUnits] TO [public]
GO
GRANT INSERT ON  [dbo].[tblCabUnits] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblCabUnits] TO [public]
GO
GRANT SELECT ON  [dbo].[tblCabUnits] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblCabUnits] TO [public]
GO
