CREATE TABLE [dbo].[recordlockingtable]
(
[rlt_table] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rlt_tablekey] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rlt_userid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_rlt_userid] DEFAULT (user_name()),
[rlt_workstation] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_rlt_workstation] DEFAULT (host_name()),
[rlt_sessionid] [int] NOT NULL CONSTRAINT [df_rlt_sessionind] DEFAULT (@@spid),
[rlt_applicationid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_rlt_applicationid] DEFAULT (app_name()),
[rlt_locktime] [datetime] NOT NULL CONSTRAINT [df_rlt_locktime] DEFAULT (getdate()),
[rlt_lockexpires] [datetime] NULL,
[rlt_instanceid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_recordlockingtable] ON [dbo].[recordlockingtable] 
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DELETE FROM recordlock WHERE ord_hdrnumber in (SELECT DISTINCT rlt_tablekey FROM deleted WHERE rlt_table = 'movement')

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_recordlockingtable] ON [dbo].[recordlockingtable] 
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DELETE FROM recordlock WHERE ord_hdrnumber in (SELECT DISTINCT rlt_tablekey FROM inserted WHERE rlt_table = 'movement')

	INSERT INTO recordlock (ord_hdrnumber, locked_by, session_date) 
    SELECT DISTINCT rlt_tablekey, rlt_userid, rlt_locktime FROM inserted WHERE rlt_table = 'movement'

END
GO
ALTER TABLE [dbo].[recordlockingtable] ADD CONSTRAINT [pk_recordlockingtable] PRIMARY KEY CLUSTERED ([rlt_table], [rlt_tablekey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_recordlocking_expires] ON [dbo].[recordlockingtable] ([rlt_lockexpires]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[recordlockingtable] TO [public]
GO
GRANT INSERT ON  [dbo].[recordlockingtable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[recordlockingtable] TO [public]
GO
GRANT SELECT ON  [dbo].[recordlockingtable] TO [public]
GO
GRANT UPDATE ON  [dbo].[recordlockingtable] TO [public]
GO
