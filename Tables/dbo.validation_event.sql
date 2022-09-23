CREATE TABLE [dbo].[validation_event]
(
[vale_id] [int] NOT NULL IDENTITY(1, 1),
[vale_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vale_pre_validation_rule] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vale_active_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vale_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vale_create_date] [datetime] NULL,
[vale_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vale_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_event_tgiu]
ON [dbo].[validation_event] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation_event
SET vale_update_date = GETDATE(),
    vale_update_user = SUSER_SNAME()
FROM inserted
WHERE validation_event.vale_id = inserted.vale_id

--BEGIN PTS 60428 SPN
--SELECT @created_date = ISNULL((SELECT validation_event.vale_create_date 
--FROM validation_event, inserted
--WHERE validation_event.vale_id = inserted.vale_id),'')
SELECT @created_date = validation_event.vale_create_date 
FROM validation_event, inserted
WHERE validation_event.vale_id = inserted.vale_id
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
    BEGIN
        UPDATE validation_event
        SET vale_create_date = GETDATE(), vale_create_user =SUSER_SNAME()
        FROM validation_event, inserted
        WHERE validation_event.vale_id = inserted.vale_id
    END

GO
ALTER TABLE [dbo].[validation_event] ADD CONSTRAINT [PK_validation_event] PRIMARY KEY CLUSTERED ([vale_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[validation_event] TO [public]
GO
GRANT INSERT ON  [dbo].[validation_event] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation_event] TO [public]
GO
GRANT SELECT ON  [dbo].[validation_event] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation_event] TO [public]
GO
