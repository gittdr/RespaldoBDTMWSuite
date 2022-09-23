CREATE TABLE [dbo].[PayDetailDisputes]
(
[PayDetailDisputeId] [int] NOT NULL,
[pyh_number] [int] NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[Status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReleasedBy] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [float] NULL,
[RateUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate] [money] NULL,
[Amount] [money] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayDetailDisputes] ADD CONSTRAINT [PK_PayDetailDisputes] PRIMARY KEY CLUSTERED ([PayDetailDisputeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PayDetailDisputes] TO [public]
GO
GRANT INSERT ON  [dbo].[PayDetailDisputes] TO [public]
GO
GRANT SELECT ON  [dbo].[PayDetailDisputes] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayDetailDisputes] TO [public]
GO
