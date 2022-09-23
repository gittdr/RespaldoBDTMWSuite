CREATE TABLE [dbo].[KaneAllocation]
(
[ImpId] [int] NOT NULL IDENTITY(1, 1),
[KaneId] [int] NOT NULL,
[STSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SASUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LHSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FSSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LTSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HTSUB] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QT] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WT] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CT] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AT] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ST] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LH] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LT] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HT] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Num] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STID1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AS1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AT1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AC1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AM1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AMTotal] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CarrierInvoiceNum] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Carrier] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KaneOrderNum] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShippingDate] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DeliveryDate] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BasedOn] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreparedBy] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PreparedOn] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PercentStop1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentStop2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentStop3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentStop4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentStop5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentLoad1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentLoad2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentLoad3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentLoad4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PercentLoad5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accessorials1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accessorials2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accessorials3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accessorials4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Accessorials5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerAccessorials1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerAccessorials2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerAccessorials3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerAccessorials4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StorerAccessorials5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linehaul1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linehaul2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linehaul3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linehaul4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Linehaul5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fuel1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fuel2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fuel3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fuel4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fuel5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber1] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber2] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber3] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber4] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNumber5] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneAllocation] ADD CONSTRAINT [PK_KaneAllocation] PRIMARY KEY CLUSTERED ([ImpId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KaneAllocation] ADD CONSTRAINT [FK_KaneAllocation_KaneBatch] FOREIGN KEY ([KaneId]) REFERENCES [dbo].[KaneBatch] ([KaneId])
GO
GRANT DELETE ON  [dbo].[KaneAllocation] TO [public]
GO
GRANT INSERT ON  [dbo].[KaneAllocation] TO [public]
GO
GRANT SELECT ON  [dbo].[KaneAllocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[KaneAllocation] TO [public]
GO
