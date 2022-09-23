CREATE TABLE [dbo].[company_group]
(
[cg_id] [int] NOT NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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

CREATE TRIGGER [dbo].[company_group_tgiu]
ON [dbo].[company_group]
FOR INSERT, UPDATE AS

BEGIN

    UPDATE company_group
    SET modified_date = GETDATE(),
        modified_by = SUSER_SNAME()
    FROM inserted
    WHERE company_group.cg_id = inserted.cg_id
       
    UPDATE company_group
    SET created_date = GETDATE(),
        created_by = SUSER_SNAME()
    FROM company_group INNER JOIN inserted
        ON company_group.cg_id = inserted.cg_id
    WHERE company_group.created_date IS NULL

END

GO
ALTER TABLE [dbo].[company_group] ADD CONSTRAINT [company_group_pk] PRIMARY KEY CLUSTERED ([cg_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_group] TO [public]
GO
GRANT INSERT ON  [dbo].[company_group] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_group] TO [public]
GO
GRANT SELECT ON  [dbo].[company_group] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_group] TO [public]
GO
