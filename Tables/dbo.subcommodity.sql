CREATE TABLE [dbo].[subcommodity]
(
[scm_identity] [int] NOT NULL IDENTITY(1, 1),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scm_subcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scm_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scm_UpdateBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scm_UpdateDate] [datetime] NOT NULL,
[scm_exclusive] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__subcommod__scm_e__57817578] DEFAULT ('N')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE TRIGGER [dbo].[itut_subcommodity]  
ON [dbo].[subcommodity] 
FOR insert,update  
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_subcommodity 
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This procedure updates the userid and date of last update
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: 

 * 
 * REVISION HISTORY:
 * 12/20/2005.01 ? PTS30355 - Donna Petersen - Customer call asking who last updated row
 *  4/`9/08 PTS 40260 Pauls recode into main
 **/
declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output

update subcommodity
set scm_updateby = @tmwuser ,scm_updatedate = getdate()
from inserted
where inserted.cmd_code = subcommodity.cmd_code
and inserted.scm_subcode = subcommodity.scm_subcode
and (isNull(subcommodity.scm_updateby,'') <> @tmwuser 
or isNull(subcommodity.scm_updatedate,'19500101') <> getdate())

return

GO
ALTER TABLE [dbo].[subcommodity] ADD CONSTRAINT [pk_scmidentity] PRIMARY KEY CLUSTERED ([scm_identity]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_cmdscm] ON [dbo].[subcommodity] ([cmd_code], [scm_subcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[subcommodity] TO [public]
GO
GRANT INSERT ON  [dbo].[subcommodity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[subcommodity] TO [public]
GO
GRANT SELECT ON  [dbo].[subcommodity] TO [public]
GO
GRANT UPDATE ON  [dbo].[subcommodity] TO [public]
GO
