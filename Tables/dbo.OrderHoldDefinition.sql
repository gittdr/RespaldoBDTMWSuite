CREATE TABLE [dbo].[OrderHoldDefinition]
(
[hld_id] [int] NOT NULL IDENTITY(1, 1),
[hld_customer] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_startdate] [datetime] NULL,
[hld_enddate] [datetime] NULL,
[hld_exception] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_authorization] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_cbcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_effective_comment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_terminate_comment] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_createdate] [datetime] NULL,
[hld_createdby] [varchar] (225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_lastupdatedt] [datetime] NULL,
[hld_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_unit_chgtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_units_charged] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hld_storage_startdate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_OrderHoldDefinition] ON [dbo].[OrderHoldDefinition] FOR UPDATE,INSERT AS 
SET NOCOUNT ON 

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

Declare @minhold as integer,
	@msg as varchar(255),
	@cnt as integer

Declare @holds table (hld_id integer, enddate datetime)



/*
*	Inserted row
*/
if exists (select 1 from inserted join OrderHoldDefinition on inserted.hld_id = OrderHoldDefinition.hld_id) and not exists (select 1 from deleted join OrderHoldDefinition on deleted.hld_id = OrderHoldDefinition.hld_id)
	update OrderHoldDefinition
	set hld_createdby = @tmwuser,
		hld_createdate = getdate(),
		hld_lastupdateby = @tmwuser,
		hld_lastupdatedt = getdate()
	from OrderHoldDefinition inner join inserted on OrderHoldDefinition.hld_id = inserted.hld_id

/*
*	Updated row
*/
if exists(select 1 from inserted join OrderHoldDefinition on inserted.hld_id = OrderHoldDefinition.hld_id) and exists(select 1 from deleted join OrderHoldDefinition on deleted.hld_id = OrderHoldDefinition.hld_id)
	Begin
		update OrderHoldDefinition
		set hld_lastupdateby = @tmwuser,
			hld_lastupdatedt = getdate()
		from OrderHoldDefinition inner join inserted on OrderHoldDefinition.hld_id = inserted.hld_id
		
		if UPDATE(hld_enddate)
			Begin
				Insert into @holds
				select hld_id,
					hld_enddate
				from inserted
				where update(hld_enddate)
					and hld_enddate <= GETDATE()
				
				select @minhold = Min(isNull(hld_id,0)) from @holds
				do while @minhold > 0
				begin
					exec ExpireOrderHoldId_sp @minhold, @cnt out
					
					select @minhold = Min(isNull(hld_id,0)) from @holds where hld_id > @minhold
				end
				
				
			
			End

	End
GO
ALTER TABLE [dbo].[OrderHoldDefinition] ADD CONSTRAINT [pk_hld_id] PRIMARY KEY CLUSTERED ([hld_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderHoldDefinition] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderHoldDefinition] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrderHoldDefinition] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderHoldDefinition] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderHoldDefinition] TO [public]
GO
