CREATE TABLE [dbo].[d83_calc_log]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[totalAmount] [money] NULL,
[zip1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[split1] [decimal] (18, 0) NULL,
[split2] [decimal] (18, 0) NULL,
[split3] [decimal] (18, 0) NULL,
[split4] [decimal] (18, 0) NULL,
[factorA] [int] NULL,
[factorB] [int] NULL,
[factorC] [int] NULL,
[factorD] [int] NULL,
[factorE] [int] NULL,
[factorF] [int] NULL,
[minfactor1] [int] NULL,
[minfactor2] [int] NULL,
[minfactor3] [int] NULL,
[minfactor4] [int] NULL,
[amount1] [money] NULL,
[amount2] [money] NULL,
[amount3] [money] NULL,
[amount4] [money] NULL,
[minamount1] [money] NULL,
[minamount2] [money] NULL,
[minamount3] [money] NULL,
[minamount4] [money] NULL,
[rowchgts] [timestamp] NOT NULL,
[car_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_leg] [int] NULL,
[car_adj_pct] [decimal] (10, 2) NULL,
[car_adj_amount] [decimal] (10, 2) NULL,
[car_actual_amount] [decimal] (10, 2) NULL,
[car_adj_min] [decimal] (10, 2) NULL,
[car_adj_absolute_min] [decimal] (12, 2) NULL,
[car_adj_absolute_min_cmp] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[d83_calc_log] ADD CONSTRAINT [PK__d83_calc__3213E83F8902B73D] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [d83_cl_order] ON [dbo].[d83_calc_log] ([ord_hdrnumber], [id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[d83_calc_log] TO [public]
GO
GRANT INSERT ON  [dbo].[d83_calc_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[d83_calc_log] TO [public]
GO
GRANT SELECT ON  [dbo].[d83_calc_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[d83_calc_log] TO [public]
GO
