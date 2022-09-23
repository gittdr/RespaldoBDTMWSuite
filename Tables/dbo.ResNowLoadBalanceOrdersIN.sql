CREATE TABLE [dbo].[ResNowLoadBalanceOrdersIN]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[State] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Order Number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origin Region 1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Origin Region 2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Legheader Number] [int] NULL,
[RevType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Travel Miles] [int] NULL,
[Loaded Miles] [int] NULL,
[Total Miles] [int] NULL,
[End Date] [datetime] NULL,
[Start DateTime] [datetime] NULL,
[End DateTime] [datetime] NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Region1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_originstate] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_deststate] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowLoadBalanceOrdersIN] ADD CONSTRAINT [PK__ResNowLoadBalanc__716902A8] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowLoadBalanceOrdersIN] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowLoadBalanceOrdersIN] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowLoadBalanceOrdersIN] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowLoadBalanceOrdersIN] TO [public]
GO
