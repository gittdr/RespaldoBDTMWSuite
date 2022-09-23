CREATE TABLE [dbo].[cardinfocrossref]
(
[info_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[info_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[info_allow_modify_auto_populate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[info_auto_populate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[info_validation_level] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cicr_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_cardinfocrossref_info_id] ON [dbo].[cardinfocrossref] ([info_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cardinfocrossref] TO [public]
GO
GRANT INSERT ON  [dbo].[cardinfocrossref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cardinfocrossref] TO [public]
GO
GRANT SELECT ON  [dbo].[cardinfocrossref] TO [public]
GO
GRANT UPDATE ON  [dbo].[cardinfocrossref] TO [public]
GO
