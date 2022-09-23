CREATE TABLE [dbo].[tariff_FAK]
(
[FAK_id] [int] NOT NULL IDENTITY(1, 1),
[tar_number] [int] NOT NULL,
[FAK_NMFC_List] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAK_NMFC_Rate_Class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariff_FAK] ADD CONSTRAINT [PK__tariff_FAK__163FF23B] PRIMARY KEY CLUSTERED ([FAK_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariff_FAK] TO [public]
GO
GRANT INSERT ON  [dbo].[tariff_FAK] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariff_FAK] TO [public]
GO
GRANT SELECT ON  [dbo].[tariff_FAK] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariff_FAK] TO [public]
GO
