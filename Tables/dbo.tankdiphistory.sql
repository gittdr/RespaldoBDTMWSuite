CREATE TABLE [dbo].[tankdiphistory]
(
[tank_nbr] [int] NOT NULL,
[tank_dip_date] [datetime] NOT NULL,
[tank_dip_shift] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tank_dip] [smallint] NULL,
[tank_inventoryqty] [int] NULL,
[tank_ullageqty] [int] NULL,
[tank_deliveredqty] [int] NULL,
[ord_hdrnumber] [int] NULL,
[tank_sales] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_tankdiphistory]
ON [dbo].[tankdiphistory] FOR DELETE

as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/**
 * 
 * NAME:
 * dbo.dt_tankdiphistory
 *
 * TYPE:
 * Trigger|D] 
 *
 * DESCRIPTION:
 * This trigger logs deletions to the tankdiphistory table
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * none
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * none

 * 
 * REVISION HISTORY:
 * 09/26/05.01 ? PTS30564 - DHUDE ? Created Trigger
 *
 **/

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

INSERT INTO tankdiphistory_deletelog (
	tank_nbr,
	tank_dip_date,
	tank_dip_shift,
	tank_dip,
	tank_inventoryqty,
	tank_ullageqty,
	tank_deliveredqty,
	ord_hdrnumber,
	tank_sales,
	tdl_appname,
	tdl_userid,
	tdl_datetime)
SELECT	tank_nbr,
	tank_dip_date,
	tank_dip_shift,
	tank_dip,
	tank_inventoryqty,
	tank_ullageqty,
	tank_deliveredqty,
	ord_hdrnumber,
	tank_sales,
	app_name(),
	@tmwuser,
	getdate()
FROM	deleted

GO
ALTER TABLE [dbo].[tankdiphistory] ADD CONSTRAINT [pk_tankdiphistory] PRIMARY KEY CLUSTERED ([tank_nbr], [tank_dip_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tankdiphistory] TO [public]
GO
GRANT INSERT ON  [dbo].[tankdiphistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tankdiphistory] TO [public]
GO
GRANT SELECT ON  [dbo].[tankdiphistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[tankdiphistory] TO [public]
GO
