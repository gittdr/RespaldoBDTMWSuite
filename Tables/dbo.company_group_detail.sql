CREATE TABLE [dbo].[company_group_detail]
(
[cg_id] [int] NOT NULL,
[comp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effective_startdate] [datetime] NULL,
[effective_enddate] [datetime] NULL,
[modified_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[company_group_detail_tgiu]
ON [dbo].[company_group_detail]
FOR INSERT, UPDATE AS

BEGIN
    UPDATE company_group_detail
    SET modified_date = GETDATE(),
        modified_by = SUSER_SNAME()
    FROM inserted
    WHERE company_group_detail.cg_id = inserted.cg_id
    AND company_group_detail.comp_id = inserted.comp_id
    
    UPDATE company_group_detail
    SET created_date = GETDATE(),
        created_by = SUSER_SNAME()
    FROM company_group_detail INNER JOIN inserted
        ON company_group_detail.cg_id = inserted.cg_id
        AND company_group_detail.comp_id = inserted.comp_id
    WHERE company_group_detail.created_date IS NULL
END

GO
ALTER TABLE [dbo].[company_group_detail] ADD CONSTRAINT [company_group_detail_pk] PRIMARY KEY CLUSTERED ([cg_id], [comp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_group_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[company_group_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_group_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[company_group_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_group_detail] TO [public]
GO
