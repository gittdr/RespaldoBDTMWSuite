CREATE TABLE [dbo].[AutomationIFHeader]
(
[IFName] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldSeparator] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSeparator] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HeaderVersion] [int] NULL,
[COMObjName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CharacterSet] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFPath] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create TRIGGER [dbo].[dt_automationIFHeader]
	ON [dbo].[AutomationIFHeader]
	FOR DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	/* CASCADE DELETE RECORDS IN AutomationIFDetail */
	BEGIN
	
	DELETE AutomationIFDetail 
	FROM	automationifdetail, deleted
	WHERE RTRIM(LTRIM(AutomationIFDetail.ifname)) = RTRIM(LTRIM(deleted.ifname))
	
	END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create TRIGGER [dbo].[ut_automationIFHeader]
	ON [dbo].[AutomationIFHeader]
	FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
	/* CASCADE DELETE RECORDS IN AutomationIFDetail */
	BEGIN

	If update(IFName)
	   BEGIN
		 update AutomationIFDetail set AutomationIFDetail.ifname = inserted.ifname from inserted, deleted where AutomationIFDetail.ifname = deleted.ifname
	   END

	END
GO
ALTER TABLE [dbo].[AutomationIFHeader] ADD CONSTRAINT [PK__AutomationIFHead__3A8D6B76] PRIMARY KEY CLUSTERED ([IFName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AutomationIFHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[AutomationIFHeader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AutomationIFHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[AutomationIFHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[AutomationIFHeader] TO [public]
GO
