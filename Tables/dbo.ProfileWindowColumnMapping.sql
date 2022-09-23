CREATE TABLE [dbo].[ProfileWindowColumnMapping]
(
[pwcm_column_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pwcm_profile_window] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pwcm_key_column_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProfileWindowColumnMapping_pwcm_key_column_id] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProfileWindowColumnMapping] ADD CONSTRAINT [pk_ProfileWindowColumnMapping] PRIMARY KEY CLUSTERED ([pwcm_column_id], [pwcm_profile_window]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProfileWindowColumnMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[ProfileWindowColumnMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[ProfileWindowColumnMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProfileWindowColumnMapping] TO [public]
GO
