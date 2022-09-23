CREATE TABLE [dbo].[rating_hierarchy_detail]
(
[rhd_id] [int] NOT NULL IDENTITY(1, 1),
[rhh_id] [int] NOT NULL,
[rhd_sequence] [int] NOT NULL,
[rhd_column_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhd_column_label] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhd_column_sort_key] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rhd_original_sequence] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_rating_hierarchy_detail] ON [dbo].[rating_hierarchy_detail] FOR INSERT AS
DECLARE @tmwuser varchar (255)
		
exec gettmwuser @tmwuser output

INSERT INTO rating_hierarchy_detail_audit 
   SELECT rhd_id, rhh_id, rhd_sequence, rhd_column_name, rhd_column_label, rhd_column_sort_key,
          @tmwuser, GETDATE(), 'I'
     FROM inserted

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_rating_hierarchy_detail] ON [dbo].[rating_hierarchy_detail] FOR UPDATE AS
DECLARE @tmwuser varchar (255)
		
exec gettmwuser @tmwuser output

INSERT INTO rating_hierarchy_detail_audit 
   SELECT rhd_id, rhh_id, rhd_sequence, rhd_column_name, rhd_column_label, rhd_column_sort_key,
          @tmwuser, GETDATE(), 'U'
     FROM inserted

GO
ALTER TABLE [dbo].[rating_hierarchy_detail] ADD CONSTRAINT [pk_rating_hierarchy_detail_rhd_id_rhh_id] PRIMARY KEY CLUSTERED ([rhd_id], [rhh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[rating_hierarchy_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[rating_hierarchy_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[rating_hierarchy_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[rating_hierarchy_detail] TO [public]
GO
