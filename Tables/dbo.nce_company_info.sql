CREATE TABLE [dbo].[nce_company_info]
(
[ncec_cmp_parent_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ncec_cmp_child_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ncec_contact_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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

CREATE TRIGGER [dbo].[nce_company_info_tgiu]
ON 			   [dbo].[nce_company_info]
FOR INSERT, UPDATE
AS
   
BEGIN

    if (select count(*) from deleted) = 0
        update nce_company_info
        set created    = getdate(),
           created_by = SUSER_SNAME()
        from inserted
        where nce_company_info.ncec_cmp_child_id = inserted.ncec_cmp_child_id
    
    else if not (update(created) or update(created_by) or update(updated) or update(updated_by))
        update nce_company_info
        set updated    = getdate(),
           updated_by = SUSER_SNAME()
        from inserted
        where nce_company_info.ncec_cmp_child_id  = inserted.ncec_cmp_child_id
        
END

GO
ALTER TABLE [dbo].[nce_company_info] ADD CONSTRAINT [nce_company_info_pk] PRIMARY KEY CLUSTERED ([ncec_cmp_parent_id], [ncec_cmp_child_id], [ncec_contact_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nce_company_info] TO [public]
GO
GRANT INSERT ON  [dbo].[nce_company_info] TO [public]
GO
GRANT SELECT ON  [dbo].[nce_company_info] TO [public]
GO
GRANT UPDATE ON  [dbo].[nce_company_info] TO [public]
GO
