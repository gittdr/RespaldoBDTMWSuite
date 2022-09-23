CREATE TABLE [dbo].[ticket_order_entry]
(
[toe_ticket_num] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toe_master_order] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toe_tonnage] [float] NOT NULL,
[toe_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toe_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toe_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toe_loaddate] [datetime] NOT NULL,
[toe_deliverdate] [datetime] NOT NULL,
[toe_processed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[toe_fuel_used] [int] NULL,
[toe_hours] [decimal] (8, 2) NULL,
[toe_miles] [int] NULL,
[toe_primary_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toe_paperwork_checkin] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toe_id] [int] NOT NULL,
[toe_grossweight] [int] NULL,
[toe_tareweight] [int] NULL,
[toe_pay] [money] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_ticket_order_entry] ON [dbo].[ticket_order_entry] FOR DELETE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DELETE	ticket_order_entry_ref
 WHERE	toe_id IN (SELECT toe_id FROM deleted)

GO
CREATE NONCLUSTERED INDEX [dk_toe_master] ON [dbo].[ticket_order_entry] ([toe_master_order], [toe_deliverdate]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_toe] ON [dbo].[ticket_order_entry] ([toe_ticket_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ticket_order_entry] TO [public]
GO
GRANT INSERT ON  [dbo].[ticket_order_entry] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ticket_order_entry] TO [public]
GO
GRANT SELECT ON  [dbo].[ticket_order_entry] TO [public]
GO
GRANT UPDATE ON  [dbo].[ticket_order_entry] TO [public]
GO
