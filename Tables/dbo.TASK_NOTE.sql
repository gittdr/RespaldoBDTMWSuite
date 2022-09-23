CREATE TABLE [dbo].[TASK_NOTE]
(
[TASK_NOTE_ID] [int] NOT NULL IDENTITY(1, 1),
[TASK_ID] [int] NOT NULL,
[NOTE_TEXT] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CREATED_DATE] [datetime] NOT NULL,
[CREATED_USER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL,
[MODIFIED_USER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[dt_task_note] on [dbo].[TASK_NOTE] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
-- Provides dt_task_note.sql
-- Requires none
/* Revision History:
	4/5/2004	Greg Kanzinger		cgk	PTS 16341
*/

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--CGK	Don't insert audit row unless the feature is turned on..
if exists (select * from generalinfo where gi_name = 'TaskNoteAudit' and gi_string1 = 'Y')
	--cgk
	--Insert expedite_audit row..
	insert into TASK_NOTE_AUDIT (TASK_NOTE_ID, TASK_ID, CREATED_DATE, CREATED_USER, MODIFIED_DATE, MODIFIED_USER, AUDIT_ACTION, AUDIT_CREATED_DATE, AUDIT_CREATED_USER)
	  (select TASK_NOTE_ID, TASK_ID, CREATED_DATE, CREATED_USER, MODIFIED_DATE, MODIFIED_USER,  'DELETE', getdate (), @tmwuser 
	  from	deleted )

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[it_task_note] on [dbo].[TASK_NOTE] for insert
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
-- Provides it_task_note.sql
-- Requires none
/* Revision History:
	4/5/2004	Greg Kanzinger		cgk	PTS 16341
*/

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--CGK	Don't insert audit row unless the feature is turned on..
if exists (select * from generalinfo where gi_name = 'TaskNoteAudit' and gi_string1 = 'Y')
	--cgk
	--Insert expedite_audit row..
	insert into TASK_NOTE_AUDIT
	  select A.* , 'INSERT', getdate (), @tmwuser 
	  from	inserted, TASK_NOTE A 
	  where inserted.TASK_NOTE_ID = A.TASK_NOTE_ID


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		emolvera
-- Create date: 30 dic 2014 12:24
-- Description:	envia mail notas
-- =============================================
CREATE TRIGGER [dbo].[trg_enviacorreonota] 
   ON  [dbo].[TASK_NOTE]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  
declare @cuerpo as varchar(500)
declare @asunto as varchar (200)
declare @destinatario as varchar(100)



select @destinatario = (select isnull(( select usr_mail_address  from ttsusers where usr_userid = (select ASSIGNED_USER from task where task.task_id = inserted.task_id)),'') 
 +   isnull((select ';' + brn_email  from branch where branch.brn_id = (select BRN_ID from task where task.task_id = inserted.task_id)),'') from inserted)
select @asunto = (select (select  'Se ha agregado una nota a la actividad ' + name from task where inserted.TASK_ID = task.task_id) from inserted)
select @cuerpo =  (select  ( select usr_fname + ' ' + usr_lname from ttsusers where usr_userid =  CREATED_USER) 
                    + ' ha agregado un comentario'  +' para la actividad ' +  (select (select name from task where inserted.TASK_ID = task.task_id) from inserted) + ' relacionada al cliente ' +
					 (select cmp_name from company where cmp_id = (select TASK_LINK_ENTITY_VALUE from task where task.task_id = inserted.task_id)) + 
					 ' la cual vence el: ' + (select  cast(DUE_DATE as varchar(50)) from task where task.task_id = inserted.task_id) 
					+ ' Favor de revisar los detalles en tu CRM' from inserted)

	SET NOCOUNT ON;


	if @destinatario != '' 
	 BEGIN
             EXEC msdb.dbo.sp_send_dbmail
             @profile_name = 'smtp TDR',
             @recipients = @destinatario ,
             @copy_recipients = '',
             @body = @cuerpo,
             @subject = @asunto,
             @attach_query_result_as_file = 0 ;
	END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE trigger [dbo].[ut_task_note] on [dbo].[TASK_NOTE] for update
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
-- Provides ut_task_note.sql
-- Requires none
/* Revision History:
	4/5/2004	Greg Kanzinger		cgk	PTS 16341
*/

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--CGK	Don't insert audit row unless the feature is turned on..
if exists (select * from generalinfo where gi_name = 'TaskNoteAudit' and gi_string1 = 'Y')
	--cgk
	--Insert expedite_audit row..
	insert into TASK_NOTE_AUDIT
	  select A.* , 'UPDATE', getdate (), @tmwuser 
	  from	inserted, TASK_NOTE A 
	  where inserted.TASK_NOTE_ID = A.TASK_NOTE_ID

GO
ALTER TABLE [dbo].[TASK_NOTE] ADD CONSTRAINT [PK__TASK_NOTE__7BFD9E25] PRIMARY KEY CLUSTERED ([TASK_NOTE_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_TASK_ID] ON [dbo].[TASK_NOTE] ([TASK_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TASK_NOTE] TO [public]
GO
GRANT INSERT ON  [dbo].[TASK_NOTE] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TASK_NOTE] TO [public]
GO
GRANT SELECT ON  [dbo].[TASK_NOTE] TO [public]
GO
GRANT UPDATE ON  [dbo].[TASK_NOTE] TO [public]
GO
