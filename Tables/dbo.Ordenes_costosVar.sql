CREATE TABLE [dbo].[Ordenes_costosVar]
(
[renglon] [int] NOT NULL,
[Ord_hdrnumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_charge] [float] NULL,
[driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unidad] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[legheadercostos] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Ordenes_costosVar] ADD CONSTRAINT [pkordcosto] PRIMARY KEY NONCLUSTERED ([renglon]) ON [PRIMARY]
GO
