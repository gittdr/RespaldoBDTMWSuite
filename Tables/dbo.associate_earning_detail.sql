CREATE TABLE [dbo].[associate_earning_detail]
(
[branch_pay_header_id] [int] NOT NULL,
[cht_itemcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivh_invoicenumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_charge] [money] NULL,
[split_pct] [float] NULL,
[item_alloc_amt] [money] NULL,
[associate_pct] [float] NULL,
[associate_amt] [money] NULL,
[ic_stlmnt_amt] [money] NULL,
[ic_stlmnt_pct] [float] NULL,
[associate_stlmnt_amt] [money] NULL,
[associate_stlmnt_pct] [float] NULL,
[ic_record] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[manual] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ic_amt_modified] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ic_allow_correction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[allow_rev_allocation_edits] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[associate_earning_detail] ADD CONSTRAINT [associate_earning_detail_pk] PRIMARY KEY CLUSTERED ([branch_pay_header_id], [cht_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[associate_earning_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[associate_earning_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[associate_earning_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[associate_earning_detail] TO [public]
GO
