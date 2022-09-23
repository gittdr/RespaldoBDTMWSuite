CREATE TABLE [dbo].[company_item]
(
[cg_id] [int] NOT NULL,
[item] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[effective_startdate] [datetime] NULL,
[effective_enddate] [datetime] NULL,
[created_date] [datetime] NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_date] [datetime] NULL,
[modified_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[company_item_tgiu]
ON [dbo].[company_item]
FOR INSERT, UPDATE AS

BEGIN

    UPDATE company_item
    SET modified_date = GETDATE(),
        modified_by = SUSER_SNAME()
    FROM inserted
    WHERE company_item.cg_id = inserted.cg_id
        AND company_item.item = inserted.item
        AND company_item.type = inserted.type
        AND ((company_item.comp_id = inserted.comp_id)
             OR company_item.comp_id IS NULL)
            
            
    UPDATE company_item
    SET created_date = GETDATE(),
        created_by = SUSER_SNAME()
    FROM company_item 
        INNER JOIN inserted
        ON company_item.cg_id = inserted.cg_id
        AND company_item.item = inserted.item
        AND company_item.type = inserted.type
        AND ((company_item.comp_id = inserted.comp_id)
             OR company_item.comp_id IS NULL)
    WHERE company_item.created_date IS NULL
    
END    

GO
ALTER TABLE [dbo].[company_item] ADD CONSTRAINT [company_item_pk] PRIMARY KEY CLUSTERED ([cg_id], [item], [type], [comp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_item] TO [public]
GO
GRANT INSERT ON  [dbo].[company_item] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_item] TO [public]
GO
GRANT SELECT ON  [dbo].[company_item] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_item] TO [public]
GO
