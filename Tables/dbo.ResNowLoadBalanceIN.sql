CREATE TABLE [dbo].[ResNowLoadBalanceIN]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Tractor] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CompCarga] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EstadoCarga] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HoraCarga] [datetime] NOT NULL,
[Orden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowLoadBalanceIN] ADD CONSTRAINT [PK__ResNowLoadBalanc__5EFA10BC] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
