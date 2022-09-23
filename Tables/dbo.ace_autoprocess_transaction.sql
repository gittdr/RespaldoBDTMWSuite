CREATE TABLE [dbo].[ace_autoprocess_transaction]
(
[record_id] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NULL,
[port_location] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[passenger_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailer_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scn_paps_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[border_eta_date] [datetime] NULL,
[ttm_message_id] [int] NULL,
[transaction_date] [datetime] NULL,
[processed_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_aat_processed_status] DEFAULT ('N'),
[ob_document_batch] [int] NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ace_autoprocess_transaction] ADD CONSTRAINT [PK__ace_autoprocess___61E6C7F6] PRIMARY KEY CLUSTERED ([record_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ace_autoprocess_transaction] TO [public]
GO
GRANT INSERT ON  [dbo].[ace_autoprocess_transaction] TO [public]
GO
GRANT SELECT ON  [dbo].[ace_autoprocess_transaction] TO [public]
GO
GRANT UPDATE ON  [dbo].[ace_autoprocess_transaction] TO [public]
GO
