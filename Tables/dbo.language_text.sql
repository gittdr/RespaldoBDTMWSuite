CREATE TABLE [dbo].[language_text]
(
[language_identity] [int] NOT NULL IDENTITY(1, 1),
[english] [varchar] (836) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language] [varchar] (890) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[context] [int] NULL,
[language_description] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[font_height] [int] NULL,
[font_weight] [int] NULL,
[font_face] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[font_alignment] [int] NULL,
[ps_context] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_language_text_ps_context] DEFAULT ('UNKNOWN'),
[lt_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lt_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_language_text] ON [dbo].[language_text] FOR INSERT, UPDATE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

BEGIN
	
	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

	UPDATE 	language_text
	SET 	language_text.lt_updatedby = UPPER(@tmwuser),
		language_text.lt_updatedon = GETDATE()
	FROM 	inserted
       WHERE 	language_text.language_identity = inserted.language_identity
END

GO
ALTER TABLE [dbo].[language_text] ADD CONSTRAINT [PK_language_text] PRIMARY KEY CLUSTERED ([language_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_language_text] ON [dbo].[language_text] ([english], [language_id], [context]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_language_text_english] ON [dbo].[language_text] ([english], [language_id], [context]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_language_text] ON [dbo].[language_text] ([language_id], [english], [context], [ps_context]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[language_text] TO [public]
GO
GRANT INSERT ON  [dbo].[language_text] TO [public]
GO
GRANT REFERENCES ON  [dbo].[language_text] TO [public]
GO
GRANT SELECT ON  [dbo].[language_text] TO [public]
GO
GRANT UPDATE ON  [dbo].[language_text] TO [public]
GO
