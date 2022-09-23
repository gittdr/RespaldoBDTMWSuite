CREATE TABLE [dbo].[ini_section]
(
[section_id] [int] NOT NULL,
[section_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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

create TRIGGER [dbo].[ini_section_tgd]
ON [dbo].[ini_section]
FOR delete AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_section, audit_oldvalue, audit_description)
select getdate(), SUSER_SNAME(), deleted.section_name, deleted.section_name, 'DELETE SECTION'
from deleted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_section_tgi]
ON [dbo].[ini_section]
FOR insert AS

INSERT INTO ini_audit
(audit_created, audit_createdby, audit_section, audit_newvalue, audit_description)
select getdate(), SUSER_SNAME(), inserted.section_name, inserted.section_name, 'INSERT SECTION'
from inserted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_section_tgu]
ON [dbo].[ini_section]
FOR update AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_section, audit_oldvalue, audit_newvalue,
 audit_description)
select getdate(), SUSER_SNAME(), inserted.section_name,
'SECTION NAME: ' + deleted.section_name + ' ACTIVE: ' + deleted.active,
'SECTION NAME: ' + inserted.section_name + ' ACTIVE: ' + inserted.active,
'UPDATE SECTION INFO'
from inserted
    inner join deleted
        on inserted.section_id = deleted.section_id

GO
ALTER TABLE [dbo].[ini_section] ADD CONSTRAINT [ini_section_pk] PRIMARY KEY CLUSTERED ([section_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ini_section] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_section] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_section] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_section] TO [public]
GO
