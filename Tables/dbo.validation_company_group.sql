CREATE TABLE [dbo].[validation_company_group]
(
[valcg_id] [int] NOT NULL IDENTITY(1, 1),
[valcg_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valcg_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valcg_create_date] [datetime] NULL,
[valcg_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valcg_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_company_group_tgiu]
ON [dbo].[validation_company_group] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation_company_group
SET valcg_update_date = GETDATE(),
    valcg_update_user = SUSER_SNAME()
FROM inserted
WHERE validation_company_group.valcg_id = inserted.valcg_id

--BEGIN PTS 60428 SPN
--SELECT @created_date = ISNULL((SELECT validation_company_group.valcg_create_date 
--FROM validation_company_group, inserted
--WHERE validation_company_group.valcg_id = inserted.valcg_id),'')
SELECT @created_date = validation_company_group.valcg_create_date
FROM validation_company_group, inserted
WHERE validation_company_group.valcg_id = inserted.valcg_id
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
BEGIN
    UPDATE validation_company_group
    SET valcg_create_date = GETDATE(), valcg_create_user =SUSER_SNAME()
    FROM validation_company_group, inserted
    WHERE validation_company_group.valcg_id = inserted.valcg_id
END

GO
ALTER TABLE [dbo].[validation_company_group] ADD CONSTRAINT [PK_validation_company_group] PRIMARY KEY CLUSTERED ([valcg_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[validation_company_group] TO [public]
GO
GRANT INSERT ON  [dbo].[validation_company_group] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation_company_group] TO [public]
GO
GRANT SELECT ON  [dbo].[validation_company_group] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation_company_group] TO [public]
GO
