CREATE TABLE [dbo].[validation_section]
(
[vals_id] [int] NOT NULL IDENTITY(1, 1),
[vals_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vals_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vals_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vals_create_date] [datetime] NULL,
[vals_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vals_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_section_tgiu]
ON [dbo].[validation_section] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation_section
SET vals_update_date = GETDATE(),
    vals_update_user = SUSER_SNAME()
FROM inserted
WHERE validation_section.vals_id = inserted.vals_id

--BEGIN PTS 60428 SPN
--SELECT @created_date = ISNULL((SELECT validation_section.vals_create_date 
--FROM validation_section,inserted WHERE validation_section.vals_id = inserted.vals_id),'')
SELECT @created_date = validation_section.vals_create_date 
FROM validation_section,inserted WHERE validation_section.vals_id = inserted.vals_id
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
BEGIN
    UPDATE validation_section
    SET vals_create_date = GETDATE(), vals_create_user =SUSER_SNAME()
    FROM validation_section, inserted
    WHERE validation_section.vals_id = inserted.vals_id
END  

GO
ALTER TABLE [dbo].[validation_section] ADD CONSTRAINT [PK_validation_section] PRIMARY KEY CLUSTERED ([vals_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[validation_section] TO [public]
GO
GRANT INSERT ON  [dbo].[validation_section] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation_section] TO [public]
GO
GRANT SELECT ON  [dbo].[validation_section] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation_section] TO [public]
GO
