CREATE TABLE [dbo].[ini_file]
(
[file_id] [int] NOT NULL,
[file_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_file_tgd]
ON [dbo].[ini_file]
FOR delete AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_file, audit_oldvalue, audit_description)
select getdate(), SUSER_SNAME(), deleted.file_name, deleted.file_name, 'DELETE FILE'
from deleted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_file_tgi]
ON [dbo].[ini_file]
FOR insert AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_file, audit_newvalue, audit_description)
select getdate(), SUSER_SNAME(), inserted.file_name, inserted.file_name, 'INSERT NEW FILE'
from inserted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_file_tgu]
ON [dbo].[ini_file]
FOR update AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_file, audit_oldvalue, audit_newvalue, audit_description)
select getdate(), SUSER_SNAME(), inserted.file_name,
       'FILE ID: ' + deleted.file_name + ' ACTIVE: ' + deleted.active,
       'FILE ID: ' + inserted.file_name + ' ACTIVE: ' + inserted.active,
       'UPDATE FILE INFO'
from inserted
inner join deleted
    on inserted.file_id = deleted.file_id

GO
ALTER TABLE [dbo].[ini_file] ADD CONSTRAINT [ini_file_pk] PRIMARY KEY CLUSTERED ([file_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ini_file] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_file] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_file] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_file] TO [public]
GO
