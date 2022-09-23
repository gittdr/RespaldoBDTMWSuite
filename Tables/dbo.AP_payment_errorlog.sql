CREATE TABLE [dbo].[AP_payment_errorlog]
(
[pad_err_id] [int] NOT NULL IDENTITY(1, 1),
[pad_batch] [int] NOT NULL,
[pad_err_date] [datetime] NOT NULL,
[pad_err_record_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pad_err_description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pad_ap_voucher_nbr] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AP_payment_errorlog] ADD CONSTRAINT [uk_AP_payment_errorlog_pad_err_id] PRIMARY KEY CLUSTERED ([pad_err_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AP_payment_errorlog] TO [public]
GO
GRANT INSERT ON  [dbo].[AP_payment_errorlog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AP_payment_errorlog] TO [public]
GO
GRANT SELECT ON  [dbo].[AP_payment_errorlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[AP_payment_errorlog] TO [public]
GO
