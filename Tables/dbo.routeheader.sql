CREATE TABLE [dbo].[routeheader]
(
[rth_id] [int] NOT NULL,
[rth_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[dt_routeheader] on [dbo].[routeheader] for delete as

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
exec gettmwuser @tmwuser output

insert into routeheader_audit 
Select rth_id,rth_name, @tmwuser,getdate(),'D' from deleted
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[it_routeheader] on [dbo].[routeheader] for insert as

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
exec gettmwuser @tmwuser output

insert into routeheader_audit 
Select rth_id,rth_name, @tmwuser,getdate(),'I' from inserted
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_routeheader] on [dbo].[routeheader] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

insert into routeheader_audit 
Select rth_id,rth_name, @tmwuser,getdate(),'U' from inserted
GO
ALTER TABLE [dbo].[routeheader] ADD CONSTRAINT [pk_routeheader] PRIMARY KEY CLUSTERED ([rth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routeheader] TO [public]
GO
GRANT INSERT ON  [dbo].[routeheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routeheader] TO [public]
GO
GRANT SELECT ON  [dbo].[routeheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[routeheader] TO [public]
GO
