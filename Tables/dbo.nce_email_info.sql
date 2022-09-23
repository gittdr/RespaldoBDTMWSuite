CREATE TABLE [dbo].[nce_email_info]
(
[ncee_email_person_id] [int] NOT NULL,
[ncee_email_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ncee_email_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ncee_ext_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ncee_int_usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created] [datetime] NULL,
[created_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[nce_email_info_tgiu]
ON 			   [dbo].[nce_email_info]
FOR INSERT, UPDATE
AS

BEGIN

    if (select count(*) from deleted) = 0
        update nce_email_info
        set created    = getdate(),
           created_by = SUSER_SNAME()
        from inserted
        where nce_email_info.ncee_email_person_id = inserted.ncee_email_person_id
    
    else if not (update(created) or update(created_by) or update(updated) or update(updated_by))
        update nce_email_info
        set updated    = getdate(),
           updated_by = SUSER_SNAME()
        from inserted
        where nce_email_info.ncee_email_person_id = inserted.ncee_email_person_id
    
END

GO
ALTER TABLE [dbo].[nce_email_info] ADD CONSTRAINT [nce_email_info_pk] PRIMARY KEY CLUSTERED ([ncee_email_person_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nce_email_info] TO [public]
GO
GRANT INSERT ON  [dbo].[nce_email_info] TO [public]
GO
GRANT SELECT ON  [dbo].[nce_email_info] TO [public]
GO
GRANT UPDATE ON  [dbo].[nce_email_info] TO [public]
GO
