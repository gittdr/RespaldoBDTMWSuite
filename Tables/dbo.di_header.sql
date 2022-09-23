CREATE TABLE [dbo].[di_header]
(
[dih_id] [int] NOT NULL IDENTITY(1, 1),
[dih_date] [datetime] NULL,
[dih_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dih_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dih_createdt] [datetime] NULL,
[dih_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dih_lastupdatedt] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[iut_di_header] ON [dbo].[di_header] FOR INSERT, UPDATE 
AS 

Set NOCOUNT ON

DECLARE	@updatecount	      INTEGER,
         @delcount            INTEGER

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

SELECT @updatecount = COUNT(*) FROM inserted
SELECT @delcount = COUNT(*) FROM deleted

-- If inserting a row, set the Created by and Create Date fields.
If @updatecount > 0 and @delcount = 0 -- insert 
BEGIN
	Update di_header
	set dih_createby = @tmwuser,
		dih_createdt = GetDate()
	from di_header, inserted
	where di_header.dih_id = inserted.dih_id

end 

-- If updating the row, set the lasted edit ID and Date
If @updatecount > 0 and @delcount > 0 -- update
Begin
	Update di_header
	set dih_lastupdateby = @tmwuser,
		dih_lastupdatedt = GetDate()
	from di_header, inserted
	where di_header.dih_id = inserted.dih_id


End

GO
ALTER TABLE [dbo].[di_header] ADD CONSTRAINT [pk_dih_id] PRIMARY KEY CLUSTERED ([dih_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[di_header] TO [public]
GO
GRANT INSERT ON  [dbo].[di_header] TO [public]
GO
GRANT SELECT ON  [dbo].[di_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[di_header] TO [public]
GO
