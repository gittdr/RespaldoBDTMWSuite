CREATE TABLE [dbo].[ini_values]
(
[value_id] [int] NOT NULL,
[file_section_item_id] [int] NOT NULL,
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[value_setting] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_level] [tinyint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_values_tgd]
ON [dbo].[ini_values]
FOR delete AS

INSERT INTO ini_audit
(audit_created, audit_createdby, audit_file, audit_section, audit_item,
 audit_newvalue, audit_description, audit_user_id)
select getdate(), SUSER_SNAME(), file_name,section_name,item_name,
    deleted.value_setting, 'DELETE NEW VALUE', deleted.usr_userid
    from deleted
        inner join ini_xref_file_section_item xfsi
            on deleted.file_section_item_id = xfsi.file_section_item_id
        inner join ini_xref_file_section xfs 
            on xfs.file_section_id = xfsi.file_section_id
        inner join ini_section s
            on s.section_id = xfs.section_id
        inner join ini_file f
            on f.file_id = xfs.file_id
        inner join ini_item i
            on i.item_id = xfsi.item_id

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[ini_values_tgiu]
ON [dbo].[ini_values]
FOR insert,update AS


if exists (select 'x' from deleted )
begin

INSERT INTO ini_audit
(audit_created, audit_createdby, audit_file, audit_section, audit_item,
 audit_newvalue, audit_description, audit_user_id)
select getdate(), SUSER_SNAME(), file_name,section_name,item_name,

deleted.value_setting, 'INSERT OLD VALUE', deleted.usr_userid
from deleted
inner join ini_xref_file_section_item xfsi
            on deleted.file_section_item_id = xfsi.file_section_item_id
        inner join ini_xref_file_section xfs 
            on xfs.file_section_id = xfsi.file_section_id
        inner join ini_section s
            on s.section_id = xfs.section_id
        inner join ini_file f
            on f.file_id = xfs.file_id
        inner join ini_item i
            on i.item_id = xfsi.item_id
 end


INSERT INTO ini_audit
(audit_created, audit_createdby, audit_file, audit_section, audit_item,
 audit_newvalue, audit_description, audit_user_id)
select getdate(), SUSER_SNAME(), file_name,section_name,item_name,

inserted.value_setting, 'INSERT NEW VALUE', inserted.usr_userid
from inserted
inner join ini_xref_file_section_item xfsi
            on inserted.file_section_item_id = xfsi.file_section_item_id
        inner join ini_xref_file_section xfs 
            on xfs.file_section_id = xfsi.file_section_id
        inner join ini_section s
            on s.section_id = xfs.section_id
        inner join ini_file f
            on f.file_id = xfs.file_id
        inner join ini_item i
            on i.item_id = xfsi.item_id
GO
ALTER TABLE [dbo].[ini_values] ADD CONSTRAINT [ini_values_pk] PRIMARY KEY CLUSTERED ([value_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ini_values_N1] ON [dbo].[ini_values] ([file_section_item_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ini_values_NU1] ON [dbo].[ini_values] ([file_section_item_id], [usr_userid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ini_values_group_level] ON [dbo].[ini_values] ([group_level]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ini_values_N2] ON [dbo].[ini_values] ([usr_userid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_values] ADD CONSTRAINT [FK_INI_VALU_REF_19189_INI_XREF] FOREIGN KEY ([file_section_item_id]) REFERENCES [dbo].[ini_xref_file_section_item] ([file_section_item_id])
GO
GRANT DELETE ON  [dbo].[ini_values] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_values] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_values] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_values] TO [public]
GO
