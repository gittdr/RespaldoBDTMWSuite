CREATE TABLE [dbo].[ticket_order_entry_master_audit]
(
[ord_hdrnumber] [int] NOT NULL,
[toema_plan_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toema_plan_status_override] [bit] NULL,
[toema_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toema_updatedate] [datetime] NOT NULL,
[toema_update_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toema_comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ticket_order_entry_master_audit] ADD CONSTRAINT [PK_ticket_order_entry_master_audit] PRIMARY KEY CLUSTERED ([ord_hdrnumber], [toema_updatedate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry_master_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry_master_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry_master_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry_master_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry_master_audit] TO [public]
GO
