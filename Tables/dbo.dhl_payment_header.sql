CREATE TABLE [dbo].[dhl_payment_header]
(
[pad_batch] [int] NOT NULL IDENTITY(1, 1),
[pad_date] [datetime] NULL,
[pad_filename] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pad_recordcount] [int] NULL,
[pad_successcount] [int] NULL,
[pad_failurecount] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dhl_payment_header] ADD CONSTRAINT [uk_dhl_payment_header_pad_batch] PRIMARY KEY CLUSTERED ([pad_batch]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dhl_payment_header] TO [public]
GO
GRANT INSERT ON  [dbo].[dhl_payment_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dhl_payment_header] TO [public]
GO
GRANT SELECT ON  [dbo].[dhl_payment_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[dhl_payment_header] TO [public]
GO
