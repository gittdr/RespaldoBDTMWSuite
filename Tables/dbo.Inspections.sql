CREATE TABLE [dbo].[Inspections]
(
[ins_id] [int] NOT NULL IDENTITY(1, 1),
[ins_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ins_date] [datetime] NULL,
[ins_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_damage] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_transit_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_number] [int] NULL,
[ins_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_cmd_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_sti] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_delivery_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_position] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_direction] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_createddate] [datetime] NULL,
[ins_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_lastupdatedt] [datetime] NULL,
[ins_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_export_pending] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_inspectioncomplete] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_scac] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_customerid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ins_errormessage] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[ins_source] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_inspections] ON [dbo].[Inspections] FOR UPDATE,INSERT AS 
SET NOCOUNT ON 

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output


/*
*	Inserted row
*/
if not exists (select 1 from inserted join inspections on inserted.ins_id = inspections.ins_id) and not exists (select 1 from deleted join inspections on deleted.ins_id = inspections.ins_id)
	update Inspections
	set ins_createdby = @tmwuser,
		ins_createddate = getdate(),
		ins_lastupdateby = @tmwuser,
		ins_lastupdatedt = getdate()
	from inspections inner join inserted on inspections.ins_id = inserted.ins_id

/*
*	Updated row
*/
if exists(select 1 from inserted join inspections on inserted.ins_id = inspections.ins_id) and exists(select 1 from deleted join inspections on deleted.ins_id = inspections.ins_id)
	update Inspections
	set ins_lastupdateby = @tmwuser,
		ins_lastupdatedt = getdate()
	from inspections inner join inserted on inspections.ins_id = inserted.ins_id
GO
ALTER TABLE [dbo].[Inspections] ADD CONSTRAINT [pk_insid] PRIMARY KEY CLUSTERED ([ins_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Inspections] TO [public]
GO
GRANT INSERT ON  [dbo].[Inspections] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Inspections] TO [public]
GO
GRANT SELECT ON  [dbo].[Inspections] TO [public]
GO
GRANT UPDATE ON  [dbo].[Inspections] TO [public]
GO
