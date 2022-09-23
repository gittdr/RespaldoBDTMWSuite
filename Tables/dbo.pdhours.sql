CREATE TABLE [dbo].[pdhours]
(
[pdh_identity] [int] NOT NULL IDENTITY(1, 1),
[pyd_number] [int] NOT NULL,
[pdh_standardhours] [decimal] (9, 2) NOT NULL,
[pdh_othours] [decimal] (9, 2) NOT NULL,
[pdh_eihours] [decimal] (9, 2) NOT NULL,
[pdh_weeknum] [int] NOT NULL,
[pdh_year] [int] NOT NULL,
[pdh_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pdh_date] [datetime] NOT NULL,
[pdh_miles] [decimal] (9, 2) NOT NULL,
[pdh_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pdh_createddate] [datetime] NULL,
[pdh_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pdh_updateddate] [datetime] NULL,
[pdh_stp_number] [int] NULL,
[pdh_pyhpayperiod] [datetime] NULL,
[pdh_recadjtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[it_pdhours] on [dbo].[pdhours] for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

	update pdhours set pdh_createdby = @tmwuser,pdh_createddate =getdate()
	from inserted where pdhours.pdh_identity = inserted.pdh_identity
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[ut_pdhours] on [dbo].[pdhours] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

	update pdhours set pdh_updatedby = @tmwuser,pdh_updateddate =getdate()
	from inserted where pdhours.pdh_identity = inserted.pdh_identity
GO
ALTER TABLE [dbo].[pdhours] ADD CONSTRAINT [pk_pdhours] PRIMARY KEY CLUSTERED ([pdh_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_date] ON [dbo].[pdhours] ([pdh_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pdhours_pydnumber] ON [dbo].[pdhours] ([pyd_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pdhours] TO [public]
GO
GRANT INSERT ON  [dbo].[pdhours] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pdhours] TO [public]
GO
GRANT SELECT ON  [dbo].[pdhours] TO [public]
GO
GRANT UPDATE ON  [dbo].[pdhours] TO [public]
GO
