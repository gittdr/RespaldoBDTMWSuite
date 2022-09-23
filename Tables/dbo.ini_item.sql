CREATE TABLE [dbo].[ini_item]
(
[item_id] [int] NOT NULL,
[item_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unpublished_setting] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_item_tgd]
ON [dbo].[ini_item]
FOR delete AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_item, audit_oldvalue, audit_description)
select getdate(), SUSER_SNAME(), deleted.item_name, deleted.item_name, 'DELETE ITEM'
from deleted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_item_tgi]
ON [dbo].[ini_item]
FOR insert AS


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_item, audit_newvalue, audit_description)
select getdate(), SUSER_SNAME(), inserted.item_name, inserted.item_name, 'INSERT NEW ITEM'
from inserted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_item_tgu]
ON [dbo].[ini_item]
FOR update AS

INSERT INTO ini_audit
(audit_created, audit_createdby, audit_item, audit_oldvalue, audit_newvalue, audit_description)
select getdate(), SUSER_SNAME(), inserted.item_name,
'ITEM NAME: ' + deleted.item_name + ' ACTIVE: ' + deleted.active,
'ITEM NAME: ' + inserted.item_name + ' ACTIVE: ' + inserted.active,
'UPDATE ITEM INFO'
from inserted
    inner join deleted
        on inserted.item_id = deleted.item_id

GO
ALTER TABLE [dbo].[ini_item] ADD CONSTRAINT [ini_item_pk] PRIMARY KEY CLUSTERED ([item_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ini_item] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_item] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_item] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_item] TO [public]
GO
