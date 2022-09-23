CREATE TABLE [dbo].[validation_mapping]
(
[valm_valcg_id] [int] NOT NULL,
[valm_vale_id] [int] NOT NULL,
[valm_valg_id] [int] NOT NULL,
[valm_effective_from] [datetime] NULL,
[valm_effective_to] [datetime] NULL,
[valm_message_severity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valm_create_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valm_create_date] [datetime] NULL,
[valm_update_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valm_update_date] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[validation_mapping_tgiu]
ON [dbo].[validation_mapping] 
FOR INSERT, UPDATE AS
DECLARE @created_date datetime

UPDATE validation_mapping
SET valm_update_date = GETDATE(),
    valm_update_user = SUSER_SNAME()
FROM inserted
WHERE validation_mapping.valm_valcg_id = inserted.valm_valcg_id
AND validation_mapping.valm_vale_id = inserted.valm_vale_id
AND validation_mapping.valm_valg_id = inserted.valm_valg_id

--BEGIN PTS 60428 SPN
--select @created_date = ISNULL((SELECT validation_mapping.valm_create_date 
--FROM validation_mapping, inserted
--WHERE  validation_mapping.valm_valcg_id = inserted.valm_valcg_id
--AND validation_mapping.valm_vale_id = inserted.valm_vale_id
--AND validation_mapping.valm_valg_id = inserted.valm_valg_id), '')
SELECT @created_date = validation_mapping.valm_create_date 
FROM validation_mapping, inserted
WHERE  validation_mapping.valm_valcg_id = inserted.valm_valcg_id
AND validation_mapping.valm_vale_id = inserted.valm_vale_id
AND validation_mapping.valm_valg_id = inserted.valm_valg_id
--END PTS 60428 SPN

--BEGIN PTS 60428 SPN
--IF (@created_date = '')
IF @created_date IS NULL
--END PTS 60428 SPN
BEGIN
    UPDATE validation_mapping
    SET valm_create_date = GETDATE(), valm_create_user =SUSER_SNAME()
    FROM validation_mapping, inserted
    WHERE validation_mapping.valm_valcg_id = inserted.valm_valcg_id
    AND validation_mapping.valm_vale_id = inserted.valm_vale_id
    AND validation_mapping.valm_valg_id = inserted.valm_valg_id
END

GO
ALTER TABLE [dbo].[validation_mapping] ADD CONSTRAINT [PK_validation_mapping] PRIMARY KEY CLUSTERED ([valm_valcg_id], [valm_vale_id], [valm_valg_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[validation_mapping] ADD CONSTRAINT [FK_valcg_map] FOREIGN KEY ([valm_valcg_id]) REFERENCES [dbo].[validation_company_group] ([valcg_id])
GO
ALTER TABLE [dbo].[validation_mapping] ADD CONSTRAINT [FK_vale_map] FOREIGN KEY ([valm_vale_id]) REFERENCES [dbo].[validation_event] ([vale_id])
GO
ALTER TABLE [dbo].[validation_mapping] ADD CONSTRAINT [FK_valg_map] FOREIGN KEY ([valm_valg_id]) REFERENCES [dbo].[validation_group] ([valg_id])
GO
GRANT DELETE ON  [dbo].[validation_mapping] TO [public]
GO
GRANT INSERT ON  [dbo].[validation_mapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[validation_mapping] TO [public]
GO
GRANT SELECT ON  [dbo].[validation_mapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[validation_mapping] TO [public]
GO
