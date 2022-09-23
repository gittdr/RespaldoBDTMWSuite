CREATE TABLE [dbo].[nce_groups]
(
[nceg_group_id] [int] NOT NULL,
[nceg_group_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NULL,
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[match_level] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[nce_groups_tgiu]
ON 			   [dbo].[nce_groups]
FOR INSERT, UPDATE
AS

BEGIN

    if (select count(*) from deleted) = 0
        update nce_groups
        set created    = getdate(),
           created_by = SUSER_SNAME()
        from inserted
        where nce_groups.nceg_group_id = inserted.nceg_group_id
    
    else if not (update(created) or update(created_by) or update(updated) or update(updated_by))
        update nce_groups
        set updated    = getdate(),
           updated_by = SUSER_SNAME()
        from inserted
        where nce_groups.nceg_group_id = inserted.nceg_group_id
    
END

GO
ALTER TABLE [dbo].[nce_groups] ADD CONSTRAINT [nce_groups_pk] PRIMARY KEY CLUSTERED ([nceg_group_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nce_groups] TO [public]
GO
GRANT INSERT ON  [dbo].[nce_groups] TO [public]
GO
GRANT SELECT ON  [dbo].[nce_groups] TO [public]
GO
GRANT UPDATE ON  [dbo].[nce_groups] TO [public]
GO
