CREATE TABLE [dbo].[importcredit]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[imc_amount] [money] NULL,
[imc_transdate] [datetime] NULL,
[imc_importflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[imc_batchnumber] [int] NULL,
[imc_agedinvflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [imc_primary] ON [dbo].[importcredit] ([cmp_id], [imc_transdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [imp_idx2] ON [dbo].[importcredit] ([imc_batchnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[importcredit] TO [public]
GO
GRANT INSERT ON  [dbo].[importcredit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[importcredit] TO [public]
GO
GRANT SELECT ON  [dbo].[importcredit] TO [public]
GO
GRANT UPDATE ON  [dbo].[importcredit] TO [public]
GO
