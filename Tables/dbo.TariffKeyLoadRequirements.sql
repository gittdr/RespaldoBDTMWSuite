CREATE TABLE [dbo].[TariffKeyLoadRequirements]
(
[tklr_id] [int] NOT NULL IDENTITY(1, 1),
[trk_number] [int] NULL,
[tar_number] [int] NULL,
[tklr_equip_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tklr_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tklr_createby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tklr_createdate] [datetime] NULL,
[tklr_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tklr_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iudt_tariffkeyloadrequirements_SortKey]
ON [dbo].[TariffKeyLoadRequirements]
FOR INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON

	-- remove deleted load req from sort key
	UPDATE tariffkey
	SET tariffkey.tar_number = tariffkey.tar_number
	FROM tariffkey
	INNER JOIN deleted ON tariffkey.trk_number = deleted.trk_number
	
	-- add new/updated load req to sort key
	UPDATE tariffkey
	SET tariffkey.tar_number = tariffkey.tar_number
	FROM tariffkey
	INNER JOIN inserted ON tariffkey.trk_number = inserted.trk_number
END
GO
ALTER TABLE [dbo].[TariffKeyLoadRequirements] ADD CONSTRAINT [pk_tklr_id] PRIMARY KEY CLUSTERED ([tklr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tariffkey_loadrequirement_trknumber] ON [dbo].[TariffKeyLoadRequirements] ([trk_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TariffKeyLoadRequirements] TO [public]
GO
GRANT INSERT ON  [dbo].[TariffKeyLoadRequirements] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TariffKeyLoadRequirements] TO [public]
GO
GRANT SELECT ON  [dbo].[TariffKeyLoadRequirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[TariffKeyLoadRequirements] TO [public]
GO
