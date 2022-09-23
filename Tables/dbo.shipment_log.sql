CREATE TABLE [dbo].[shipment_log]
(
[sl_id] [int] NOT NULL IDENTITY(1, 1),
[sl_order] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sl_lgh_number] [int] NULL,
[sl_station] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_citystate] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_empname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_transtype] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_pieces] [int] NULL,
[sl_overage] [int] NULL,
[sl_shortage] [int] NULL,
[sl_damaged] [int] NULL,
[sl_datetime] [datetime] NULL,
[sl_filename] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_updatedby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sl_updatedon] [datetime] NULL,
[sl_createdate] [datetime] NULL,
[sl_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_shipment_log]
ON [dbo].[shipment_log]
FOR INSERT, Update
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @tmwuser varchar (255),
	@updatecount	int,
	@delcount	int

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

exec gettmwuser @tmwuser output


if (@updatecount > 0 and @delcount = 0)
	Update shipment_log
	set sl_updatedby = @tmwuser,
		sl_updatedon = getdate(),
		sl_createdate = getdate(),
		sl_createby = @tmwuser
	from inserted
	where inserted.sl_id = shipment_log.sl_id
else

	Update shipment_log
	set sl_updatedby = @tmwuser,
		sl_updatedon = getdate()
	from inserted
	where inserted.sl_id = shipment_log.sl_id

GO
GRANT DELETE ON  [dbo].[shipment_log] TO [public]
GO
GRANT INSERT ON  [dbo].[shipment_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[shipment_log] TO [public]
GO
GRANT SELECT ON  [dbo].[shipment_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[shipment_log] TO [public]
GO
