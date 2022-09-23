CREATE TABLE [dbo].[validation_group]
(
[valg_id] [int] NOT NULL IDENTITY(1, 1),
[valg_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valg_effective_from] [datetime] NULL,
[valg_effective_to] [datetime] NULL,
[valg_failure_section_id] [int] NULL,
[valg_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valg_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valg_create_date] [datetime] NULL,
[valg_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valg_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_group_tgiu]
ON [dbo].[validation_group] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation_group
SET valg_update_date = GETDATE(),
    valg_update_user = SUSER_SNAME()
FROM inserted
WHERE validation_group.valg_id = inserted.valg_id

--BEGIN PTS 60428 SPN
--SELECT @created_date = ISNULL((SELECT validation_group.valg_create_date 
--FROM validation_group, inserted
--WHERE validation_group.valg_id = inserted.valg_id),'')
SELECT @created_date = validation_group.valg_create_date 
FROM validation_group, inserted
WHERE validation_group.valg_id = inserted.valg_id
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
BEGIN
    UPDATE validation_group
    SET valg_create_date = GETDATE(), valg_create_user =SUSER_SNAME()
    FROM validation_group, inserted
    WHERE validation_group.valg_id = inserted.valg_id
END

GO
ALTER TABLE [dbo].[validation_group] ADD CONSTRAINT [PK_validation_group] PRIMARY KEY CLUSTERED ([valg_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[validation_group] ADD CONSTRAINT [FK_validation_section_failure] FOREIGN KEY ([valg_failure_section_id]) REFERENCES [dbo].[validation_section] ([vals_id])
GO
GRANT DELETE ON  [dbo].[validation_group] TO [public]
GO
GRANT INSERT ON  [dbo].[validation_group] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation_group] TO [public]
GO
GRANT SELECT ON  [dbo].[validation_group] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation_group] TO [public]
GO
