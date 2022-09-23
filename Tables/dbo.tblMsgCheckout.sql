CREATE TABLE [dbo].[tblMsgCheckout]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[TruckSN] [int] NULL,
[DriverSN] [int] NULL,
[UnitID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MsgSN] [int] NOT NULL,
[Agent] [uniqueidentifier] NOT NULL,
[Assigned] [datetime] NOT NULL CONSTRAINT [DF_tblMsgCheckout_Assigned] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgCheckout] ADD CONSTRAINT [PK_tblMsgCheckout] PRIMARY KEY CLUSTERED ([SN]) WITH (STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgCheckout] ADD CONSTRAINT [CK_tblMsgCheckout_Agent] UNIQUE NONCLUSTERED ([Agent]) WITH (STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMsgCheckout] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMsgCheckout] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMsgCheckout] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMsgCheckout] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMsgCheckout] TO [public]
GO
