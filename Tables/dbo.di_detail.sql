CREATE TABLE [dbo].[di_detail]
(
[did_id] [int] NOT NULL IDENTITY(1, 1),
[dih_id] [int] NOT NULL,
[mpp_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[did_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[did_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[did_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[did_createdt] [datetime] NULL,
[did_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[did_lastupdatedt] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[iut_di_detail] ON [dbo].[di_detail] FOR INSERT, UPDATE 
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
	Update di_detail
	set did_createby = @tmwuser,
		did_createdt = GetDate()
	from di_detail, inserted
	where di_detail.did_id = inserted.did_id

end 

-- If updating the row, set the lasted edit ID and Date
If @updatecount > 0 and @delcount > 0 -- update
Begin
	Update di_detail
	set did_lastupdateby = @tmwuser,
		did_lastupdatedt = GetDate()
	from di_detail, inserted
	where di_detail.did_id = inserted.did_id


End

GO
ALTER TABLE [dbo].[di_detail] ADD CONSTRAINT [pk_did_id] PRIMARY KEY CLUSTERED ([did_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_dih_id] ON [dbo].[di_detail] ([dih_id], [did_id], [mpp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mpp_id] ON [dbo].[di_detail] ([mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[di_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[di_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[di_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[di_detail] TO [public]
GO
