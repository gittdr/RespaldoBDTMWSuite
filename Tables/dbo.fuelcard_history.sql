CREATE TABLE [dbo].[fuelcard_history]
(
[fch_id] [int] NOT NULL IDENTITY(1, 1),
[fch_vendor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fch_card_number] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fch_accountid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fch_customerid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fch_request_type] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fch_advance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fch_amount] [money] NULL,
[fch_error_number] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fch_response_status] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fch_response_status_message] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fch_updateddt] [datetime] NULL,
[fch_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_fch_account] ON [dbo].[fuelcard_history] ([fch_accountid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_fch_card] ON [dbo].[fuelcard_history] ([fch_card_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_fch_card_account_customer] ON [dbo].[fuelcard_history] ([fch_card_number], [fch_accountid], [fch_customerid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_fch_customer] ON [dbo].[fuelcard_history] ([fch_customerid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelcard_history] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelcard_history] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelcard_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelcard_history] TO [public]
GO
