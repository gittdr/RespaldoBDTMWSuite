CREATE TABLE [dbo].[Invoicedetailpayments]
(
[ivdpymt_number] [int] NOT NULL IDENTITY(1, 1),
[ivdpymt_ivdnumber] [int] NOT NULL,
[ivdpymt_Check_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivdpymt_GPBatch] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ivdpymt_Check_date] [datetime] NOT NULL,
[ivdpymt_Amount_pd] [money] NULL,
[ivdpymt_ivhnumber] [int] NOT NULL,
[ivdpymt_pydnumber] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Invoicedetailpayments] TO [public]
GO
GRANT INSERT ON  [dbo].[Invoicedetailpayments] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Invoicedetailpayments] TO [public]
GO
GRANT SELECT ON  [dbo].[Invoicedetailpayments] TO [public]
GO
GRANT UPDATE ON  [dbo].[Invoicedetailpayments] TO [public]
GO
