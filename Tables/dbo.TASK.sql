CREATE TABLE [dbo].[TASK]
(
[TASK_ID] [int] NOT NULL IDENTITY(1, 1),
[TASK_TEMPLATE_ID] [int] NULL,
[NAME] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME_P] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_LINK_ENTITY_VALUE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_LINK_ENTITY_SYS_VALUE] [int] NULL,
[TASK_LINK_ENTITY_TABLE_ID] [int] NULL,
[DESCRIPTION] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESCRIPTION_P] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESCRIPTION_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORIGINAL_DUE_DATE] [datetime] NULL,
[ASSIGNED_USER] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASSIGNED_USER_P] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASSIGNED_USER_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DUE_DATE] [datetime] NOT NULL,
[DUE_DATE_P] [datetime] NULL,
[DUE_DATE_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LEAD_TIME] [int] NOT NULL,
[LEAD_TIME_P] [int] NULL,
[LEAD_TIME_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIORITY] [int] NULL,
[PRIORITY_P] [int] NULL,
[PRIORITY_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMPLETED_DATE] [datetime] NULL,
[ACTIVE_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIVE_FLAG_P] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIVE_FLAG_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS_P] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CREATED_DATE] [datetime] NOT NULL,
[CREATED_USER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MODIFIED_DATE] [datetime] NOT NULL,
[MODIFIED_USER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[USER_DEFINED_TYPE1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE1_P] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE1_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE2] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE2_P] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE2_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE3] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE3_P] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE3_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE4] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE4_P] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_DEFINED_TYPE4_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PENDING_CHANGES_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO7] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO8] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO9] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO10] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO11] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO12] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO13] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO14] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO15] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT_ADD_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GENERATION_RULE_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT_EDIT_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT_DELETE_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT_HOLD_FLAG] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_TYPE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_TYPE_P] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_TYPE_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_NAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_NAME_P] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_NAME_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_PHONE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_PHONE_P] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_PHONE_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_PHONE_EXT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_PHONE_EXT_P] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_PHONE_EXT_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_EMAIL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_EMAIL_P] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONTACT_EMAIL_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BRN_ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BRN_ID_P] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BRN_ID_F] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WORKFLOW_ID] [int] NULL,
[END_DATE] [datetime] NULL,
[ALL_DAY_EVENT] [tinyint] NULL,
[REMINDER_ENABLED] [int] NULL,
[REMINDER_INTERVAL] [int] NULL,
[REMINDER_UNITS] [int] NULL,
[ACTIVITY_TYPE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_activity_type] DEFAULT ('UNK'),
[SNOOZED] [int] NULL,
[SNOOZE_INTERVAL] [int] NULL,
[SNOOZE_UNITS] [int] NULL,
[SNOOZE_TIME] [datetime] NULL,
[OUTLOOK_ID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OUTLOOK_DEFAULTFOLDER_ID] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REMIND_ALL_USERS] [bit] NULL,
[Communication_Setting] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO16] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO17] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO18] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO19] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDL_INFO20] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[dt_task] on [dbo].[TASK] for delete
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
-- Provides dt_task.sql
-- Requires none
/* Revision History:
	4/5/2004	Greg Kanzinger		cgk	PTS 16341
*/

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--CGK	Don't insert audit row unless the feature is turned on..
if exists (select * from generalinfo where gi_name = 'TaskAudit' and gi_string1 = 'Y')
	--cgk
	--Insert expedite_audit row..
