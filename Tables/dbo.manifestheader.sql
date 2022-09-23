CREATE TABLE [dbo].[manifestheader]
(
[stp_number_start] [int] NULL,
[stp_number_end] [int] NULL,
[timestamp] [timestamp] NULL,
[mfh_number] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NULL,
[unit_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seal_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manifesth__is_ac__64AB8E0A] DEFAULT ('Y'),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_committed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manifesth__is_co__659FB243] DEFAULT ('N'),
[manifest_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recommended_door] [int] NULL CONSTRAINT [DF__manifesth__recom__6693D67C] DEFAULT ((0)),
[planned_ob_door] [int] NULL CONSTRAINT [DF__manifesth__plann__6787FAB5] DEFAULT ((0)),
[route_id] [int] NULL CONSTRAINT [DF__manifesth__route__687C1EEE] DEFAULT ((0)),
[status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_count] [int] NULL,
[stp_count_done] [int] NULL,
[pickups] [int] NULL,
[pickups_done] [int] NULL,
[deliveries] [int] NULL,
[deliveries_done] [int] NULL,
[ord_count] [int] NULL,
[remarks] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terminal_schedule_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create trigger [dbo].[iud_manifestheader]
on [dbo].[manifestheader]
for insert,update,delete
as
 SET NOCOUNT ON
 DECLARE @tmwuser varchar (255)
 exec gettmwuser @tmwuser output

 --log delete
 INSERT INTO [manifestheaderaudit]
      ([audit_type],[audit_user],[audit_date],[stp_number_start],[stp_number_end],[mfh_number],[mov_number],[unit_type],[unit_id],[seal_number],[is_active],[cmp_id],[is_committed],[manifest_type],[recommended_door],[planned_ob_door],[route_id],[status])
  select 'D', @tmwuser, GETDATE(),[stp_number_start],[stp_number_end],[mfh_number],[mov_number],[unit_type],[unit_id],[seal_number],[is_active],[cmp_id],[is_committed],[manifest_type],[recommended_door],[planned_ob_door],[route_id],[status]      
     from deleted 
     where not exists(select 1 from inserted where inserted.mfh_number = deleted.mfh_number) 
     
     --log insert/update
 INSERT INTO [manifestheaderaudit]
      ([audit_type],[audit_user],[audit_date],[stp_number_start],[stp_number_end],[mfh_number],[mov_number],[unit_type],[unit_id],[seal_number],[is_active],[cmp_id],[is_committed],[manifest_type],[recommended_door],[planned_ob_door],[route_id],[status])
  select (case when not exists(select 1 from deleted where inserted.mfh_number = deleted.mfh_number) then 'I' else 'U' end),  
  @tmwuser, GETDATE(),[stp_number_start],[stp_number_end],[mfh_number],[mov_number],[unit_type],[unit_id],[seal_number],[is_active],[cmp_id],[is_committed],[manifest_type],[recommended_door],[planned_ob_door],[route_id],[status]      
     from inserted
GO
CREATE NONCLUSTERED INDEX [manifest_mov] ON [dbo].[manifestheader] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [manifest_asset] ON [dbo].[manifestheader] ([unit_type], [unit_id], [is_active], [mfh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[manifestheader] TO [public]
GO
GRANT INSERT ON  [dbo].[manifestheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[manifestheader] TO [public]
GO
GRANT SELECT ON  [dbo].[manifestheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[manifestheader] TO [public]
GO
