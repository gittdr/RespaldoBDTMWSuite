CREATE TABLE [dbo].[stdhierarchy]
(
[sth_id] [int] NOT NULL IDENTITY(1, 1),
[sth_abbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sth_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sth_priority] [int] NOT NULL,
[sth_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sth_update_by] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sth_update_dt] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_stdhierarchy] ON [dbo].[stdhierarchy]
 for insert as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
 * 
 * NAME:
 * dbo.It_stdhierarchy
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * Insert trigger for stdhierarchy table
 *
 * RETURNS:
 * NA
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 06/16/2011 ? PTS54605 vjh created
 *
 **/


declare @sth_id	int,
	@tmwuser VARCHAR(255),
	@newvalue varchar(100)

	EXEC gettmwuser @tmwuser OUTPUT

	SELECT @sth_id = sth_id, @newvalue = sth_abbr
		FROM inserted
	INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_field, stha_new_value, stha_update_dt, stha_update_by)
                         VALUES (@sth_id, 'INSERTED', 'sth_abbr', @newvalue, GETDATE(), @tmwuser)
	SELECT @sth_id = sth_id, @newvalue = sth_name
		FROM inserted
	INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_field, stha_new_value, stha_update_dt, stha_update_by)
                         VALUES (@sth_id, 'INSERTED', 'sth_name', @newvalue, GETDATE(), @tmwuser)
	SELECT @sth_id = sth_id, @newvalue = sth_retired
		FROM inserted
	INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_field, stha_new_value, stha_update_dt, stha_update_by)
                         VALUES (@sth_id, 'INSERTED', 'sth_retired', @newvalue, GETDATE(), @tmwuser)
	SELECT @sth_id = sth_id, @newvalue = ISNULL(CAST(inserted.sth_priority AS VARCHAR(10)), ' ')
		FROM inserted
	INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_field, stha_new_value, stha_update_dt, stha_update_by)
                         VALUES (@sth_id, 'INSERTED', 'sth_priority', @newvalue, GETDATE(), @tmwuser)

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_stdhierarchy] ON [dbo].[stdhierarchy]
FOR INSERT,UPDATE
AS


declare	@tmwuser		varchar (255)
declare	@updatecount	int,
		@delcount		int

exec gettmwuser @tmwuser output  

select @updatecount = count(*) from inserted
select @delcount = count(*) from deleted


if (@updatecount > 0 and not update(sth_update_by) and not update(sth_update_dt)) OR
	(@updatecount > 0 and @delcount = 0)
	Update stdhierarchy
	set sth_update_by = @tmwuser,
		sth_update_dt = getdate()
	from inserted
	where inserted.sth_id = stdhierarchy.sth_id
		and (isNull(stdhierarchy.sth_update_by,'') <> @tmwuser
		OR isNull(stdhierarchy.sth_update_dt,'') <> getdate())

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_stdhierarchy] ON [dbo].[stdhierarchy]
FOR UPDATE
AS
/**
 * 
 * NAME:
 * dbo.ut_stdhierarchy
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * update trigger for stdhierarchy table
 *
 * RETURNS:
 * NA
 * 
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 *
 * REFERENCES: 
 * 
 * REVISION HISTORY:
 * 06/16/2011 ? PTS54605 vjh created
 *
 **/
DECLARE	@tmwuser	VARCHAR(255),
        @currentdate	DATETIME,
        @oldvalue	VARCHAR(100),
        @newvalue	VARCHAR(100),
        @sth_id		int


EXEC gettmwuser @tmwuser OUTPUT


   SET @currentdate = GETDATE()
   SELECT @sth_id = inserted.sth_id
     FROM inserted

   IF UPDATE(sth_name)
   BEGIN
      SELECT @oldvalue = ISNULL(deleted.sth_name, ' '),
             @newvalue = ISNULL(inserted.sth_name, ' ')
        FROM deleted, inserted
       WHERE deleted.sth_id = inserted.sth_id
      IF @oldvalue <> @newvalue
         INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_dt,
                                       stha_update_by, stha_update_field,
                                       stha_original_value, stha_new_value)
                               VALUES (@sth_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'sth_name', @oldvalue, @newvalue)
   END    
   
   IF UPDATE(sth_retired)
   BEGIN
      SELECT @oldvalue = ISNULL(deleted.sth_retired, ' '),
             @newvalue = ISNULL(inserted.sth_retired, ' ')
        FROM deleted, inserted
       WHERE deleted.sth_id = inserted.sth_id
      IF @oldvalue <> @newvalue
         INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_dt,
                                       stha_update_by, stha_update_field,
                                       stha_original_value, stha_new_value)
                               VALUES (@sth_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'sth_retired', @oldvalue, @newvalue)
   END 

   IF UPDATE(sth_priority)
   BEGIN
      SELECT @oldvalue = ISNULL(CAST(deleted.sth_priority AS VARCHAR(10)), ' '),
             @newvalue = ISNULL(CAST(inserted.sth_priority AS VARCHAR(10)), ' ')
        FROM deleted, inserted
       WHERE deleted.sth_id = inserted.sth_id
      IF @oldvalue <> @newvalue
         INSERT INTO stdhierarchyaudit (sth_id, stha_action, stha_update_dt,
                                       stha_update_by, stha_update_field,
                                       stha_original_value, stha_new_value)
                               VALUES (@sth_id, 'UPDATE', @currentdate,
                                       @tmwuser, 'sth_priority', @oldvalue, @newvalue)
   END

GO
ALTER TABLE [dbo].[stdhierarchy] ADD CONSTRAINT [pk_stdhierarchy_sth_id] PRIMARY KEY CLUSTERED ([sth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stdhierarchy] TO [public]
GO
GRANT INSERT ON  [dbo].[stdhierarchy] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stdhierarchy] TO [public]
GO
GRANT SELECT ON  [dbo].[stdhierarchy] TO [public]
GO
GRANT UPDATE ON  [dbo].[stdhierarchy] TO [public]
GO