--	insert into TASK_AUDIT
--	  select *, 'DELETE', getdate (), @tmwuser 
--	  from	deleted
-- PTS 27731 CGK 4/11/2005
	insert into TASK_AUDIT (TASK_ID, TASK_TEMPLATE_ID, NAME, NAME_P, NAME_F, TASK_LINK_ENTITY_VALUE, TASK_LINK_ENTITY_SYS_VALUE, 
                      TASK_LINK_ENTITY_TABLE_ID, DESCRIPTION, DESCRIPTION_P, DESCRIPTION_F, ORIGINAL_DUE_DATE, ASSIGNED_USER, ASSIGNED_USER_P, 
                      ASSIGNED_USER_F, DUE_DATE, DUE_DATE_P, DUE_DATE_F, LEAD_TIME, LEAD_TIME_P, LEAD_TIME_F, PRIORITY, PRIORITY_P, PRIORITY_F, 
                      COMPLETED_DATE, ACTIVE_FLAG, ACTIVE_FLAG_P, ACTIVE_FLAG_F, STATUS, STATUS_P, STATUS_F, CREATED_DATE, CREATED_USER, 
                      MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE1_P, USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2, 
                      USER_DEFINED_TYPE2_P, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3, USER_DEFINED_TYPE3_P, USER_DEFINED_TYPE3_F, 
                      USER_DEFINED_TYPE4, USER_DEFINED_TYPE4_P, USER_DEFINED_TYPE4_F, PENDING_CHANGES_FLAG, ADDL_INFO1, ADDL_INFO2, 
                      ADDL_INFO3, ADDL_INFO4, ADDL_INFO5, ADDL_INFO6, ADDL_INFO7, ADDL_INFO8, ADDL_INFO9, ADDL_INFO10, ADDL_INFO11, ADDL_INFO12, 
                      ADDL_INFO13, ADDL_INFO14, ADDL_INFO15, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, PROMPT_HOLD_FLAG, 
                      GENERATION_RULE_FLAG, AUDIT_ACTION, AUDIT_CREATED_DATE, AUDIT_CREATED_USER)
	select TASK_ID, TASK_TEMPLATE_ID, NAME, NAME_P, NAME_F, TASK_LINK_ENTITY_VALUE, TASK_LINK_ENTITY_SYS_VALUE, 
                      TASK_LINK_ENTITY_TABLE_ID, DESCRIPTION, DESCRIPTION_P, DESCRIPTION_F, ORIGINAL_DUE_DATE, ASSIGNED_USER, ASSIGNED_USER_P, 
                      ASSIGNED_USER_F, DUE_DATE, DUE_DATE_P, DUE_DATE_F, LEAD_TIME, LEAD_TIME_P, LEAD_TIME_F, PRIORITY, PRIORITY_P, PRIORITY_F, 
                      COMPLETED_DATE, ACTIVE_FLAG, ACTIVE_FLAG_P, ACTIVE_FLAG_F, STATUS, STATUS_P, STATUS_F, CREATED_DATE, CREATED_USER, 
                      MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE1_P, USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2, 
                      USER_DEFINED_TYPE2_P, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3, USER_DEFINED_TYPE3_P, USER_DEFINED_TYPE3_F, 
                      USER_DEFINED_TYPE4, USER_DEFINED_TYPE4_P, USER_DEFINED_TYPE4_F, PENDING_CHANGES_FLAG, ADDL_INFO1, ADDL_INFO2, 
                      ADDL_INFO3, ADDL_INFO4, ADDL_INFO5, ADDL_INFO6, ADDL_INFO7, ADDL_INFO8, ADDL_INFO9, ADDL_INFO10, ADDL_INFO11, ADDL_INFO12, 
                      ADDL_INFO13, ADDL_INFO14, ADDL_INFO15, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, PROMPT_HOLD_FLAG, 
                      GENERATION_RULE_FLAG, 'DELETE', getdate (), @tmwuser
	from deleted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trg_enviacorreoactividad] 
   ON  [dbo].[TASK] 
   AFTER INSERT
AS 
BEGIN

declare @cuerpo as varchar(MAX)
declare @Tail as varchar(500)
declare @Head as varchar(500)
declare @asunto as varchar (200)
declare @destinatario as varchar(100)


