CREATE TABLE [dbo].[MCTRANSREASON]
(
[MCT_TRANS] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCT_REASON] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCT_DISREASON] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCT_UPDTDATE] [datetime] NULL,
[MCT_USERID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[mcttrans_updt] ON [dbo].[MCTRANSREASON] FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
BEGIN

	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

	UPDATE	MCTRANSREASON
	SET	MCT_USERID = @tmwuser,
		MCT_UPDTDATE = GETDATE()
	FROM	MCTRANSREASON m, inserted i
	WHERE	m.MCT_TRANS = i.MCT_TRANS
END


GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_mcttrans] ON [dbo].[MCTRANSREASON] ([MCT_TRANS]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MCTRANSREASON] TO [public]
GO
GRANT INSERT ON  [dbo].[MCTRANSREASON] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MCTRANSREASON] TO [public]
GO
GRANT SELECT ON  [dbo].[MCTRANSREASON] TO [public]
GO
GRANT UPDATE ON  [dbo].[MCTRANSREASON] TO [public]
GO
