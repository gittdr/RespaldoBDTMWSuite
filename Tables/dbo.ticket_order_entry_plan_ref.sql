CREATE TABLE [dbo].[ticket_order_entry_plan_ref]
(
[toep_id] [int] NOT NULL,
[toepr_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toepr_ref_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toepr_ref_sequence] [int] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [toep_id_dk] ON [dbo].[ticket_order_entry_plan_ref] ([toep_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry_plan_ref] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry_plan_ref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry_plan_ref] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry_plan_ref] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry_plan_ref] TO [public]
GO
