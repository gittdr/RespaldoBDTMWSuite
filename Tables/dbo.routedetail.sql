CREATE TABLE [dbo].[routedetail]
(
[rth_id] [int] NOT NULL,
[rtd_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cty_code] [int] NOT NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtd_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttr_number] [int] NOT NULL,
[rtd_sequence] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[dt_routedetail] on [dbo].[routedetail] for delete as

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
exec gettmwuser @tmwuser output

insert into routedetail_audit 
Select rth_id,rtd_id,cmp_id,cty_code,cty_nmstct,rtd_zip ,ttr_number, @tmwuser,getdate(),'D' from deleted
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[it_routedetail] on [dbo].[routedetail] for insert as

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
exec gettmwuser @tmwuser output

insert into routedetail_audit 
Select rth_id,rtd_id,cmp_id,cty_code,cty_nmstct,rtd_zip ,ttr_number, @tmwuser,getdate(),'I' from inserted
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_routedetail] on [dbo].[routedetail] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

insert into routedetail_audit 
Select rth_id,rtd_id,cmp_id,cty_code,cty_nmstct,rtd_zip ,ttr_number, @tmwuser,getdate(),'U' from inserted
GO
ALTER TABLE [dbo].[routedetail] ADD CONSTRAINT [pk_routedetail] PRIMARY KEY CLUSTERED ([rth_id], [rtd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[routedetail] TO [public]
GO
GRANT INSERT ON  [dbo].[routedetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[routedetail] TO [public]
GO
GRANT SELECT ON  [dbo].[routedetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[routedetail] TO [public]
GO
