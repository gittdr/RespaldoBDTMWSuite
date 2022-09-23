CREATE TABLE [dbo].[expenseallocation]
(
[eal_id] [int] NOT NULL IDENTITY(1, 1),
[pyh_number] [int] NULL,
[pyd_number] [int] NULL,
[lgh_number] [int] NULL,
[thr_id] [int] NULL,
[eal_proratequantity] [decimal] (19, 4) NULL,
[eal_totalprorates] [decimal] (19, 4) NULL,
[eal_rate] [decimal] (19, 4) NULL,
[eal_amount] [decimal] (19, 4) NULL,
[cur_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_conversion_rate] [decimal] (19, 4) NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_sequence] [int] NULL,
[eal_converted_rate] [decimal] (19, 4) NULL,
[eal_converted_amount] [decimal] (19, 4) NULL,
[eal_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_created_date] [datetime2] NULL,
[eal_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_modified_date] [datetime2] NULL,
[eal_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_pytrule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_distindex] [int] NULL,
[eal_prorateitem] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_debit_amount] [decimal] (19, 4) NULL,
[eal_credit_amount] [decimal] (19, 4) NULL,
[eal_distribution_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eal_inv_debit_amount] [decimal] (19, 4) NULL,
[eal_inv_credit_amount] [decimal] (19, 4) NULL,
[eal_system_debit_amount] [decimal] (19, 4) NULL,
[eal_system_credit_amount] [decimal] (19, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[expenseallocation] ADD CONSTRAINT [pk_expenseallocation] PRIMARY KEY CLUSTERED ([eal_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_expenseallocation_pyh_number] ON [dbo].[expenseallocation] ([pyh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[expenseallocation] TO [public]
GO
GRANT INSERT ON  [dbo].[expenseallocation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[expenseallocation] TO [public]
GO
GRANT SELECT ON  [dbo].[expenseallocation] TO [public]
GO
GRANT UPDATE ON  [dbo].[expenseallocation] TO [public]
GO
