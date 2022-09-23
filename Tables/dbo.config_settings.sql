CREATE TABLE [dbo].[config_settings]
(
[con_id] [int] NOT NULL IDENTITY(1, 1),
[con_file] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_section] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_value] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_role] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_branchid] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_import_date] [datetime] NOT NULL,
[con_importedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[config_setting_tgd]
ON [dbo].[config_settings]
FOR delete AS
SET NOCOUNT ON

INSERT INTO config_audit
(con_section, con_key, con_value_old, con_userid, con_role, con_trans_date, con_updatedby,con_description )
select deleted.con_section, deleted.con_key, deleted.con_value, deleted.con_userid, deleted.con_role, getdate(), SUSER_SNAME(), 'DELETE ITEM'
from deleted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[config_setting_tgi]
ON [dbo].[config_settings]
FOR insert AS
SET NOCOUNT ON

INSERT INTO config_audit
(con_section, con_key, con_value_old, con_userid, con_role, con_trans_date, con_updatedby, con_description )
select inserted.con_section, inserted.con_key, inserted.con_value, inserted.con_userid, inserted.con_role, getdate(), SUSER_SNAME(), 'Inserted new setting'
from inserted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[config_setting_tgu]
ON [dbo].[config_settings]
FOR update AS
SET NOCOUNT ON

INSERT INTO config_audit
(con_section, con_key, con_value_old, con_value_new, con_userid, con_role, con_trans_date, con_updatedby,con_description )
select deleted.con_section, deleted.con_key, deleted.con_value, inserted.con_value, deleted.con_userid, deleted.con_role, getdate(), SUSER_SNAME(), 'Updated setting'
from inserted
    inner join deleted
        on inserted.con_id = deleted.con_id

GO
ALTER TABLE [dbo].[config_settings] ADD CONSTRAINT [pk_config_setting_con_id] PRIMARY KEY CLUSTERED ([con_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_con_id] ON [dbo].[config_settings] ([con_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[config_settings] TO [public]
GO
GRANT INSERT ON  [dbo].[config_settings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[config_settings] TO [public]
GO
GRANT SELECT ON  [dbo].[config_settings] TO [public]
GO
GRANT UPDATE ON  [dbo].[config_settings] TO [public]
GO
