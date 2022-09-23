CREATE TABLE [dbo].[dhl_payment_data]
(
[pad_batch] [int] NOT NULL,
[pad_identity] [int] NOT NULL IDENTITY(1, 1),
[pad_number] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pad_payment_date] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pad_payment_doc_number] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dhl_payment_data] ADD CONSTRAINT [uk_dhl_payment_data_pad_id] PRIMARY KEY CLUSTERED ([pad_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dhl_payment_data] TO [public]
GO
GRANT INSERT ON  [dbo].[dhl_payment_data] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dhl_payment_data] TO [public]
GO
GRANT SELECT ON  [dbo].[dhl_payment_data] TO [public]
GO
GRANT UPDATE ON  [dbo].[dhl_payment_data] TO [public]
GO