select @destinatario = (select isnull(( select usr_mail_address  from ttsusers where usr_userid = ASSIGNED_USER),'')  +   isnull((select ';' + brn_email  from branch where branch.brn_id = inserted.BRN_ID),'') from inserted)
select @asunto =  (select 'Nueva actividad CRM: ' + NAME + ' : ' + cast(DUE_DATE as varchar(50))+ ' to ' + cast(END_DATE as varchar(50)) from inserted)



select @cuerpo = '<html>
  <body>
    <script type="application/ld+json">'
+'{
  "@context": "http://schema.org",
  "@type": "EventReservation",
  "reservationNumber": "E123456789",
  "reservationStatus": "http://schema.org/Confirmed",
  "underName": {
    "@type": "Person",
    "name": "John Smith"
  },
  "reservationFor": {
    "@type": "Event",
    "name": "Foo Fighters Concert",
    "startDate": "2017-04-20T19:30:00-08:00",
    "location": {
      "@type": "Place",
      "name": "AT&T Park",
      "address": {
        "@type": "PostalAddress",
        "streetAddress": "24 Willie Mays Plaza",
        "addressLocality": "San Francisco",
        "addressRegion": "CA",
        "postalCode": "94107",
        "addressCountry": "US"
      }
    }
  }
}'
+'</script>'

   + '<p>'+
     +(select  ( select usr_fname + ' ' + usr_lname from ttsusers where usr_userid =  CREATED_USER) 
    + ' te ha asignado la tarea ' + DESCRIPTION + ' para el cliente ' + 
	(select cmp_name from company where cmp_id = TASK_LINK_ENTITY_VALUE) + 
	 ' : ' + cast(DUE_DATE as varchar(50))+ ' - ' + cast(END_DATE as varchar(50)) from inserted)+'<p>'
   + '</p>
  </body>
</html>'




	SET NOCOUNT ON;


	if @destinatario != '' 
	 BEGIN
             EXEC msdb.dbo.sp_send_dbmail
             @profile_name = 'smtp TDR',
             @recipients = @destinatario ,
             @copy_recipients = '',
             @body = @cuerpo,
			 @body_format = 'HTML',
             @subject = @asunto,
             @attach_query_result_as_file = 0 ;
	END
END


GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[ut_task] on [dbo].[TASK] for update
as
-- Provides ut_task.sql
-- Requires none
/* Revision History:
	4/5/2004	Greg Kanzinger		cgk	PTS 16341
*/


DECLARE @task_id int
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--CGK	Don't insert audit row unless the feature is turned on..
if exists (select * from generalinfo where gi_name = 'TaskAudit' and gi_string1 = 'Y')
	--cgk
	--Insert expedite_audit row..
