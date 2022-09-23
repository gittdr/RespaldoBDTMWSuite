CREATE TABLE [dbo].[OrderHold]
(
[ohld_id] [int] NOT NULL IDENTITY(1, 1),
[hld_id] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[ohld_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_startdate] [datetime] NULL,
[ohld_enddate] [datetime] NULL,
[ohld_effective_comment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_terminate_comment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_exceptioncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_authcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_authid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_cbcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_releaseid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_releasecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_refnum1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_createdate] [datetime] NULL,
[ohld_createdby] [varchar] (225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_lastupdatedt] [datetime] NULL,
[ohld_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_export_pending] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_inactivedate] [datetime] NULL,
[ohld_inactive_notify] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_unit_chgtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_units_charged] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ohld_storage_startdate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[iudt_OrderHold] ON [dbo].[OrderHold] FOR UPDATE,INSERT,DELETE AS 
SET NOCOUNT ON 

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

Declare	@active			char(1),
	@inserted			integer,
	@deleted			integer,
	@ordhdr				integer

select @inserted  = count(*) from inserted join orderhold on inserted.ohld_id = orderhold.ohld_id
select @deleted = count(*) from deleted join orderhold on deleted.ohld_id = orderhold.ohld_id


/*
*	Inserted row
*/
update orderhold
set ohld_createdby = @tmwuser,
	ohld_createdate = getdate(),
	ohld_lastupdateby = @tmwuser,
	ohld_lastupdatedt = getdate()
from orderhold inner join inserted on orderhold.ohld_id = inserted.ohld_id
where not exists (select * from deleted where orderhold.ohld_id = deleted.ohld_id)
	

/*
*	Updated row
*/
--if exists(select 1 from inserted join orderhold on inserted.ohld_id = orderhold.ohld_id) and exists(select 1 from deleted join orderhold on deleted.ohld_id = orderhold.ohld_id)
	If Not UPDATE(ohld_lastupdateby) 
		update orderhold
		set ohld_lastupdateby = @tmwuser,
			ohld_lastupdatedt = getdate()
		from orderhold inner join inserted on orderhold.ohld_id = inserted.ohld_id

-- PTS #69267 mak
IF UPDATE(ohld_active) 
	Begin
		select i.ohld_id 
		into #inactived
		from inserted i inner join deleted d on (i.ohld_id = d.ohld_id)
		where i.ohld_active = 'N' and
			d.ohld_active = 'Y'

		if exists(select * from #inactived)
		begin
			update orderhold set ohld_inactivedate = GETDATE(),
				ohld_export_pending = 'Y'
			from orderhold 
			where ohld_id in (select ohld_id from #inactived)
		end
	end

IF OBJECT_ID('dbo.order_hold_status_sp') IS NOT NULL
	Begin
		declare @ohld_id int
		declare @ord_hdrnumber int
		declare @ohld_active char(1)
		declare @ohld_active_old char(1)
		-- look for inserted or updated rows
		select @ohld_id = -1
		while exists (select * from inserted where ohld_id > @ohld_id)
		begin
  			 select @ohld_id = min(ohld_id) from inserted where ohld_id > @ohld_id
			 select @ord_hdrnumber = ord_hdrnumber, @ohld_active = ohld_active from inserted where ohld_id = @ohld_id
			 set @ohld_active_old = ''
			 select @ohld_active_old = isNull(ohld_active,'') from deleted where ohld_id = @ohld_id
			 --Call the proc to update the status of the Order based on the Hold status.
			 if @ohld_active_old <> @ohld_active
				exec order_hold_status_sp @ord_hdrnumber
	 	end
	 	-- look for deleted rows
	 	select @ohld_id = -1
		while exists (select * from deleted where ohld_id > @ohld_id)
		begin
  			 select @ohld_id = min(ohld_id) from deleted where ohld_id > @ohld_id
			 if not exists(select 1 from inserted where ohld_id = @ohld_id)
				BEGIN
					select @ord_hdrnumber = ord_hdrnumber from deleted where ohld_id = @ohld_id
					--Call the proc to update the status of the Order based on the Hold status.
					exec order_hold_status_sp @ord_hdrnumber
				END
	 	end
	end
GO
ALTER TABLE [dbo].[OrderHold] ADD CONSTRAINT [pk_ohld_id] PRIMARY KEY CLUSTERED ([ohld_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_idorder] ON [dbo].[OrderHold] ([hld_id], [ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderHold] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderHold] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrderHold] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderHold] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderHold] TO [public]
GO
