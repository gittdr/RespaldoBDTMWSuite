CREATE TABLE [dbo].[reportobject]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[dwobjectname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[apply_format] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL,
[last_updateby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_reportobject_changelog]
ON [dbo].[reportobject]
FOR INSERT, UPDATE 
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @updatecount	int,
	@delcount	int

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted

if (@updatecount > 0 and not update(last_updateby) and not update(last_updatedate)) OR
	(@updatecount > 0 and @delcount = 0)
	Update reportobject
	set last_updateby = @tmwuser,
		last_updatedate = getdate()
	from inserted
	where inserted.id = reportobject.id
		and (isNull(reportobject.last_updateby,'') <> @tmwuser
		OR isNull(reportobject.last_updatedate,'19500101') <> getdate())
		
GO
ALTER TABLE [dbo].[reportobject] ADD CONSTRAINT [pk_reportobject] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_dwobjectname] ON [dbo].[reportobject] ([dwobjectname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reportobject] TO [public]
GO
GRANT INSERT ON  [dbo].[reportobject] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reportobject] TO [public]
GO
GRANT SELECT ON  [dbo].[reportobject] TO [public]
GO
GRANT UPDATE ON  [dbo].[reportobject] TO [public]
GO
