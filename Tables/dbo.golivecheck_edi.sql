CREATE TABLE [dbo].[golivecheck_edi]
(
[glc_rundate] [datetime] NULL,
[glc_edi_cmp_invalid_output] [int] NULL,
[glc_edi_trading_partners] [int] NULL,
[glc_edi_incmp_214_info] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glc_edi_210] [int] NULL,
[glc_edi_214] [int] NULL,
[glc_edi_997_210] [int] NULL,
[glc_edi_997_214] [int] NULL,
[glc_edi_204] [int] NULL,
[glc_edi_210_no_acc] [int] NULL,
[glc_edi_ref_set_not_required] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_edi] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_edi] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_edi] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_edi] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_edi] TO [public]
GO
