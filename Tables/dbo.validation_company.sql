CREATE TABLE [dbo].[validation_company]
(
[valco_valcg_id] [int] NOT NULL,
[valco_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[valco_used_as] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[valco_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valco_create_date] [datetime] NULL,
[valco_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valco_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_company_tgiu]
ON [dbo].[validation_company] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation_company
SET valco_update_date = GETDATE(),
    valco_update_user = SUSER_SNAME()
FROM inserted
WHERE validation_company.valco_valcg_id = inserted.valco_valcg_id
AND validation_company.valco_cmp_id = inserted.valco_cmp_id
AND validation_company.valco_used_as = inserted.valco_used_as

--BEGIN PTS 60428 SPN
--SELECT @created_date = ISNULL((SELECT validation_company.valco_create_date 
--FROM validation_company, inserted
--WHERE validation_company.valco_valcg_id = inserted.valco_valcg_id
--AND validation_company.valco_cmp_id = inserted.valco_cmp_id
--AND validation_company.valco_used_as = inserted.valco_used_as),'')
SELECT @created_date = validation_company.valco_create_date 
FROM validation_company, inserted
WHERE validation_company.valco_valcg_id = inserted.valco_valcg_id
AND validation_company.valco_cmp_id = inserted.valco_cmp_id
AND validation_company.valco_used_as = inserted.valco_used_as
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
BEGIN
    UPDATE validation_company
    SET valco_create_date = GETDATE(), valco_create_user =SUSER_SNAME()
    FROM validation_company, inserted
    WHERE validation_company.valco_valcg_id = inserted.valco_valcg_id
    AND validation_company.valco_cmp_id = inserted.valco_cmp_id
    AND validation_company.valco_used_as = inserted.valco_used_as
END

GO
ALTER TABLE [dbo].[validation_company] ADD CONSTRAINT [PK_validation_company] PRIMARY KEY CLUSTERED ([valco_valcg_id], [valco_cmp_id], [valco_used_as]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[validation_company] ADD CONSTRAINT [FK_valco_company] FOREIGN KEY ([valco_cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[validation_company] ADD CONSTRAINT [FK_valco_valcg] FOREIGN KEY ([valco_valcg_id]) REFERENCES [dbo].[validation_company_group] ([valcg_id])
GO
GRANT DELETE ON  [dbo].[validation_company] TO [public]
GO
GRANT INSERT ON  [dbo].[validation_company] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation_company] TO [public]
GO
GRANT SELECT ON  [dbo].[validation_company] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation_company] TO [public]
GO