--	insert into TASK_AUDIT
--	  select *, 'UPDATE', getdate (), @tmwuser 
--	  from	inserted
-- PTS 27731 CGK 4/11/2005

	select @task_id = Max(TASK_ID) from inserted

	IF NOT exists (select TASK_ID from TASK_AUDIT WHERE task_id = @task_id) AND IsNull (@task_id, 0) > 0 Begin
		insert into TASK_AUDIT (TASK_ID, TASK_TEMPLATE_ID, NAME, NAME_P, NAME_F, TASK_LINK_ENTITY_VALUE, TASK_LINK_ENTITY_SYS_VALUE, 
	                      TASK_LINK_ENTITY_TABLE_ID, DESCRIPTION, DESCRIPTION_P, DESCRIPTION_F, ORIGINAL_DUE_DATE, ASSIGNED_USER, ASSIGNED_USER_P, 
	                      ASSIGNED_USER_F, DUE_DATE, DUE_DATE_P, DUE_DATE_F, LEAD_TIME, LEAD_TIME_P, LEAD_TIME_F, PRIORITY, PRIORITY_P, PRIORITY_F, 
	                      COMPLETED_DATE, ACTIVE_FLAG, ACTIVE_FLAG_P, ACTIVE_FLAG_F, STATUS, STATUS_P, STATUS_F, CREATED_DATE, CREATED_USER, 
	                      MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE1_P, USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2, 
	                      USER_DEFINED_TYPE2_P, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3, USER_DEFINED_TYPE3_P, USER_DEFINED_TYPE3_F, 
	                      USER_DEFINED_TYPE4, USER_DEFINED_TYPE4_P, USER_DEFINED_TYPE4_F, PENDING_CHANGES_FLAG, ADDL_INFO1, ADDL_INFO2, 
	                      ADDL_INFO3, ADDL_INFO4, ADDL_INFO5, ADDL_INFO6, ADDL_INFO7, ADDL_INFO8, ADDL_INFO9, ADDL_INFO10, ADDL_INFO11, ADDL_INFO12, 
	                      ADDL_INFO13, ADDL_INFO14, ADDL_INFO15, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, PROMPT_HOLD_FLAG, 
	                      GENERATION_RULE_FLAG, AUDIT_ACTION, AUDIT_CREATED_DATE, AUDIT_CREATED_USER)
		select TASK_ID, TASK_TEMPLATE_ID, NAME, NAME_P, NAME_F, TASK_LINK_ENTITY_VALUE, TASK_LINK_ENTITY_SYS_VALUE, 
	                      TASK_LINK_ENTITY_TABLE_ID, DESCRIPTION, DESCRIPTION_P, DESCRIPTION_F, ORIGINAL_DUE_DATE, ASSIGNED_USER, ASSIGNED_USER_P, 
	                      ASSIGNED_USER_F, DUE_DATE, DUE_DATE_P, DUE_DATE_F, LEAD_TIME, LEAD_TIME_P, LEAD_TIME_F, PRIORITY, PRIORITY_P, PRIORITY_F, 
	                      COMPLETED_DATE, ACTIVE_FLAG, ACTIVE_FLAG_P, ACTIVE_FLAG_F, STATUS, STATUS_P, STATUS_F, CREATED_DATE, CREATED_USER, 
	                      MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE1_P, USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2, 
	                      USER_DEFINED_TYPE2_P, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3, USER_DEFINED_TYPE3_P, USER_DEFINED_TYPE3_F, 
	                      USER_DEFINED_TYPE4, USER_DEFINED_TYPE4_P, USER_DEFINED_TYPE4_F, PENDING_CHANGES_FLAG, ADDL_INFO1, ADDL_INFO2, 
	                      ADDL_INFO3, ADDL_INFO4, ADDL_INFO5, ADDL_INFO6, ADDL_INFO7, ADDL_INFO8, ADDL_INFO9, ADDL_INFO10, ADDL_INFO11, ADDL_INFO12, 
	                      ADDL_INFO13, ADDL_INFO14, ADDL_INFO15, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, PROMPT_HOLD_FLAG, 
	                      GENERATION_RULE_FLAG, 'INSERT', getdate (), @tmwuser
		from deleted 
		where TASK_ID = @task_id
	End

	insert into TASK_AUDIT (TASK_ID, TASK_TEMPLATE_ID, NAME, NAME_P, NAME_F, TASK_LINK_ENTITY_VALUE, TASK_LINK_ENTITY_SYS_VALUE, 
                      TASK_LINK_ENTITY_TABLE_ID, DESCRIPTION, DESCRIPTION_P, DESCRIPTION_F, ORIGINAL_DUE_DATE, ASSIGNED_USER, ASSIGNED_USER_P, 
                      ASSIGNED_USER_F, DUE_DATE, DUE_DATE_P, DUE_DATE_F, LEAD_TIME, LEAD_TIME_P, LEAD_TIME_F, PRIORITY, PRIORITY_P, PRIORITY_F, 
                      COMPLETED_DATE, ACTIVE_FLAG, ACTIVE_FLAG_P, ACTIVE_FLAG_F, STATUS, STATUS_P, STATUS_F, CREATED_DATE, CREATED_USER, 
                      MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE1_P, USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2, 
                      USER_DEFINED_TYPE2_P, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3, USER_DEFINED_TYPE3_P, USER_DEFINED_TYPE3_F, 
                      USER_DEFINED_TYPE4, USER_DEFINED_TYPE4_P, USER_DEFINED_TYPE4_F, PENDING_CHANGES_FLAG, ADDL_INFO1, ADDL_INFO2, 
                      ADDL_INFO3, ADDL_INFO4, ADDL_INFO5, ADDL_INFO6, ADDL_INFO7, ADDL_INFO8, ADDL_INFO9, ADDL_INFO10, ADDL_INFO11, ADDL_INFO12, 
                      ADDL_INFO13, ADDL_INFO14, ADDL_INFO15, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, PROMPT_HOLD_FLAG, 
                      GENERATION_RULE_FLAG, AUDIT_ACTION, AUDIT_CREATED_DATE, AUDIT_CREATED_USER)
	select TASK_ID, TASK_TEMPLATE_ID, NAME, NAME_P, NAME_F, TASK_LINK_ENTITY_VALUE, TASK_LINK_ENTITY_SYS_VALUE, 
                      TASK_LINK_ENTITY_TABLE_ID, DESCRIPTION, DESCRIPTION_P, DESCRIPTION_F, ORIGINAL_DUE_DATE, ASSIGNED_USER, ASSIGNED_USER_P, 
                      ASSIGNED_USER_F, DUE_DATE, DUE_DATE_P, DUE_DATE_F, LEAD_TIME, LEAD_TIME_P, LEAD_TIME_F, PRIORITY, PRIORITY_P, PRIORITY_F, 
                      COMPLETED_DATE, ACTIVE_FLAG, ACTIVE_FLAG_P, ACTIVE_FLAG_F, STATUS, STATUS_P, STATUS_F, CREATED_DATE, CREATED_USER, 
                      MODIFIED_DATE, MODIFIED_USER, USER_DEFINED_TYPE1, USER_DEFINED_TYPE1_P, USER_DEFINED_TYPE1_F, USER_DEFINED_TYPE2, 
                      USER_DEFINED_TYPE2_P, USER_DEFINED_TYPE2_F, USER_DEFINED_TYPE3, USER_DEFINED_TYPE3_P, USER_DEFINED_TYPE3_F, 
                      USER_DEFINED_TYPE4, USER_DEFINED_TYPE4_P, USER_DEFINED_TYPE4_F, PENDING_CHANGES_FLAG, ADDL_INFO1, ADDL_INFO2, 
                      ADDL_INFO3, ADDL_INFO4, ADDL_INFO5, ADDL_INFO6, ADDL_INFO7, ADDL_INFO8, ADDL_INFO9, ADDL_INFO10, ADDL_INFO11, ADDL_INFO12, 
                      ADDL_INFO13, ADDL_INFO14, ADDL_INFO15, PROMPT_ADD_FLAG, PROMPT_EDIT_FLAG, PROMPT_DELETE_FLAG, PROMPT_HOLD_FLAG, 
                      GENERATION_RULE_FLAG, 'UPDATE', getdate (), @tmwuser
	from inserted

GO
ALTER TABLE [dbo].[TASK] ADD CONSTRAINT [PK__TASK__708BEB79] PRIMARY KEY CLUSTERED ([TASK_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_TASK_DUE_DATE] ON [dbo].[TASK] ([DUE_DATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_STATUS] ON [dbo].[TASK] ([STATUS]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_TASK_TASK_LINK_ENTITY_SYS_VALUE] ON [dbo].[TASK] ([TASK_LINK_ENTITY_SYS_VALUE], [TASK_LINK_ENTITY_TABLE_ID], [ACTIVE_FLAG]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_TASK_TEMPLATE_ID] ON [dbo].[TASK] ([TASK_TEMPLATE_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TASK] TO [public]
GO
GRANT INSERT ON  [dbo].[TASK] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TASK] TO [public]
GO
GRANT SELECT ON  [dbo].[TASK] TO [public]
GO
GRANT UPDATE ON  [dbo].[TASK] TO [public]
GO
