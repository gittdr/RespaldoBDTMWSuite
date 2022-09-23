CREATE TABLE [dbo].[userobject]
(
[id] [int] NOT NULL,
[object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[view_type] [smallint] NOT NULL,
[dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_type1] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[view_versiondate] [datetime] NULL,
[original_dwsyntax] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_view] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zoom] [smallint] NULL,
[dw_horz_scroll_split] [int] NULL,
[dw_horz_scroll_pos2] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_userobject] ON [dbo].[userobject] FOR DELETE AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DELETE	userobject_defaults
 WHERE	id IN (SELECT id FROM deleted)

UPDATE	dispatchview
SET		dv_config_id = null, dv_config = null
WHERE	dv_config_id IN (SELECT id FROM deleted)

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  TRIGGER [dbo].[itut_userobject] ON [dbo].[userobject] FOR INSERT, UPDATE
AS
/**
 * 
 * NAME:
 * dbo.itut_userobject
 *
 * TYPE:
 * [Trigger] 
 *
 * DESCRIPTION:
 * This trigger rejects and changes to the userobject table except from admin users if GI setting ScreenDesignForAdminUsersOnly = Y
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * 
 * REVISION HISTORY:
 * 04/18/2006.01 ? PTS32630 - DPETE ? Created. Pauls Hauling wants to disallow non admins from saving trip grids
 *
 **/


declare @tmwuser varchar(255),@uoid int,@thisuoid int
exec gettmwuser @tmwuser output


if exists (Select  1  from generalinfo where gi_name = 'ScreenDesignForAdminUsersOnly' and upper(left(gi_string1,1)) = 'Y')
 and not exists (select 1 from ttsusers where usr_userid =  @tmwuser and isnull(usr_sysadmin,'N') =  'Y')
  BEGIN
      /* disable screen design by changing the name (append user id) and raise an error */
	raiserror('GI setting does not allow non Admin users to save custom views.',16,1)
     	rollback transaction
        return

      
  END


return
GO
ALTER TABLE [dbo].[userobject] ADD CONSTRAINT [pk_userobject] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_userobject] ON [dbo].[userobject] ([description], [user_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ck_userobject] ON [dbo].[userobject] ([object], [user_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userobject] TO [public]
GO
GRANT INSERT ON  [dbo].[userobject] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userobject] TO [public]
GO
GRANT SELECT ON  [dbo].[userobject] TO [public]
GO
GRANT UPDATE ON  [dbo].[userobject] TO [public]
GO
