CREATE TABLE [dbo].[legheader_driver_hours]
(
[ldh_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ldh_drv_hours] [decimal] (10, 2) NULL,
[ldh_drv_ld_unld_hrs] [decimal] (10, 2) NULL,
[last_updateddt] [datetime] NULL,
[last_updatedby] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE TRIGGER [dbo].[iut_legheader_driver_hours] ON [dbo].[legheader_driver_hours]
	FOR Insert, Update
AS 	
	Declare 
	@updatecount	int,
	@deletecount	int,
	@inserted		int
	
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output
	
	select @deletecount = count(*) from deleted
	select @inserted = count(*) from inserted
	select @updatecount = (select count(*) from legheader_driver_hours join Deleted on legheader_driver_hours.ldh_id = Deleted.ldh_id)
		
	-- Set the Time and User id on Updated records
	if @inserted > 0 
		update legheader_driver_hours
		set last_updateddt = getdate(),
			last_updatedby = @tmwuser
		from inserted i join legheader_driver_hours l on i.lgh_number = l.lgh_number
			and ((l.last_updatedby <> @tmwuser) OR
				isnull(l.last_updateddt,'19500101') <> getdate())

	


GO
ALTER TABLE [dbo].[legheader_driver_hours] ADD CONSTRAINT [pk_ldh_id] PRIMARY KEY CLUSTERED ([ldh_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_lgh_number_mppIid] ON [dbo].[legheader_driver_hours] ([lgh_number], [mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader_driver_hours] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader_driver_hours] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legheader_driver_hours] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader_driver_hours] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader_driver_hours] TO [public]
GO
