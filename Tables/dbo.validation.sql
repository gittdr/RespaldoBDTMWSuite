CREATE TABLE [dbo].[validation]
(
[val_id] [int] NOT NULL IDENTITY(1, 1),
[val_valg_id] [int] NOT NULL,
[val_rule_number] [int] NOT NULL,
[val_type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[val_position] [int] NULL,
[val_length] [int] NULL,
[val_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[val_fetch_section_id] [int] NULL,
[val_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[val_create_date] [datetime] NULL,
[val_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[val_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_tgiu]
ON [dbo].[validation] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation
SET val_update_date = GETDATE(),
    val_update_user = SUSER_SNAME()
FROM inserted
WHERE validation.val_id = inserted.val_id

--BEGIN PTS 60428 SPN
--SELECT @created_date = ISNULL((SELECT validation.val_create_date 
--FROM validation, inserted
--WHERE validation.val_id = inserted.val_id),'')

SELECT @created_date = validation.val_create_date 
FROM validation, inserted
WHERE validation.val_id = inserted.val_id
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
BEGIN
    UPDATE validation
    SET val_create_date = GETDATE(), val_create_user =SUSER_SNAME()
    FROM validation, inserted
    WHERE validation.val_id = inserted.val_id
END

GO
ALTER TABLE [dbo].[validation] ADD CONSTRAINT [PK_validation] PRIMARY KEY CLUSTERED ([val_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[validation] ADD CONSTRAINT [FK_validation_group] FOREIGN KEY ([val_valg_id]) REFERENCES [dbo].[validation_group] ([valg_id])
GO
ALTER TABLE [dbo].[validation] ADD CONSTRAINT [FK_validation_section_fetch] FOREIGN KEY ([val_fetch_section_id]) REFERENCES [dbo].[validation_section] ([vals_id])
GO
GRANT DELETE ON  [dbo].[validation] TO [public]
GO
GRANT INSERT ON  [dbo].[validation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation] TO [public]
GO
GRANT SELECT ON  [dbo].[validation] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation] TO [public]
GO
