CREATE TABLE [dbo].[notesiconrules]
(
[nir_id] [int] NOT NULL IDENTITY(1, 1),
[nir_not_urgent] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nir_processing_order] [int] NULL,
[nir_output_bitmap_id] [int] NULL,
[nir_created_date] [datetime] NULL,
[nir_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nir_modified_date] [datetime] NULL,
[nir_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notesiconrules] ADD CONSTRAINT [PK_notesiconrules] PRIMARY KEY CLUSTERED ([nir_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notesiconrules] TO [public]
GO
GRANT INSERT ON  [dbo].[notesiconrules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notesiconrules] TO [public]
GO
GRANT SELECT ON  [dbo].[notesiconrules] TO [public]
GO
GRANT UPDATE ON  [dbo].[notesiconrules] TO [public]
GO
