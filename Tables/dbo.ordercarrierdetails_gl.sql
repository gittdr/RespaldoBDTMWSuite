CREATE TABLE [dbo].[ordercarrierdetails_gl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[oc_id] [int] NULL,
[ocd_id] [int] NULL,
[glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[base_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[account_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL,
[debit_amount] [money] NULL,
[credit_amount] [money] NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ordercarrierdetails_gl] ADD CONSTRAINT [PK__ordercar__3213E83F0CC124D6] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ocgl_ocid] ON [dbo].[ordercarrierdetails_gl] ([oc_id], [id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ordercarrierdetails_gl] TO [public]
GO
GRANT INSERT ON  [dbo].[ordercarrierdetails_gl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ordercarrierdetails_gl] TO [public]
GO
GRANT SELECT ON  [dbo].[ordercarrierdetails_gl] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordercarrierdetails_gl] TO [public]
GO
