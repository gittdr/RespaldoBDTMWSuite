CREATE TABLE [dbo].[ticket_order_entry_ref]
(
[toe_id] [int] NOT NULL,
[toer_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toer_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toer_ref_sequence] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pk_toe_ref] ON [dbo].[ticket_order_entry_ref] ([toe_id], [toer_ref_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry_ref] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry_ref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry_ref] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry_ref] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry_ref] TO [public]
GO
