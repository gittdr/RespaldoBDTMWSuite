CREATE TABLE [dbo].[unitconversion]
(
[unc_from] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unc_to] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unc_convflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unc_factor] [float] NULL,
[unc_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unc_updtdate] [datetime] NULL,
[unc_adddate] [datetime] NULL,
[dw_timestamp] [timestamp] NOT NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__unitconve__INS_T__0153E46C] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_unitconversion_timestamp] ON [dbo].[unitconversion] ([dw_timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [unitconversion_INS_TIMESTAMP] ON [dbo].[unitconversion] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uncidx] ON [dbo].[unitconversion] ([unc_from], [unc_to], [unc_convflag]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[unitconversion] TO [public]
GO
GRANT INSERT ON  [dbo].[unitconversion] TO [public]
GO
GRANT REFERENCES ON  [dbo].[unitconversion] TO [public]
GO
GRANT SELECT ON  [dbo].[unitconversion] TO [public]
GO
GRANT UPDATE ON  [dbo].[unitconversion] TO [public]
GO
