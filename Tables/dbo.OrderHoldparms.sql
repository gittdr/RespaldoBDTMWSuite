CREATE TABLE [dbo].[OrderHoldparms]
(
[hparm_id] [int] NOT NULL IDENTITY(1, 1),
[hld_id] [int] NOT NULL,
[hparm_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[hparm_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hparm_createdate] [datetime] NULL,
[hparm_createdby] [varchar] (225) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hparm_lastupdatedt] [datetime] NULL,
[hparm_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_OrderHoldparms] ON [dbo].[OrderHoldparms] FOR UPDATE,INSERT AS 
SET NOCOUNT ON 

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output


/*
*	Inserted row
*/
if exists (select 1 from inserted join OrderHoldparms on inserted.hparm_id = OrderHoldparms.hparm_id) and not exists (select 1 from deleted join OrderHoldparms on deleted.hparm_id = OrderHoldparms.hparm_id)
	update OrderHoldparms
	set hparm_createdby = @tmwuser,
		hparm_createdate = getdate(),
		hparm_lastupdateby = @tmwuser,
		hparm_lastupdatedt = getdate()
	from OrderHoldparms inner join inserted on OrderHoldparms.hparm_id = inserted.hparm_id

/*
*	Updated row
*/
if exists(select 1 from inserted join OrderHoldparms on inserted.hparm_id = OrderHoldparms.hparm_id) and exists(select 1 from deleted join OrderHoldparms on deleted.hparm_id = OrderHoldparms.hparm_id)
	update OrderHoldparms
	set hparm_lastupdateby = @tmwuser,
		hparm_lastupdatedt = getdate()
	from OrderHoldparms inner join inserted on OrderHoldparms.hparm_id = inserted.hparm_id
GO
ALTER TABLE [dbo].[OrderHoldparms] ADD CONSTRAINT [pk_hparm_id] PRIMARY KEY CLUSTERED ([hparm_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderHoldparms] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderHoldparms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrderHoldparms] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderHoldparms] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderHoldparms] TO [public]
GO
