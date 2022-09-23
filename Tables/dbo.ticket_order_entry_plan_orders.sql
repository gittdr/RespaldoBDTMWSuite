CREATE TABLE [dbo].[ticket_order_entry_plan_orders]
(
[toep_id] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[create_userid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_toepo_create_userid] DEFAULT (user_name()),
[create_date] [datetime] NOT NULL CONSTRAINT [DF_toepo_create_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_ticket_order_entry_plan_orders] ON [dbo].[ticket_order_entry_plan_orders] FOR DELETE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

UPDATE	ticket_order_entry_plan
SET		toep_planned_count = toep_planned_count - 1
FROM	ticket_order_entry_plan toep, deleted d
WHERE	toep.toep_id = d.toep_id

GO
ALTER TABLE [dbo].[ticket_order_entry_plan_orders] ADD CONSTRAINT [PK_ticket_order_entry_plan_orders] PRIMARY KEY CLUSTERED ([toep_id], [ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_toepo_ord_hdrnumber] ON [dbo].[ticket_order_entry_plan_orders] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry_plan_orders] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry_plan_orders] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry_plan_orders] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry_plan_orders] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry_plan_orders] TO [public]
GO
