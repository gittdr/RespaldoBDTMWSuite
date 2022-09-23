CREATE TABLE [dbo].[tch_rejected_transactions]
(
[tchRejTransID] [int] NOT NULL IDENTITY(1, 1),
[transaction_date] [datetime] NOT NULL,
[vendor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[card_number] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_number] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_id] [int] NOT NULL,
[location_name] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_city] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error_code] [int] NOT NULL,
[error_description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tch_rejected_transactions] ADD CONSTRAINT [pk_tch_rejected_transactions] PRIMARY KEY CLUSTERED ([tchRejTransID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tch_rejected_transactions] TO [public]
GO
GRANT INSERT ON  [dbo].[tch_rejected_transactions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tch_rejected_transactions] TO [public]
GO
GRANT SELECT ON  [dbo].[tch_rejected_transactions] TO [public]
GO
GRANT UPDATE ON  [dbo].[tch_rejected_transactions] TO [public]
GO
