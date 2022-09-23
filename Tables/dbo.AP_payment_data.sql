CREATE TABLE [dbo].[AP_payment_data]
(
[pad_batch] [int] NOT NULL,
[pad_identity] [int] NOT NULL IDENTITY(1, 1),
[pad_ap_check_dt] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pad_ap_check_nbr] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pad_ap_check_amt] [decimal] (19, 2) NULL,
[pad_ap_vendor_id] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pad_ap_voucher_nbr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AP_payment_data] ADD CONSTRAINT [uk_AP_payment_data_pad_id] PRIMARY KEY CLUSTERED ([pad_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AP_payment_data] TO [public]
GO
GRANT INSERT ON  [dbo].[AP_payment_data] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AP_payment_data] TO [public]
GO
GRANT SELECT ON  [dbo].[AP_payment_data] TO [public]
GO
GRANT UPDATE ON  [dbo].[AP_payment_data] TO [public]
GO
