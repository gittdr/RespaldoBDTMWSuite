CREATE TABLE [dbo].[golivecheck_rating]
(
[glc_rundate] [datetime] NULL,
[glc_cnt_primary_bill_rates] [int] NULL,
[glc_cnt_accessorial_bill_rates] [int] NULL,
[glc_cnt_lineitem_bill_rates] [int] NULL,
[glc_pct_acc_li_bill_attached_primary] [float] NULL,
[glc_cnt_primary_pay_rates] [int] NULL,
[glc_cnt_accessorial_pay_rates] [int] NULL,
[glc_cnt_lineitem_pay_rates] [int] NULL,
[glc_pct_acc_pay_attached_primary] [float] NULL,
[glc_cnt_bill_rates_used] [int] NULL,
[glc_cnt_pay_rates_used] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[golivecheck_rating] TO [public]
GO
GRANT INSERT ON  [dbo].[golivecheck_rating] TO [public]
GO
GRANT REFERENCES ON  [dbo].[golivecheck_rating] TO [public]
GO
GRANT SELECT ON  [dbo].[golivecheck_rating] TO [public]
GO
GRANT UPDATE ON  [dbo].[golivecheck_rating] TO [public]
GO
