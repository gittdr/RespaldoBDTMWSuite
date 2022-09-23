CREATE TABLE [dbo].[FuelRelations]
(
[RelId] [int] NOT NULL IDENTITY(1, 1),
[RelType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pickup] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Delivery] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Supplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeliveryState] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StringValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DecimalValue] [decimal] (10, 2) NULL,
[LastUpdate] [datetime] NOT NULL,
[LastUpdateby] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Commodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LearnedCount] [decimal] (10, 2) NULL,
[AccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelRelat__Accou__325C42A5] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FuelRelations] ADD CONSTRAINT [PK__FuelRelations__31681E6C] PRIMARY KEY CLUSTERED ([RelId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_FuelRelationsRelTypeTerminal] ON [dbo].[FuelRelations] ([RelType], [Terminal]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelRelations] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelRelations] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelRelations] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelRelations] TO [public]
GO
